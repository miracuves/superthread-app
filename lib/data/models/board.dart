import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'public_settings.dart';
import 'webhook_notification.dart';
import 'board_form.dart';
import 'vcs_mapping.dart';

part 'board.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Board extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? teamId;
  final String? projectId;
  final List<String>? members;
  final String? ownerId;
  final bool? isPublic;
  final PublicSettings? publicSettings;
  final List<WebhookNotification>? webhookNotifications;
  final List<FormModel>? forms;
  final VCSMapping? vcsMapping;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Board({required this.id, required this.title, this.description, this.teamId, this.projectId, this.members, this.ownerId, this.isPublic, this.publicSettings, this.webhookNotifications, this.forms, this.vcsMapping, required this.createdAt, this.updatedAt});

  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);
  Map<String, dynamic> toJson() => _$BoardToJson(this);

  Board copyWith({String? id, String? title, String? description, String? teamId, String? projectId, List<String>? members, String? ownerId, bool? isPublic, PublicSettings? publicSettings, List<WebhookNotification>? webhookNotifications, List<FormModel>? forms, VCSMapping? vcsMapping, DateTime? createdAt, DateTime? updatedAt}) {
    return Board(id: id ?? this.id, title: title ?? this.title, description: description ?? this.description, teamId: teamId ?? this.teamId, projectId: projectId ?? this.projectId, members: members ?? this.members, ownerId: ownerId ?? this.ownerId, isPublic: isPublic ?? this.isPublic, publicSettings: publicSettings ?? this.publicSettings, webhookNotifications: webhookNotifications ?? this.webhookNotifications, forms: forms ?? this.forms, vcsMapping: vcsMapping ?? this.vcsMapping, createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt);
  }

  @override
  List<Object?> get props => [id, title, description, teamId, projectId, members, ownerId, isPublic, publicSettings, webhookNotifications, forms, vcsMapping, createdAt, updatedAt];
}
