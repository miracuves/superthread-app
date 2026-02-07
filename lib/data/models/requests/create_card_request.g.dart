// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_card_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCardRequest _$CreateCardRequestFromJson(Map<String, dynamic> json) =>
    CreateCardRequest(
      title: json['title'] as String,
      content: json['content'] as String?,
      boardId: json['board_id'] as String?,
      listId: json['list_id'] as String?,
      sprintId: json['sprint_id'] as String?,
      ownerId: json['owner_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: json['status'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      start_date: (json['start_date'] as num?)?.toInt(),
      due_date: (json['due_date'] as num?)?.toInt(),
      project_id: json['project_id'] as String?,
      epic_id: json['epic_id'] as String?,
      icon: json['icon'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreateCardRequestToJson(CreateCardRequest instance) {
  final val = <String, dynamic>{
    'title': instance.title,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('content', instance.content);
  writeNotNull('board_id', instance.boardId);
  writeNotNull('list_id', instance.listId);
  writeNotNull('sprint_id', instance.sprintId);
  writeNotNull('owner_id', instance.ownerId);
  writeNotNull('assigned_to', instance.assignedTo);
  writeNotNull('tags', instance.tags);
  writeNotNull('status', instance.status);
  writeNotNull('priority', instance.priority);
  writeNotNull('start_date', instance.start_date);
  writeNotNull('due_date', instance.due_date);
  writeNotNull('project_id', instance.project_id);
  writeNotNull('epic_id', instance.epic_id);
  writeNotNull('icon', instance.icon);
  return val;
}
