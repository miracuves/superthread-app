import 'package:json_annotation/json_annotation.dart';

part 'update_page_request.g.dart';

@JsonSerializable()
class UpdatePageRequest {
  final String? title;
  final String? content;
  final String? projectId;
  final List<String>? tags;
  final bool? isArchived;
  final bool? isPinned;

  UpdatePageRequest({
    this.title,
    this.content,
    this.projectId,
    this.tags,
    this.isArchived,
    this.isPinned,
  });

  factory UpdatePageRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePageRequestToJson(this);
}

