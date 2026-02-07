// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_board_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBoardRequest _$CreateBoardRequestFromJson(Map<String, dynamic> json) =>
    CreateBoardRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      teamId: json['team_id'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
    );

Map<String, dynamic> _$CreateBoardRequestToJson(CreateBoardRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'team_id': instance.teamId,
      'cover_image_url': instance.coverImageUrl,
    };

UpdateBoardRequest _$UpdateBoardRequestFromJson(Map<String, dynamic> json) =>
    UpdateBoardRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      isArchived: json['is_archived'] as bool?,
    );

Map<String, dynamic> _$UpdateBoardRequestToJson(UpdateBoardRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'cover_image_url': instance.coverImageUrl,
      'is_archived': instance.isArchived,
    };
