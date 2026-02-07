import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_epic_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateEpicRequest extends Equatable {
  final String? title;
  final String? content;
  final String? listId;

  const UpdateEpicRequest({
    this.title,
    this.content,
    this.listId,
  });

  factory UpdateEpicRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateEpicRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateEpicRequestToJson(this);

  @override
  List<Object?> get props => [title, content, listId];
}
