import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'board_form.g.dart';
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class FormModel extends Equatable {
  final String? id;
  final String? title;
  const FormModel({this.id, this.title});
  factory FormModel.fromJson(Map<String, dynamic> json) => _$FormModelFromJson(json);
  Map<String, dynamic> toJson() => _$FormModelToJson(this);
  @override
  List<Object?> get props => [id, title];
}
