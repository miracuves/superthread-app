// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Page _$PageFromJson(Map<String, dynamic> json) => Page(
      id: json['id'] as String,
      title: json['title'] as String,
      content: const SafeStringConverter().fromJson(json['content']),
      teamId: const SafeStringConverter().fromJson(json['team_id']),
      projectId: const SafeStringConverter().fromJson(json['project_id']),
      isArchived: json['is_archived'] as bool?,
      isPinned: json['is_pinned'] as bool?,
      tags: const SafeStringListConverter().fromJson(json['tags']),
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
    );

Map<String, dynamic> _$PageToJson(Page instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': const SafeStringConverter().toJson(instance.content),
      'team_id': const SafeStringConverter().toJson(instance.teamId),
      'project_id': const SafeStringConverter().toJson(instance.projectId),
      'is_archived': instance.isArchived,
      'is_pinned': instance.isPinned,
      'tags': const SafeStringListConverter().toJson(instance.tags),
      'time_created': instance.createdAt.toIso8601String(),
      'time_updated': const TimestampConverter().toJson(instance.updatedAt),
    };
