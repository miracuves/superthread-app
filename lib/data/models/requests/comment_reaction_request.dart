import 'package:json_annotation/json_annotation.dart';

part 'comment_reaction_request.g.dart';

@JsonSerializable()
class CommentReactionRequest {
  final String reaction;
  final bool toggle;

  CommentReactionRequest({required this.reaction, this.toggle = true});

  factory CommentReactionRequest.fromJson(Map<String, dynamic> json) =>
      _$CommentReactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CommentReactionRequestToJson(this);
}
