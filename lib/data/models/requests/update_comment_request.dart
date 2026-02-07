import 'package:json_annotation/json_annotation.dart';

part 'update_comment_request.g.dart';

@JsonSerializable()
class UpdateCommentRequest {
  final String content;

  UpdateCommentRequest({required this.content});

  factory UpdateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCommentRequestToJson(this);
}
