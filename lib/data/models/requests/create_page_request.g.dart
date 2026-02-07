// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_page_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePageRequest _$CreatePageRequestFromJson(Map<String, dynamic> json) =>
    CreatePageRequest(
      title: json['title'] as String,
      content: json['content'] as String?,
      projectId: json['projectId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isPinned: json['isPinned'] as bool?,
    );

Map<String, dynamic> _$CreatePageRequestToJson(CreatePageRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'projectId': instance.projectId,
      'tags': instance.tags,
      'isPinned': instance.isPinned,
    };
