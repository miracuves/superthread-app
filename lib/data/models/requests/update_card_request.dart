import 'package:json_annotation/json_annotation.dart';

part 'update_card_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateCardRequest {
  final String? title;
  final String? content;
  final String? listId;
  final String? ownerId;
  final String? assignedTo;
  final List<String>? tags;
  final String? status;
  final int? priority;
  final int? start_date;
  final int? due_date;
  final String? project_id;
  final String? epic_id;
  final bool? archived;
  final Map<String, dynamic>? icon;

  const UpdateCardRequest({
    this.title,
    this.content,
    this.listId,
    this.ownerId,
    this.assignedTo,
    this.tags,
    this.status,
    this.priority,
    this.start_date,
    this.due_date,
    this.project_id,
    this.epic_id,
    this.archived,
    this.icon,
  });

  factory UpdateCardRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCardRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCardRequestToJson(this);
}
