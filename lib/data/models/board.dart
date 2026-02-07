import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/services/api/converters.dart';
import 'epic.dart';
import 'card.dart';

part 'board.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Board extends Equatable {
  @SafeStringConverter()
  final String id;
  final String name;
  final String? description;
  @SafeStringConverter()
  final String teamId;
  final String? coverImageUrl;
  final int? position;
  final bool isArchived;
  final List<BoardList>? lists;
  final List<Epic>? epics;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const Board({
    required this.id,
    required this.name,
    this.description,
    required this.teamId,
    this.coverImageUrl,
    this.position,
    this.isArchived = false,
    this.lists,
    this.epics,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final timeConverter = const TimestampConverter();
    
    // Some API responses use 'title' instead of 'name' for boards
    final name = strConverter.fromJson(json['name'] ?? json['title']) ?? 'Untitled Board';
    
    return Board(
      id: strConverter.fromJson(json['id']) ?? '',
      name: name,
      description: strConverter.fromJson(json['description']),
      teamId: strConverter.fromJson(json['team_id']) ?? '',
      coverImageUrl: strConverter.fromJson(json['cover_image_url']),
      position: json['position'] as int?,
      isArchived: json['is_archived'] as bool? ?? false,
      lists: (json['lists'] as List?)
          ?.map((e) => BoardList.fromJson(e as Map<String, dynamic>))
          .toList(),
      epics: (json['epics'] as List?)
          ?.map((e) => Epic.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: timeConverter.fromJson(json['time_created'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: timeConverter.fromJson(json['time_updated'] ?? json['updated_at']),
      metadata: (json['metadata'] is Map) ? Map<String, dynamic>.from(json['metadata'] as Map) : null,
    );
  }
  Map<String, dynamic> toJson() => _$BoardToJson(this);

  Board copyWith({
    String? id,
    String? name,
    String? description,
    String? teamId,
    String? coverImageUrl,
    int? position,
    bool? isArchived,
    List<BoardList>? lists,
    List<Epic>? epics,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teamId: teamId ?? this.teamId,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      position: position ?? this.position,
      isArchived: isArchived ?? this.isArchived,
      lists: lists ?? this.lists,
      epics: epics ?? this.epics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        teamId,
        coverImageUrl,
        position,
        isArchived,
        lists,
        epics,
        createdAt,
        updatedAt,
        metadata,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Board &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BoardList extends Equatable {
  @SafeStringConverter()
  final String id;
  final String name;
  @SafeStringConverter()
  final String boardId;
  final int? position;
  @SafeStringListConverter()
  final List<String>? cardIds;
  final List<Epic>? epics;
  final List<Card>? cards;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;

  const BoardList({
    required this.id,
    required this.name,
    required this.boardId,
    this.position,
    this.cardIds,
    this.epics,
    this.cards,
    required this.createdAt,
    this.updatedAt,
  });

  factory BoardList.fromJson(Map<String, dynamic> json) {
    final strConverter = const SafeStringConverter();
    final timeConverter = const TimestampConverter();
    return BoardList(
      id: strConverter.fromJson(json['id']) ?? '',
      name: strConverter.fromJson(json['name'] ?? json['title']) ?? 'Untitled List',
      boardId: strConverter.fromJson(json['board_id']) ?? '',
      position: json['position'] as int?,
      cardIds: (json['card_ids'] as List?)?.map((e) => e.toString()).toList(),
      epics: (json['epics'] as List?)
          ?.map((e) => Epic.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: timeConverter.fromJson(json['time_created'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: timeConverter.fromJson(json['time_updated'] ?? json['updated_at']),
      cards: (json['cards'] as List?)
          ?.map((e) => Card.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() => _$BoardListToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        boardId,
        position,
        cardIds,
        epics,
        cards,
        createdAt,
        updatedAt,
      ];
}