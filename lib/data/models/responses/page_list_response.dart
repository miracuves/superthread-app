import 'package:json_annotation/json_annotation.dart';
import '../page.dart';

part 'page_list_response.g.dart';

@JsonSerializable()
class PageListResponse {
  final int count;
  final String? cursor;
  final List<Page> pages;

  PageListResponse({
    required this.count,
    this.cursor,
    required this.pages,
  });

  factory PageListResponse.fromJson(Map<String, dynamic> json) =>
      _$PageListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PageListResponseToJson(this);
}

