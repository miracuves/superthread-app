// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_reaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentReactionRequest _$CommentReactionRequestFromJson(
        Map<String, dynamic> json) =>
    CommentReactionRequest(
      reaction: json['reaction'] as String,
      toggle: json['toggle'] as bool? ?? true,
    );

Map<String, dynamic> _$CommentReactionRequestToJson(
        CommentReactionRequest instance) =>
    <String, dynamic>{
      'reaction': instance.reaction,
      'toggle': instance.toggle,
    };
