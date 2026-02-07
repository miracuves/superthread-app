// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_epic_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateEpicRequest _$CreateEpicRequestFromJson(Map<String, dynamic> json) =>
    CreateEpicRequest(
      title: json['title'] as String,
      content: json['content'] as String?,
      listId: json['list_id'] as String?,
    );

Map<String, dynamic> _$CreateEpicRequestToJson(CreateEpicRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'list_id': instance.listId,
    };
