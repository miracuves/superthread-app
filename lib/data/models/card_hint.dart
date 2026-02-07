import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/services/api/converters.dart';

part 'card_hint.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class CardHint extends Equatable {
  @SafeStringConverter()
  final String type;
  final HintTag? tag;
  final HintRelation? relation;

  const CardHint({
    required this.type,
    this.tag,
    this.relation,
  });

  factory CardHint.fromJson(Map<String, dynamic> json) =>
      _$CardHintFromJson(json);

  Map<String, dynamic> toJson() => _$CardHintToJson(this);

  @override
  List<Object?> get props => [type, tag, relation];
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class HintTag extends Equatable {
  @SafeStringConverter()
  final String name;

  const HintTag({required this.name});

  factory HintTag.fromJson(Map<String, dynamic> json) =>
      _$HintTagFromJson(json);

  Map<String, dynamic> toJson() => _$HintTagToJson(this);

  @override
  List<Object?> get props => [name];
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class HintRelation extends Equatable {
  final RelatedCard? card;
  final double? similarity;

  const HintRelation({this.card, this.similarity});

  factory HintRelation.fromJson(Map<String, dynamic> json) =>
      _$HintRelationFromJson(json);

  Map<String, dynamic> toJson() => _$HintRelationToJson(this);

  @override
  List<Object?> get props => [card, similarity];
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class RelatedCard extends Equatable {
  @SafeStringConverter()
  final String title;
  @SafeStringConverter()
  @JsonKey(name: 'card_id')
  final String cardId;
  @SafeStringConverter()
  @JsonKey(name: 'user_id')
  final String? userId;
  @SafeStringConverter()
  @JsonKey(name: 'project_id')
  final String? projectId;
  @SafeStringConverter()
  @JsonKey(name: 'board_id')
  final String? boardId;
  @SafeStringConverter()
  @JsonKey(name: 'board_title')
  final String? boardTitle;
  @SafeStringConverter()
  @JsonKey(name: 'list_id')
  final String? listId;
  @SafeStringConverter()
  @JsonKey(name: 'list_title')
  final String? listTitle;
  @SafeStringConverter()
  @JsonKey(name: 'list_color')
  final String? listColor;
  @SafeStringConverter()
  final String? status;

  const RelatedCard({
    required this.title,
    required this.cardId,
    this.userId,
    this.projectId,
    this.boardId,
    this.boardTitle,
    this.listId,
    this.listTitle,
    this.listColor,
    this.status,
  });

  factory RelatedCard.fromJson(Map<String, dynamic> json) =>
      _$RelatedCardFromJson(json);

  Map<String, dynamic> toJson() => _$RelatedCardToJson(this);

  @override
  List<Object?> get props => [
        title, cardId, userId, projectId, boardId,
        boardTitle, listId, listTitle, listColor, status,
      ];
}

