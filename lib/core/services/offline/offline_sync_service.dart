import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../api/api_service.dart';
import '../storage/storage_service.dart';
import '../../../data/models/card.dart';
import '../../../data/models/note.dart';
import '../../../data/models/page.dart' as page_model;
import '../../../data/models/requests/create_board_request.dart';
import '../../../data/models/requests/create_card_request.dart';
import '../../../data/models/requests/update_card_request.dart';
import '../../../data/models/requests/create_note_request.dart';
import '../../../data/models/requests/update_note_request.dart';

class OfflineSyncService {
  final ApiService _apiService;
  final StorageService _storageService;
  late Database _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = false;
  bool _isSyncing = false;

  OfflineSyncService(this._apiService, this._storageService);

  Future<void> init() async {
    await _initDatabase();
    await _checkConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'superthread_offline.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT,
        board_id TEXT NOT NULL,
        list_id TEXT NOT NULL,
        assigned_to TEXT,
        tags TEXT,
        status TEXT NOT NULL,
        position INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        last_sync_at TEXT,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT,
        tags TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        last_sync_at TEXT,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pages (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT,
        tags TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        last_sync_at TEXT,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE boards (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        project_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        last_sync_at TEXT,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_cards_board_id ON cards(board_id)');
    await db.execute('CREATE INDEX idx_cards_sync_status ON cards(sync_status)');
    await db.execute('CREATE INDEX idx_pending_operations ON pending_operations(entity_type, entity_id)');
  }

  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

  void _setupConnectivityListener() {
    final connectivity = Connectivity();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (wasOffline && _isOnline) {
        _syncPendingData();
      }
    });
  }

  // Cache operations
  Future<void> cacheCards(List<Card> cards) async {
    final batch = _database.batch();
    final now = DateTime.now().toIso8601String();

    for (final card in cards) {
      batch.insert(
        'cards',
        {
          'id': card.id,
          'title': card.title,
          'content': card.description,
          'board_id': card.boardId,
          'list_id': card.listId,
          'assigned_to': card.assignedTo,
          'tags': jsonEncode(card.tags),
          'status': card.status,
          'position': card.position,
          'created_at': card.createdAt.toIso8601String(),
          'updated_at': card.updatedAt?.toIso8601String(),
          'sync_status': 'synced',
          'last_sync_at': now,
          'is_deleted': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<void> cacheCard(Card card, {bool isLocal = false}) async {
    await _database.insert(
      'cards',
      {
        'id': card.id,
        'title': card.title,
        'content': card.description,
        'board_id': card.boardId,
        'list_id': card.listId,
        'assigned_to': card.assignedTo,
        'tags': jsonEncode(card.tags),
        'status': card.status,
        'position': card.position,
        'created_at': card.createdAt.toIso8601String(),
        'updated_at': card.updatedAt?.toIso8601String(),
        'sync_status': isLocal ? 'pending' : 'synced',
        'last_sync_at': isLocal ? null : DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (isLocal) {
      await _addPendingOperation('card', card.id, 'create', card);
    }
  }

  Future<void> updateCard(Card card) async {
    await _database.update(
      'cards',
      {
        'title': card.title,
        'content': card.description,
        'assigned_to': card.assignedTo,
        'tags': jsonEncode(card.tags),
        'status': card.status,
        'position': card.position,
        'updated_at': card.updatedAt?.toIso8601String(),
        'sync_status': 'pending',
      },
      where: 'id = ?',
      whereArgs: [card.id],
    );

    await _addPendingOperation('card', card.id, 'update', card);
  }

  Future<void> deleteCard(String cardId) async {
    await _database.update(
      'cards',
      {
        'sync_status': 'pending',
        'is_deleted': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cardId],
    );

    await _addPendingOperation('card', cardId, 'delete', {'id': cardId});
  }

  Future<List<Card>> getCachedCards({
    String? boardId,
    String? listId,
    bool includeDeleted = false,
  }) async {
    String whereClause = includeDeleted ? '' : 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    if (boardId != null) {
      whereClause = (whereClause.isEmpty ? '' : '$whereClause AND ') + 'board_id = ?';
      whereArgs.add(boardId);
    }

    if (listId != null) {
      whereClause = (whereClause.isEmpty ? '' : '$whereClause AND ') + 'list_id = ?';
      whereArgs.add(listId);
    }

    final results = await _database.query(
      'cards',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'position ASC, updated_at DESC',
    );

    return results.map((row) => _mapRowToCard(row)).toList();
  }

  Future<void> cacheNotes(List<Note> notes) async {
    final batch = _database.batch();
    final now = DateTime.now().toIso8601String();

    for (final note in notes) {
      batch.insert(
        'notes',
        {
          'id': note.id,
          'title': note.title,
          'content': note.content,
          'tags': note.tags != null ? jsonEncode(note.tags) : null,
          'created_at': note.createdAt.toIso8601String(),
          'updated_at': note.updatedAt?.toIso8601String(),
          'sync_status': 'synced',
          'last_sync_at': now,
          'is_deleted': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<void> cacheNote(Note note, {bool isLocal = false}) async {
    await _database.insert(
      'notes',
      {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'tags': note.tags != null ? jsonEncode(note.tags) : null,
        'created_at': note.createdAt.toIso8601String(),
        'updated_at': note.updatedAt?.toIso8601String(),
        'sync_status': isLocal ? 'pending' : 'synced',
        'last_sync_at': isLocal ? null : DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (isLocal) {
      await _addPendingOperation('note', note.id, 'create', note);
    }
  }

  Future<List<Note>> getCachedNotes({bool includeDeleted = false}) async {
    final results = await _database.query(
      'notes',
      where: includeDeleted ? null : 'is_deleted = 0',
      orderBy: 'updated_at DESC',
    );

    return results.map((row) => _mapRowToNote(row)).toList();
  }

  // Sync operations
  Future<void> _addPendingOperation(
    String entityType,
    String entityId,
    String operation,
    dynamic data,
  ) async {
    await _database.insert(
      'pending_operations',
      {
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'data': jsonEncode(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
      },
    );
  }

  Future<void> _syncPendingData() async {
    if (!_isOnline) return;
    
    // Prevent concurrent sync operations
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) return;

    final pendingOperations = await _database.query(
      'pending_operations',
      orderBy: 'timestamp ASC',
      limit: 50, // Process in batches to avoid overwhelming the server
    );

    for (final operation in pendingOperations) {
      try {
        await _processPendingOperation(operation);

        // Remove successful operation
        await _database.delete(
          'pending_operations',
          where: 'id = ?',
          whereArgs: [operation['id']],
        );
      } catch (e) {
        // Update retry count
        await _database.update(
          'pending_operations',
          {
            'retry_count': (operation['retry_count'] as int) + 1,
          },
          where: 'id = ?',
          whereArgs: [operation['id']],
        );

        // Remove if too many retries
        if ((operation['retry_count'] as int) >= 3) {
          await _database.delete(
            'pending_operations',
            where: 'id = ?',
            whereArgs: [operation['id']],
          );
        }
      }
    }

      // Fetch and cache latest data from server
      await _fetchLatestData();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processPendingOperation(Map<String, dynamic> operation) async {
    final entityType = operation['entity_type'] as String;
    final entityId = operation['entity_id'] as String;
    final operationType = operation['operation'] as String;
    final data = jsonDecode(operation['data'] as String);

    switch (entityType) {
      case 'card':
        await _processCardOperation(entityId, operationType, data);
        break;
      case 'note':
        await _processNoteOperation(entityId, operationType, data);
        break;
    }
  }

  Future<void> _processCardOperation(
    String entityId,
    String operationType,
    dynamic data,
  ) async {
    final teamId = await _storageService.getTeamId();
    if (teamId == null) return;

    switch (operationType) {
      case 'create':
        final cardData = data as Card;
        final request = CreateCardRequest(
          title: cardData.title,
          content: cardData.description,
          boardId: cardData.boardId,
          listId: cardData.listId,
          ownerId: cardData.assignedTo,
          tags: cardData.tags,
          due_date: cardData.dueDate?.millisecondsSinceEpoch,
        );
        await _apiService.createCard(teamId, request);
        break;
      case 'update':
        final cardData = data as Card;
        final request = UpdateCardRequest(
          title: cardData.title,
          content: cardData.description,
          listId: cardData.listId,
          ownerId: cardData.assignedTo,
          tags: cardData.tags,
          status: cardData.status,
          due_date: cardData.dueDate?.millisecondsSinceEpoch,
          archived: cardData.isArchived,
        );
        await _apiService.updateCard(teamId, entityId, request);
        break;
      case 'delete':
        await _apiService.deleteCard(teamId, entityId);
        break;
    }
  }

  Future<void> _processNoteOperation(
    String entityId,
    String operationType,
    dynamic data,
  ) async {
    final teamId = await _storageService.getTeamId();
    if (teamId == null) return;

    switch (operationType) {
      case 'create':
        final noteData = data as Note;
        final request = CreateNoteRequest(
          title: noteData.title,
          content: noteData.content,
          teamId: teamId,
          tags: noteData.tags,
        );
        await _apiService.createNote(teamId, request);
        break;
      case 'update':
        final noteData = data as Note;
        final request = UpdateNoteRequest(
          title: noteData.title,
          content: noteData.content,
          tags: noteData.tags,
        );
        await _apiService.updateNote(teamId, entityId, request);
        break;
      case 'delete':
        await _apiService.deleteNote(teamId, entityId);
        break;
    }
  }

  Future<void> _fetchLatestData() async {
    final teamId = await _storageService.getTeamId();
    if (teamId == null) return;

    try {
      // Sync cards using board-specific endpoints
      final boardsResponse = await _apiService.getBoards(teamId, limit: 50, archived: "false");
      for (final board in boardsResponse.boards) {
        final cardsResponse = await _apiService.getCards(teamId, boardId: board.id, limit: 100);
        await cacheCards(cardsResponse.cards);
      }

      // Sync notes
      final notesResponse = await _apiService.getNotes(teamId: teamId, limit: 100);
      await cacheNotes(notesResponse.notes);

      // Sync pages
      final pagesResponse = await _apiService.getPages(teamId, limit: 100);
      await cachePages(pagesResponse.pages);
    } catch (e) {
      // Handle sync errors gracefully
    }
  }

  // Helper methods
  Card _mapRowToCard(Map<String, dynamic> row) {
    final tagsJson = row['tags'] as String?;
    return Card(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['content'] as String?,
      boardId: row['board_id'] as String,
      listId: row['list_id'] as String?,
      teamId: row['team_id'] as String?,
      assignedTo: row['assigned_to'] as String?,
      assignedToName: row['assigned_to_name'] as String?,
      tags: tagsJson != null ? jsonDecode(tagsJson) : null,
      status: row['status'] as String?,
      position: row['position'] as int?,
      coverImageUrl: row['cover_image_url'] as String?,
      dueDate: row['due_date'] != null ? DateTime.parse(row['due_date'] as String) : null,
      isArchived: (row['is_archived'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at'] as String) : null,
    );
  }

  Note _mapRowToNote(Map<String, dynamic> row) {
    final tagsJson = row['tags'] as String?;
    return Note(
      id: row['id'] as String,
      title: row['title'] as String,
      content: row['content'] as String,
      tags: tagsJson != null ? jsonDecode(tagsJson) : null,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // Page methods
  page_model.Page _mapRowToPage(Map<String, dynamic> row) {
    final tagsJson = row['tags'] as String?;
    return page_model.Page(
      id: row['id'] as String,
      title: row['title'] as String,
      content: row['content'] as String?,
      tags: tagsJson != null ? List<String>.from(jsonDecode(tagsJson)) : null,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at'] as String) : null,
    );
  }

  Future<void> cachePages(List<page_model.Page> pages) async {
    final batch = _database.batch();
    final now = DateTime.now().toIso8601String();

    for (final page in pages) {
      batch.insert(
        'pages',
        {
          'id': page.id,
          'title': page.title,
          'content': page.content,
          'tags': page.tags != null ? jsonEncode(page.tags) : null,
          'created_at': page.createdAt.toIso8601String(),
          'updated_at': page.updatedAt?.toIso8601String() ?? now,
          'sync_status': 'synced',
          'last_sync_at': now,
          'is_deleted': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<page_model.Page>> getCachedPages({bool includeDeleted = false}) async {
    final results = await _database.query(
      'pages',
      where: includeDeleted ? null : 'is_deleted = 0',
      orderBy: 'updated_at DESC',
    );

    return results.map((row) => _mapRowToPage(row)).toList();
  }

  bool get isOnline => _isOnline;

  void dispose() {
    _connectivitySubscription?.cancel();
    _database.close();
  }
}