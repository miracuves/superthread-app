import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/services/api/converters.dart';

part 'note.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class Note extends Equatable {
  @SafeStringConverter()
  final String id;
  @SafeStringConverter()
  final String title;
  @SafeStringConverter()
  final String content;
  @SafeStringConverter()
  final String? teamId;
  @SafeStringConverter()
  final String? projectId;
  @SafeStringConverter()
  @JsonKey(name: 'assigned_to')
  final String? assignedTo;
  @SafeStringConverter()
  final String? assignedToName;
  @SafeStringListConverter()
  final List<String>? tags;
  @SafeStringConverter()
  final String? status;
  final bool isArchived;
  final bool isPinned;
  @SafeStringListConverter()
  final List<String>? attachments;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const Note({
    required this.id,
    required this.title,
    this.content = '',
    this.teamId,
    this.projectId,
    this.assignedTo,
    this.assignedToName,
    this.tags,
    this.status,
    this.isArchived = false,
    this.isPinned = false,
    this.attachments,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    final converter = const SafeStringConverter();
    return Note(
      id: converter.fromJson(json['id']) ?? '',
      title: converter.fromJson(json['title']) ?? '',
      content: converter.fromJson(json['user_notes'] ?? json['content']) ?? '',
      teamId: converter.fromJson(json['team_id']),
      projectId: converter.fromJson(json['project_id']),
      assignedTo: converter.fromJson(json['assigned_to']),
      assignedToName: converter.fromJson(json['assigned_to_name']),
      tags: const SafeStringListConverter().fromJson(json['tags']),
      status: converter.fromJson(json['status']),
      isArchived: json['is_archived'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      attachments: const SafeStringListConverter().fromJson(json['attachments']),
      createdAt: const TimestampConverter().fromJson(json['time_created']) ?? DateTime.now(),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      metadata: (json['metadata'] is Map) ? Map<String, dynamic>.from(json['metadata'] as Map) : null,
    );
  }

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? teamId,
    String? projectId,
    String? assignedTo,
    String? assignedToName,
    List<String>? tags,
    String? status,
    bool? isArchived,
    bool? isPinned,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      teamId: teamId ?? this.teamId,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    teamId,
    projectId,
    assignedTo,
    assignedToName,
    tags,
    status,
    isArchived,
    isPinned,
    attachments,
    createdAt,
    updatedAt,
    metadata,
  ];
}
