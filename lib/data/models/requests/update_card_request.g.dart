// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_card_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCardRequest _$UpdateCardRequestFromJson(Map<String, dynamic> json) =>
    UpdateCardRequest(
      title: json['title'] as String?,
      content: json['content'] as String?,
      listId: json['list_id'] as String?,
      ownerId: json['owner_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: json['status'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      start_date: (json['start_date'] as num?)?.toInt(),
      due_date: (json['due_date'] as num?)?.toInt(),
      project_id: json['project_id'] as String?,
      epic_id: json['epic_id'] as String?,
      archived: json['archived'] as bool?,
      icon: json['icon'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateCardRequestToJson(UpdateCardRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'list_id': instance.listId,
      'owner_id': instance.ownerId,
      'assigned_to': instance.assignedTo,
      'tags': instance.tags,
      'status': instance.status,
      'priority': instance.priority,
      'start_date': instance.start_date,
      'due_date': instance.due_date,
      'project_id': instance.project_id,
      'epic_id': instance.epic_id,
      'archived': instance.archived,
      'icon': instance.icon,
    };
