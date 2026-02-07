// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_hint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardHint _$CardHintFromJson(Map<String, dynamic> json) => CardHint(
      type: json['type'] as String,
      tag: json['tag'] == null
          ? null
          : HintTag.fromJson(json['tag'] as Map<String, dynamic>),
      relation: json['relation'] == null
          ? null
          : HintRelation.fromJson(json['relation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CardHintToJson(CardHint instance) {
  final val = <String, dynamic>{
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('tag', instance.tag?.toJson());
  writeNotNull('relation', instance.relation?.toJson());
  return val;
}

HintTag _$HintTagFromJson(Map<String, dynamic> json) => HintTag(
      name: json['name'] as String,
    );

Map<String, dynamic> _$HintTagToJson(HintTag instance) => <String, dynamic>{
      'name': instance.name,
    };

HintRelation _$HintRelationFromJson(Map<String, dynamic> json) => HintRelation(
      card: json['card'] == null
          ? null
          : RelatedCard.fromJson(json['card'] as Map<String, dynamic>),
      similarity: (json['similarity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HintRelationToJson(HintRelation instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('card', instance.card?.toJson());
  writeNotNull('similarity', instance.similarity);
  return val;
}

RelatedCard _$RelatedCardFromJson(Map<String, dynamic> json) => RelatedCard(
      title: json['title'] as String,
      cardId: json['card_id'] as String,
      userId: const SafeStringConverter().fromJson(json['user_id']),
      projectId: const SafeStringConverter().fromJson(json['project_id']),
      boardId: const SafeStringConverter().fromJson(json['board_id']),
      boardTitle: const SafeStringConverter().fromJson(json['board_title']),
      listId: const SafeStringConverter().fromJson(json['list_id']),
      listTitle: const SafeStringConverter().fromJson(json['list_title']),
      listColor: const SafeStringConverter().fromJson(json['list_color']),
      status: const SafeStringConverter().fromJson(json['status']),
    );

Map<String, dynamic> _$RelatedCardToJson(RelatedCard instance) {
  final val = <String, dynamic>{
    'title': instance.title,
    'card_id': instance.cardId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user_id', const SafeStringConverter().toJson(instance.userId));
  writeNotNull(
      'project_id', const SafeStringConverter().toJson(instance.projectId));
  writeNotNull(
      'board_id', const SafeStringConverter().toJson(instance.boardId));
  writeNotNull(
      'board_title', const SafeStringConverter().toJson(instance.boardTitle));
  writeNotNull('list_id', const SafeStringConverter().toJson(instance.listId));
  writeNotNull(
      'list_title', const SafeStringConverter().toJson(instance.listTitle));
  writeNotNull(
      'list_color', const SafeStringConverter().toJson(instance.listColor));
  writeNotNull('status', const SafeStringConverter().toJson(instance.status));
  return val;
}
