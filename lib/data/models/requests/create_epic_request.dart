import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_epic_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateEpicRequest extends Equatable {
  final String title;
  final String? content;
  final String? listId;

  const CreateEpicRequest({
    required this.title,
    this.content,
    this.listId,
  });

  factory CreateEpicRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEpicRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateEpicRequestToJson(this);

  @override
  List<Object?> get props => [title, content, listId];
}
