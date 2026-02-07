import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'public_settings.g.dart';
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class PublicSettings extends Equatable {
  final bool? allowComments;
  final bool? allowAttachments;
  final String? accessLevel;
  const PublicSettings({this.allowComments, this.allowAttachments, this.accessLevel});
  factory PublicSettings.fromJson(Map<String, dynamic> json) => _$PublicSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$PublicSettingsToJson(this);
  @override
  List<Object?> get props => [allowComments, allowAttachments, accessLevel];
}
