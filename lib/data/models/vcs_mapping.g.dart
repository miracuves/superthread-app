// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vcs_mapping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VCSMapping _$VCSMappingFromJson(Map<String, dynamic> json) => VCSMapping(
      provider: json['provider'] as String?,
      repository: json['repository'] as String?,
      branch: json['branch'] as String?,
    );

Map<String, dynamic> _$VCSMappingToJson(VCSMapping instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'repository': instance.repository,
      'branch': instance.branch,
    };
