import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vibration/vibration.dart';
import '../../../data/models/notification_model.dart';
import '../api/api_service.dart';
import '../storage/storage_service.dart';
import '../service_locator.dart';

class SuperthreadNotificationService {
  static final SuperthreadNotificationService _instance =
      SuperthreadNotificationService._internal();
  factory SuperthreadNotificationService() => _instance;
  SuperthreadNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _pollingTimer;
  NotificationPreferences _preferences = const NotificationPreferences();
  DateTime _lastSuccessfulPoll = DateTime.now();
  Map<String, DateTime> _lastKnownTimestamps = <String, DateTime>{};
  bool _isInitialized = false;
  String? _currentTeamId;

  // Initialization
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Load preferences
      await _loadPreferences();

      // Request notification permissions
      await _requestPermissions();

      // Initialize vibration
      await Vibration.hasVibrator();

      _isInitialized = true;

      // Start polling if enabled
      if (_preferences.enabled && _currentTeamId != null) {
        startPolling(_currentTeamId!);
      }

      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
    }
  }

  // Local Notifications Setup
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Create notification channels
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // Main updates channel
    const AndroidNotificationChannel updatesChannel = AndroidNotificationChannel(
      'superthread_updates',
      'Superthread Updates',
      description: 'Notifications for cards, notes, and project updates',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    // Comments channel
    const AndroidNotificationChannel commentsChannel = AndroidNotificationChannel(
      'superthread_comments',
      'Comments & Mentions',
      description: 'Notifications for comments and mentions',
      importance: Importance.low,
      enableVibration: true,
      playSound: true,
    );

    // Deadlines channel
    const AndroidNotificationChannel deadlinesChannel = AndroidNotificationChannel(
      'superthread_deadlines',
      'Deadlines & Reminders',
      description: 'Important deadline and reminder notifications',
      importance: Importance.high,
            enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(updatesChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(commentsChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(deadlinesChannel);
  }

  Future<void> _requestPermissions() async {
    // Android
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // iOS
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions();
  }

  // Preferences Management
  Future<void> _loadPreferences() async {
    try {
      final storageService = getService<StorageService>();
      final prefsJson = await storageService.getNotificationPreferences();
      if (prefsJson.isNotEmpty) {
        _preferences = NotificationPreferences.fromJson(jsonDecode(prefsJson));
      }
    } catch (e) {
      debugPrint('Failed to load notification preferences: $e');
    }
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    try {
      _preferences = preferences;
      final storageService = getService<StorageService>();
      await storageService.saveNotificationPreferences(jsonEncode(preferences.toJson()));

      // Restart polling if needed
      if (_currentTeamId != null) {
        stopPolling();
        if (preferences.enabled) {
          startPolling(_currentTeamId!);
        }
      }
    } catch (e) {
      debugPrint('Failed to save notification preferences: $e');
    }
  }

  // Polling Management
  void startPolling(String teamId) {
    if (!_isInitialized || !_preferences.enabled) return;

    stopPolling(); // Stop any existing timer
    _currentTeamId = teamId;

    final interval = Duration(minutes: _preferences.pollingInterval);
    _pollingTimer = Timer.periodic(interval, (_) => _performPolling());

    debugPrint('Started polling for team: $teamId with interval: ${_preferences.pollingInterval} minutes');
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('Stopped notification polling');
  }

  Future<void> _performPolling() async {
    if (_currentTeamId == null || !_preferences.enabled) return;

    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('No internet connection, skipping poll');
        return;
      }

      // Check if in quiet hours
      if (_isQuietHours()) {
        debugPrint('In quiet hours, skipping notification display');
        return;
      }

      // Perform update check
      final result = await _checkForUpdates(_currentTeamId!);

      if (result.hasAnyNewItems) {
        await _processNewNotifications(result);
      }

      _lastSuccessfulPoll = DateTime.now();

    } catch (e) {
      debugPrint('Polling failed: $e');
      // Don't retry immediately to avoid spam
    }
  }

  bool _isQuietHours() {
    final currentHour = DateTime.now().hour;
    return _preferences.quietHours.contains(currentHour);
  }

  Future<UpdateCheckResult> _checkForUpdates(String teamId) async {
    final now = DateTime.now();

    // Get last known timestamps
    final lastCardCheck = _lastKnownTimestamps['cards'] ?? now.subtract(const Duration(days: 1));
    final lastNoteCheck = _lastKnownTimestamps['notes'] ?? now.subtract(const Duration(days: 1));
    final lastCommentCheck = _lastKnownTimestamps['comments'] ?? now.subtract(const Duration(days: 1));

    final notifications = <NotificationItem>[];
    bool hasNewCards = false;
    bool hasNewNotes = false;
    bool hasNewComments = false;
    bool hasNewAssignments = false;
    int newCardsCount = 0;
    int newNotesCount = 0;
    int newCommentsCount = 0;
    int newAssignmentsCount = 0;

    try {
      final apiService = getService<ApiService>();

      // Check for new cards
      if (_preferences.cardNotifications) {
        final boardsResponse = await apiService.getBoards(teamId, limit: 50, archived: "false");
        for (final board in boardsResponse.boards) {
          final cardsResponse = await apiService.getCards(teamId, boardId: board.id, limit: 100, archived: "false");
          for (final card in cardsResponse.cards) {
            if (card.createdAt.isAfter(lastCardCheck)) {
              notifications.add(NotificationItem(
                id: 'card_${card.id}',
                title: 'New Card: ${card.title}',
                body: card.title,
                type: 'card',
                data: {'cardId': card.id},
                createdAt: card.createdAt,
              ));
              hasNewCards = true;
              newCardsCount++;
            }
          }
        }
        _lastKnownTimestamps['cards'] = now;
      }

      // Check for new notes
      if (_preferences.noteNotifications) {
        final notesResponse = await apiService.getNotes(teamId: teamId);
        for (final note in notesResponse.notes) {
          if (note.createdAt.isAfter(lastNoteCheck)) {
            notifications.add(NotificationItem(
              id: 'note_${note.id}',
              title: 'New Note: ${note.title}',
              body: note.title,
              type: 'note',
              data: {'noteId': note.id},
              createdAt: note.createdAt,
            ));
            hasNewNotes = true;
            newNotesCount++;
          }
        }
        _lastKnownTimestamps['notes'] = now;
      }

      // Check for assignments (simulated since no direct endpoint)
      if (_preferences.assignmentNotifications) {
        // This would require a custom endpoint or enhancement
        // For now, we'll simulate assignment checking
        _lastKnownTimestamps['assignments'] = now;
      }

    } catch (e) {
      debugPrint('Update check failed: $e');
    }

    return UpdateCheckResult(
      hasNewCards: hasNewCards,
      hasNewNotes: hasNewNotes,
      hasNewComments: hasNewComments,
      hasNewAssignments: hasNewAssignments,
      newCardsCount: newCardsCount,
      newNotesCount: newNotesCount,
      newCommentsCount: newCommentsCount,
      newAssignmentsCount: newAssignmentsCount,
      lastChecked: now,
      notifications: notifications,
    );
  }

  Future<void> _processNewNotifications(UpdateCheckResult result) async {
    for (final notification in result.notifications) {
      await _showNotification(notification);
    }

    // Show summary notification if multiple items
    if (result.totalNewItems > 3) {
      await _showSummaryNotification(result);
    }
  }

  Future<void> _showNotification(NotificationItem notification) async {
    if (!_isInQuietHours() || _isHighPriorityNotification(notification)) {
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _getChannelId(notification.type),
          'Superthread Notification',
          channelDescription: notification.body,
          importance: _getImportance(notification),
          priority: _getPriority(notification),
          icon: '@mipmap/ic_notification',
          largeIcon: notification.imageUrl != null
              ? FilePathAndroidBitmap(notification.imageUrl!)
              : null,
          styleInformation: notification.imageUrl != null
              ? BigPictureStyleInformation(
                  FilePathAndroidBitmap(notification.imageUrl!),
                  contentTitle: notification.title,
                  htmlFormatContent: true,
                )
              : null,
          enableVibration: _preferences.vibrationEnabled,
          playSound: _preferences.soundEnabled,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: _preferences.soundEnabled,
        ),
      );

      await _notifications.show(
        0,
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode(notification.toJson()),
      );

      // Trigger vibration if enabled
      if (_preferences.vibrationEnabled && !kIsWeb) {
        await Vibration.vibrate(duration: 100, amplitude: 128);
      }
    }

    // Save notification to storage
    await _saveNotificationToStorage(notification);
  }

  Future<void> _showSummaryNotification(UpdateCheckResult result) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'superthread_updates',
        'Superthread Updates',
        channelDescription: '${result.totalNewItems} new items: ${result.newCardsCount} cards, ${result.newNotesCount} notes',
        importance: Importance.high,
                enableVibration: _preferences.vibrationEnabled,
        playSound: _preferences.soundEnabled,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _preferences.soundEnabled,
        badgeNumber: result.totalNewItems,
      ),
    );

    await _notifications.show(
      0,
      'Superthread Updates',
      '${result.totalNewItems} new items',
      notificationDetails,
    );
  }

  Future<void> _saveNotificationToStorage(NotificationItem notification) async {
    try {
      final storageService = getService<StorageService>();
      await storageService.saveNotification(notification.toJson());
    } catch (e) {
      debugPrint('Failed to save notification to storage: $e');
    }
  }

  // Utility Methods
  String _getChannelId(String type) {
    switch (type) {
      case 'card':
      case 'project':
        return 'superthread_updates';
      case 'note':
        return 'superthread_updates';
      case 'comment':
        return 'superthread_comments';
      case 'deadline':
        return 'superthread_deadlines';
      default:
        return 'superthread_updates';
    }
  }

  Importance _getImportance(NotificationItem notification) {
    switch (notification.type) {
      case 'deadline':
        return Importance.high;
      case 'assignment':
        return Importance.defaultImportance;
      case 'card':
        return Importance.defaultImportance;
      case 'note':
        return Importance.defaultImportance;
      default:
        return Importance.low;
    }
  }

  Priority _getPriority(NotificationItem notification) {
    switch (notification.type) {
      case 'deadline':
        return Priority.high;
      case 'assignment':
        return Priority.low;
      case 'card':
        return Priority.low;
      case 'note':
        return Priority.low;
      default:
        return Priority.low;
    }
  }

  bool _isHighPriorityNotification(NotificationItem notification) {
    return notification.type == 'deadline';
  }

  bool _isInQuietHours() {
    final currentHour = DateTime.now().hour;
    return _preferences.quietHours.contains(currentHour);
  }

  // Public API
  NotificationPreferences get preferences => _preferences;

  DateTime get lastPollTime => _lastSuccessfulPoll;

  bool get isPolling => _pollingTimer?.isActive ?? false;

  List<NotificationItem> get cachedNotifications => [];

  // Cleanup
  void dispose() {
    stopPolling();
  }
}

// Extension for storage service - these methods are now in StorageService directly