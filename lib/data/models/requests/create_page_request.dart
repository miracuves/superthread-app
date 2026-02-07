import 'package:json_annotation/json_annotation.dart';

part 'create_page_request.g.dart';

@JsonSerializable()
class CreatePageRequest {
  final String title;
  final String? content;
  final String? projectId;
  final List<String>? tags;
  final bool? isPinned;

  CreatePageRequest({
    required this.title,
    this.content,
    this.projectId,
    this.tags,
    this.isPinned,
  });

  factory CreatePageRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePageRequestToJson(this);
}

