// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_note_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateNoteRequest _$CreateNoteRequestFromJson(Map<String, dynamic> json) =>
    CreateNoteRequest(
      title: json['title'] as String,
      content: json['content'] as String,
      teamId: json['team_id'] as String?,
      boardId: json['board_id'] as String?,
      cardId: json['card_id'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreateNoteRequestToJson(CreateNoteRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'team_id': instance.teamId,
      'board_id': instance.boardId,
      'card_id': instance.cardId,
      'tags': instance.tags,
    };
