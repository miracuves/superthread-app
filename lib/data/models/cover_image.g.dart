// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverImage _$CoverImageFromJson(Map<String, dynamic> json) => CoverImage(
      type: json['type'] as String,
      src: const SafeStringConverter().fromJson(json['src']),
      id: const SafeStringConverter().fromJson(json['id']),
      blurhash: const SafeStringConverter().fromJson(json['blurhash']),
      color: const SafeStringConverter().fromJson(json['color']),
      emoji: const SafeStringConverter().fromJson(json['emoji']),
      positionY: const SafeIntConverter().fromJson(json['position_y']),
      objectFit: const SafeStringConverter().fromJson(json['object_fit']),
    );

Map<String, dynamic> _$CoverImageToJson(CoverImage instance) {
  final val = <String, dynamic>{
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('src', const SafeStringConverter().toJson(instance.src));
  writeNotNull('id', const SafeStringConverter().toJson(instance.id));
  writeNotNull(
      'blurhash', const SafeStringConverter().toJson(instance.blurhash));
  writeNotNull('color', const SafeStringConverter().toJson(instance.color));
  writeNotNull('emoji', const SafeStringConverter().toJson(instance.emoji));
  writeNotNull(
      'position_y', const SafeIntConverter().toJson(instance.positionY));
  writeNotNull(
      'object_fit', const SafeStringConverter().toJson(instance.objectFit));
  return val;
}
