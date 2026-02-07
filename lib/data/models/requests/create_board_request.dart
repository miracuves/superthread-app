import 'package:json_annotation/json_annotation.dart';

part 'create_board_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateBoardRequest {
  final String name;
  final String? description;
  final String teamId;
  final String? coverImageUrl;

  const CreateBoardRequest({
    required this.name,
    this.description,
    required this.teamId,
    this.coverImageUrl,
  });

  factory CreateBoardRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBoardRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBoardRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateBoardRequest {
  final String? name;
  final String? description;
  final String? coverImageUrl;
  final bool? isArchived;

  const UpdateBoardRequest({
    this.name,
    this.description,
    this.coverImageUrl,
    this.isArchived,
  });

  factory UpdateBoardRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBoardRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBoardRequestToJson(this);
}

