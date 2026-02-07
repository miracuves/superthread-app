// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_epic_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateEpicRequest _$UpdateEpicRequestFromJson(Map<String, dynamic> json) =>
    UpdateEpicRequest(
      title: json['title'] as String?,
      content: json['content'] as String?,
      listId: json['list_id'] as String?,
    );

Map<String, dynamic> _$UpdateEpicRequestToJson(UpdateEpicRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'list_id': instance.listId,
    };
