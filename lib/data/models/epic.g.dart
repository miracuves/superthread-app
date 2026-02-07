// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Epic _$EpicFromJson(Map<String, dynamic> json) => Epic(
      id: json['id'] as String,
      title: json['title'] as String,
      content: const SafeStringConverter().fromJson(json['content']),
      listId: const SafeStringConverter().fromJson(json['list_id']),
      archived: json['archived'] as bool? ?? false,
      createdAt: const TimestampConverter().fromJson(json['time_created']),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      boards: (json['boards'] as List<dynamic>?)
          ?.map((e) => Board.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EpicToJson(Epic instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': const SafeStringConverter().toJson(instance.content),
      'list_id': const SafeStringConverter().toJson(instance.listId),
      'archived': instance.archived,
      'time_created': const TimestampConverter().toJson(instance.createdAt),
      'time_updated': const TimestampConverter().toJson(instance.updatedAt),
      'boards': instance.boards,
    };
