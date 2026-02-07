import 'package:json_annotation/json_annotation.dart';
import '../page.dart';

part 'page_response.g.dart';

@JsonSerializable()
class PageResponse {
  final Page page;

  PageResponse({required this.page});

  factory PageResponse.fromJson(Map<String, dynamic> json) =>
      _$PageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PageResponseToJson(this);
}

