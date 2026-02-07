import 'package:json_annotation/json_annotation.dart';

part 'update_note_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateNoteRequest {
  final String? title;
  final String? content;
  final bool? isArchived;
  final List<String>? tags;

  UpdateNoteRequest({
    this.title,
    this.content,
    this.isArchived,
    this.tags,
  });

  factory UpdateNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateNoteRequestFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (content != null) 'user_notes': content,
      if (isArchived != null) 'is_archived': isArchived,
      if (tags != null) 'tags': tags,
    };
  }
}
