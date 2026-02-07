import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/services/api/converters.dart';
import 'board.dart';

part 'epic.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Epic extends Equatable {
  @SafeStringConverter()
  final String id;
  @SafeStringConverter()
  final String title;
  @SafeStringConverter()
  final String? content;
  @SafeStringConverter()
  final String? listId; // Reference to list
  final bool archived;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime? createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;
  final List<Board>? boards;

  const Epic({
    required this.id,
    required this.title,
    this.content,
    this.listId,
    this.archived = false,
    this.createdAt,
    this.updatedAt,
    this.boards,
  });

  factory Epic.fromJson(Map<String, dynamic> json) {
    final converter = const SafeStringConverter();
    final timeConverter = const TimestampConverter();
    return Epic(
      id: converter.fromJson(json['id']) ?? '',
      title: converter.fromJson(json['title'] ?? json['name']) ?? '',
      content: converter.fromJson(json['content'] ?? json['description']),
      listId: converter.fromJson(json['list_id']),
      archived: json['archived'] as bool? ?? false,
      createdAt: timeConverter.fromJson(json['time_created'] ?? json['created_at']),
      updatedAt: timeConverter.fromJson(json['time_updated'] ?? json['updated_at']),
      boards: (json['boards'] as List?)?.map((e) {
        final board = Board.fromJson(e as Map<String, dynamic>);
        // Propagate teamId if missing in board JSON
        if (board.teamId.isEmpty) {
          final parentTeamId = converter.fromJson(json['team_id']) ?? '';
          return board.copyWith(teamId: parentTeamId);
        }
        return board;
      }).toList(),
    );
  }
  Map<String, dynamic> toJson() => _$EpicToJson(this);

  @override
  List<Object?> get props => [id, title, content, listId, archived, createdAt, updatedAt, boards];

  Epic copyWith({
    String? id,
    String? title,
    String? content,
    String? listId,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Board>? boards,
  }) {
    return Epic(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      listId: listId ?? this.listId,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      boards: boards ?? this.boards,
    );
  }
}
