// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicSettings _$PublicSettingsFromJson(Map<String, dynamic> json) =>
    PublicSettings(
      allowComments: json['allow_comments'] as bool?,
      allowAttachments: json['allow_attachments'] as bool?,
      accessLevel: json['access_level'] as String?,
    );

Map<String, dynamic> _$PublicSettingsToJson(PublicSettings instance) =>
    <String, dynamic>{
      'allow_comments': instance.allowComments,
      'allow_attachments': instance.allowAttachments,
      'access_level': instance.accessLevel,
    };
