import 'package:json_annotation/json_annotation.dart';

part 'create_comment_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateCommentRequest {
  final String content;
  final String cardId;
  final String? parentCommentId;
  final int? schema;
  final String? pageId;
  final String? context;

  CreateCommentRequest({
    required this.content,
    required this.cardId,
    this.parentCommentId,
    this.schema = 1,
    this.pageId,
    this.context,
  });

  factory CreateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCommentRequestToJson(this);
}