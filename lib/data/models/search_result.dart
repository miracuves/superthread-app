import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final String id;
  final String type;
  final String title;
  final String? description;
  final String? projectId;
  final String? projectName;
  final String? assignedTo;
  final String? assignedToName;
  final List<String>? tags;
  final String? status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.projectId,
    this.projectName,
    this.assignedTo,
    this.assignedToName,
    this.tags,
    this.status,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.metadata,
  });

  SearchResult copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? projectId,
    String? projectName,
    String? assignedTo,
    String? assignedToName,
    List<String>? tags,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return SearchResult(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      projectId: json['project_id'] as String?,
      projectName: json['project_name'] as String?,
      assignedTo: json['assigned_to'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      status: json['status'] as String?,
      createdAt: json['created_at'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : (json['updated_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] * 1000)
              : DateTime.parse(json['updated_at'] as String)),
      imageUrl: json['image_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'project_id': projectId,
      'project_name': projectName,
      'assigned_to': assignedTo,
      'assigned_to_name': assignedToName,
      'tags': tags,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt?.millisecondsSinceEpoch != null ? updatedAt!.millisecondsSinceEpoch ~/ 1000 : null,
      'image_url': imageUrl,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        projectId,
        projectName,
        assignedTo,
        assignedToName,
        tags,
        status,
        createdAt,
        updatedAt,
        imageUrl,
        metadata,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ title.hashCode;
}

class SearchResponse {
  final List<SearchResult> results;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const SearchResponse({
    required this.results,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>?)
            ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SearchResponse(
      results: results,
      total: json['total'] as int? ?? results.length,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'has_more': hasMore,
    };
  }
}