import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/services/api/converters.dart';

part 'page.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Page extends Equatable {
  @SafeStringConverter()
  final String id;
  @SafeStringConverter()
  final String title;
  @SafeStringConverter()
  final String? content;
  @SafeStringConverter()
  final String? teamId;
  @SafeStringConverter()
  final String? projectId;
  final bool? isArchived;
  final bool? isPinned;
  @SafeStringListConverter()
  final List<String>? tags;
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime createdAt;
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;

  const Page({
    required this.id,
    required this.title,
    this.content,
    this.teamId,
    this.projectId,
    this.isArchived,
    this.isPinned,
    this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);

  Map<String, dynamic> toJson() => _$PageToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        teamId,
        projectId,
        isArchived,
        isPinned,
        tags,
        createdAt,
        updatedAt,
      ];
}

