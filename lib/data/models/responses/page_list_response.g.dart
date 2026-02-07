// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageListResponse _$PageListResponseFromJson(Map<String, dynamic> json) =>
    PageListResponse(
      count: (json['count'] as num).toInt(),
      cursor: json['cursor'] as String?,
      pages: (json['pages'] as List<dynamic>)
          .map((e) => Page.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PageListResponseToJson(PageListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'cursor': instance.cursor,
      'pages': instance.pages,
    };
