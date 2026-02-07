import 'package:json_annotation/json_annotation.dart';

part 'create_card_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateCardRequest {
  final String title;
  final String? content;
  final String? boardId;
  final String? listId;
  final String? sprintId;
  final String? ownerId;
  final String? assignedTo; // Keep for backward compatibility if needed, but API uses owner_id
  final List<String>? tags;
  final String? status;
  final int? priority;
  final int? start_date; // Unix timestamp
  final int? due_date; // Unix timestamp
  final String? project_id; // Space ID
  final String? epic_id; // Project ID
  final Map<String, dynamic>? icon;

  const CreateCardRequest({
    required this.title,
    this.content,
    this.boardId,
    this.listId,
    this.sprintId,
    this.ownerId,
    this.assignedTo,
    this.tags,
    this.status,
    this.priority,
    this.start_date,
    this.due_date,
    this.project_id,
    this.epic_id,
    this.icon,
  });

  factory CreateCardRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCardRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCardRequestToJson(this);
}
