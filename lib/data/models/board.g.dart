// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Board _$BoardFromJson(Map<String, dynamic> json) => Board(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      teamId: json['team_id'] as String?,
      projectId: json['project_id'] as String?,
      members:
          (json['members'] as List<dynamic>?)?.map((e) => e as String).toList(),
      ownerId: json['owner_id'] as String?,
      isPublic: json['is_public'] as bool?,
      publicSettings: json['public_settings'] == null
          ? null
          : PublicSettings.fromJson(
              json['public_settings'] as Map<String, dynamic>),
      webhookNotifications: (json['webhook_notifications'] as List<dynamic>?)
          ?.map((e) => WebhookNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      forms: (json['forms'] as List<dynamic>?)
          ?.map((e) => FormModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      vcsMapping: json['vcs_mapping'] == null
          ? null
          : VCSMapping.fromJson(json['vcs_mapping'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BoardToJson(Board instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'team_id': instance.teamId,
      'project_id': instance.projectId,
      'members': instance.members,
      'owner_id': instance.ownerId,
      'is_public': instance.isPublic,
      'public_settings': instance.publicSettings?.toJson(),
      'webhook_notifications':
          instance.webhookNotifications?.map((e) => e.toJson()).toList(),
      'forms': instance.forms?.map((e) => e.toJson()).toList(),
      'vcs_mapping': instance.vcsMapping?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
