import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'vcs_mapping.g.dart';
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class VCSMapping extends Equatable {
  final String? provider;
  final String? repository;
  final String? branch;
  const VCSMapping({this.provider, this.repository, this.branch});
  factory VCSMapping.fromJson(Map<String, dynamic> json) => _$VCSMappingFromJson(json);
  Map<String, dynamic> toJson() => _$VCSMappingToJson(this);
  @override
  List<Object?> get props => [provider, repository, branch];
}
