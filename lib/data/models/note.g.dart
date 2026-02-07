// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      teamId: const SafeStringConverter().fromJson(json['team_id']),
      projectId: const SafeStringConverter().fromJson(json['project_id']),
      assignedTo: const SafeStringConverter().fromJson(json['assigned_to']),
      assignedToName:
          const SafeStringConverter().fromJson(json['assigned_to_name']),
      tags: const SafeStringListConverter().fromJson(json['tags']),
      status: const SafeStringConverter().fromJson(json['status']),
      isArchived: json['is_archived'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      attachments:
          const SafeStringListConverter().fromJson(json['attachments']),
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NoteToJson(Note instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'title': instance.title,
    'content': instance.content,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('team_id', const SafeStringConverter().toJson(instance.teamId));
  writeNotNull(
      'project_id', const SafeStringConverter().toJson(instance.projectId));
  writeNotNull(
      'assigned_to', const SafeStringConverter().toJson(instance.assignedTo));
  writeNotNull('assigned_to_name',
      const SafeStringConverter().toJson(instance.assignedToName));
  writeNotNull('tags', const SafeStringListConverter().toJson(instance.tags));
  writeNotNull('status', const SafeStringConverter().toJson(instance.status));
  val['is_archived'] = instance.isArchived;
  val['is_pinned'] = instance.isPinned;
  writeNotNull('attachments',
      const SafeStringListConverter().toJson(instance.attachments));
  val['time_created'] = instance.createdAt.toIso8601String();
  writeNotNull(
      'time_updated', const TimestampConverter().toJson(instance.updatedAt));
  writeNotNull('metadata', instance.metadata);
  return val;
}
