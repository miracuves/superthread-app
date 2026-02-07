// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Board _$BoardFromJson(Map<String, dynamic> json) => Board(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      teamId: json['team_id'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      position: (json['position'] as num?)?.toInt(),
      isArchived: json['is_archived'] as bool? ?? false,
      lists: (json['lists'] as List<dynamic>?)
          ?.map((e) => BoardList.fromJson(e as Map<String, dynamic>))
          .toList(),
      epics: (json['epics'] as List<dynamic>?)
          ?.map((e) => Epic.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BoardToJson(Board instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'team_id': instance.teamId,
      'cover_image_url': instance.coverImageUrl,
      'position': instance.position,
      'is_archived': instance.isArchived,
      'lists': instance.lists,
      'epics': instance.epics,
      'time_created': instance.createdAt.toIso8601String(),
      'time_updated': const TimestampConverter().toJson(instance.updatedAt),
      'metadata': instance.metadata,
    };

BoardList _$BoardListFromJson(Map<String, dynamic> json) => BoardList(
      id: json['id'] as String,
      name: json['name'] as String,
      boardId: json['board_id'] as String,
      position: (json['position'] as num?)?.toInt(),
      cardIds: const SafeStringListConverter().fromJson(json['card_ids']),
      epics: (json['epics'] as List<dynamic>?)
          ?.map((e) => Epic.fromJson(e as Map<String, dynamic>))
          .toList(),
      cards: (json['cards'] as List<dynamic>?)
          ?.map((e) => Card.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['time_created'] as String),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
    );

Map<String, dynamic> _$BoardListToJson(BoardList instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'board_id': instance.boardId,
      'position': instance.position,
      'card_ids': const SafeStringListConverter().toJson(instance.cardIds),
      'epics': instance.epics,
      'cards': instance.cards,
      'time_created': instance.createdAt.toIso8601String(),
      'time_updated': const TimestampConverter().toJson(instance.updatedAt),
    };
