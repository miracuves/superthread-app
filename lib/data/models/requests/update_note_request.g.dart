// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_note_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateNoteRequest _$UpdateNoteRequestFromJson(Map<String, dynamic> json) =>
    UpdateNoteRequest(
      title: json['title'] as String?,
      content: json['content'] as String?,
      isArchived: json['is_archived'] as bool?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UpdateNoteRequestToJson(UpdateNoteRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'is_archived': instance.isArchived,
      'tags': instance.tags,
    };
