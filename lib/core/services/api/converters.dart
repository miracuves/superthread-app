import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json * 1000);
    }
    if (json is String) {
      return DateTime.tryParse(json);
    }
    return null;
  }

  @override
  dynamic toJson(DateTime? object) {
    return object?.millisecondsSinceEpoch != null 
        ? object!.millisecondsSinceEpoch ~/ 1000 
        : null;
  }
}
class SafeStringConverter implements JsonConverter<String?, dynamic> {
  const SafeStringConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    return json.toString();
  }

  @override
  dynamic toJson(String? object) => object;
}

class SafeIntConverter implements JsonConverter<int?, dynamic> {
  const SafeIntConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is String) return int.tryParse(json);
    if (json is double) return json.toInt();
    return null;
  }

  @override
  dynamic toJson(int? object) => object;
}

class SafeStringListConverter implements JsonConverter<List<String>?, dynamic> {
  const SafeStringListConverter();

  @override
  List<String>? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is List) {
      return json.map((e) => e.toString()).toList();
    }
    // If it's a single item instead of a list, wrap it
    return [json.toString()];
  }

  @override
  dynamic toJson(List<String>? object) => object;
}
