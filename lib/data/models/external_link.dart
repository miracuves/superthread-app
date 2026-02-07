import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/services/api/converters.dart';

part 'external_link.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class ExternalLink extends Equatable {
  @SafeStringConverter()
  final String type;
  final GitHubPullRequest? githubPullRequest;
  final GenericLink? generic;

  const ExternalLink({
    required this.type,
    this.githubPullRequest,
    this.generic,
  });

  factory ExternalLink.fromJson(Map<String, dynamic> json) =>
      _$ExternalLinkFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalLinkToJson(this);

  @override
  List<Object?> get props => [type, githubPullRequest, generic];
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class GitHubPullRequest extends Equatable {
  @SafeIntConverter()
  final int id;
  @SafeIntConverter()
  final int number;
  @SafeStringConverter()
  final String state;
  @SafeStringConverter()
  final String title;
  @SafeStringConverter()
  final String? body;
  @SafeStringConverter()
  final String? htmlUrl;
  
  @JsonKey(name: 'time_created')
  @TimestampConverter()
  final DateTime? createdAt;
  
  @JsonKey(name: 'time_updated')
  @TimestampConverter()
  final DateTime? updatedAt;
  
  @JsonKey(name: 'time_closed')
  @TimestampConverter()
  final DateTime? closedAt;
  
  @JsonKey(name: 'time_merged')
  @TimestampConverter()
  final DateTime? mergedAt;
  
  final GitHubBranch? head;
  final GitHubBranch? base;
  final bool? draft;
  final bool? merged;

  const GitHubPullRequest({
    required this.id,
    required this.number,
    required this.state,
    required this.title,
    this.body,
    this.htmlUrl,
    this.createdAt,
    this.updatedAt,
    this.closedAt,
    this.mergedAt,
    this.head,
    this.base,
    this.draft,
    this.merged,
  });

  factory GitHubPullRequest.fromJson(Map<String, dynamic> json) =>
      _$GitHubPullRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubPullRequestToJson(this);

  @override
  List<Object?> get props => [
        id, number, state, title, body, htmlUrl,
        createdAt, updatedAt, closedAt, mergedAt,
        head, base, draft, merged,
      ];
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class GitHubBranch extends Equatable {
  @SafeStringConverter()
  final String label;
  @SafeStringConverter()
  final String ref;

  const GitHubBranch({
    required this.label,
    required this.ref,
  });

  factory GitHubBranch.fromJson(Map<String, dynamic> json) =>
      _$GitHubBranchFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubBranchToJson(this);

  @override
  List<Object?> get props => [label, ref];
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  includeIfNull: false,
)
class GenericLink extends Equatable {
  @SafeStringConverter()
  final String url;
  @SafeStringConverter()
  final String id;
  @SafeStringConverter()
  final String? displayText;
  
  @JsonKey(name: 'time_added')
  @TimestampConverter()
  final DateTime? addedAt;

  const GenericLink({
    required this.url,
    required this.id,
    this.displayText,
    this.addedAt,
  });

  factory GenericLink.fromJson(Map<String, dynamic> json) =>
      _$GenericLinkFromJson(json);

  Map<String, dynamic> toJson() => _$GenericLinkToJson(this);

  @override
  List<Object?> get props => [url, id, displayText, addedAt];
}

