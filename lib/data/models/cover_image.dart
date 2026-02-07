import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/services/api/converters.dart';

part 'cover_image.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class CoverImage extends Equatable {
  @SafeStringConverter()
  final String type;
  @SafeStringConverter()
  final String? src;
  @SafeStringConverter()
  final String? id;
  @SafeStringConverter()
  final String? blurhash;
  @SafeStringConverter()
  final String? color;
  @SafeStringConverter()
  final String? emoji;
  @SafeIntConverter()
  final int? positionY;
  @SafeStringConverter()
  final String? objectFit;

  const CoverImage({
    required this.type,
    this.src,
    this.id,
    this.blurhash,
    this.color,
    this.emoji,
    this.positionY,
    this.objectFit,
  });

  factory CoverImage.fromJson(Map<String, dynamic> json) =>
      _$CoverImageFromJson(json);

  Map<String, dynamic> toJson() => _$CoverImageToJson(this);

  @override
  List<Object?> get props => [
        type, src, id, blurhash, color, emoji, positionY, objectFit,
      ];
}

