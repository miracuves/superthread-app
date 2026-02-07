// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_page_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePageRequest _$UpdatePageRequestFromJson(Map<String, dynamic> json) =>
    UpdatePageRequest(
      title: json['title'] as String?,
      content: json['content'] as String?,
      projectId: json['projectId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isArchived: json['isArchived'] as bool?,
      isPinned: json['isPinned'] as bool?,
    );

Map<String, dynamic> _$UpdatePageRequestToJson(UpdatePageRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'projectId': instance.projectId,
      'tags': instance.tags,
      'isArchived': instance.isArchived,
      'isPinned': instance.isPinned,
    };
