// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_comment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCommentRequest _$CreateCommentRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCommentRequest(
      content: json['content'] as String,
      cardId: json['card_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      schema: (json['schema'] as num?)?.toInt() ?? 1,
      pageId: json['page_id'] as String?,
      context: json['context'] as String?,
    );

Map<String, dynamic> _$CreateCommentRequestToJson(
        CreateCommentRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
      'card_id': instance.cardId,
      'parent_comment_id': instance.parentCommentId,
      'schema': instance.schema,
      'page_id': instance.pageId,
      'context': instance.context,
    };
