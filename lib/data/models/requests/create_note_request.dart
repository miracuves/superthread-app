import 'package:json_annotation/json_annotation.dart';

part 'create_note_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateNoteRequest {
  final String title;
  final String content;
  final String? teamId;
  final String? boardId;
  final String? cardId;
  final List<String>? tags;

  CreateNoteRequest({
    required this.title,
    required this.content,
    this.teamId,
    this.boardId,
    this.cardId,
    this.tags,
  });

  factory CreateNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateNoteRequestFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'user_notes': content,
      if (teamId != null) 'team_id': teamId,
      if (boardId != null) 'board_id': boardId,
      if (cardId != null) 'card_id': cardId,
      if (tags != null) 'tags': tags,
    };
  }
}
