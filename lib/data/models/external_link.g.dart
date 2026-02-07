// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExternalLink _$ExternalLinkFromJson(Map<String, dynamic> json) => ExternalLink(
      type: json['type'] as String,
      githubPullRequest: json['github_pull_request'] == null
          ? null
          : GitHubPullRequest.fromJson(
              json['github_pull_request'] as Map<String, dynamic>),
      generic: json['generic'] == null
          ? null
          : GenericLink.fromJson(json['generic'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExternalLinkToJson(ExternalLink instance) {
  final val = <String, dynamic>{
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('github_pull_request', instance.githubPullRequest?.toJson());
  writeNotNull('generic', instance.generic?.toJson());
  return val;
}

GitHubPullRequest _$GitHubPullRequestFromJson(Map<String, dynamic> json) =>
    GitHubPullRequest(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      state: json['state'] as String,
      title: json['title'] as String,
      body: const SafeStringConverter().fromJson(json['body']),
      htmlUrl: const SafeStringConverter().fromJson(json['html_url']),
      createdAt: const TimestampConverter().fromJson(json['time_created']),
      updatedAt: const TimestampConverter().fromJson(json['time_updated']),
      closedAt: const TimestampConverter().fromJson(json['time_closed']),
      mergedAt: const TimestampConverter().fromJson(json['time_merged']),
      head: json['head'] == null
          ? null
          : GitHubBranch.fromJson(json['head'] as Map<String, dynamic>),
      base: json['base'] == null
          ? null
          : GitHubBranch.fromJson(json['base'] as Map<String, dynamic>),
      draft: json['draft'] as bool?,
      merged: json['merged'] as bool?,
    );

Map<String, dynamic> _$GitHubPullRequestToJson(GitHubPullRequest instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'number': instance.number,
    'state': instance.state,
    'title': instance.title,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('body', const SafeStringConverter().toJson(instance.body));
  writeNotNull(
      'html_url', const SafeStringConverter().toJson(instance.htmlUrl));
  writeNotNull(
      'time_created', const TimestampConverter().toJson(instance.createdAt));
  writeNotNull(
      'time_updated', const TimestampConverter().toJson(instance.updatedAt));
  writeNotNull(
      'time_closed', const TimestampConverter().toJson(instance.closedAt));
  writeNotNull(
      'time_merged', const TimestampConverter().toJson(instance.mergedAt));
  writeNotNull('head', instance.head?.toJson());
  writeNotNull('base', instance.base?.toJson());
  writeNotNull('draft', instance.draft);
  writeNotNull('merged', instance.merged);
  return val;
}

GitHubBranch _$GitHubBranchFromJson(Map<String, dynamic> json) => GitHubBranch(
      label: json['label'] as String,
      ref: json['ref'] as String,
    );

Map<String, dynamic> _$GitHubBranchToJson(GitHubBranch instance) =>
    <String, dynamic>{
      'label': instance.label,
      'ref': instance.ref,
    };

GenericLink _$GenericLinkFromJson(Map<String, dynamic> json) => GenericLink(
      url: json['url'] as String,
      id: json['id'] as String,
      displayText: const SafeStringConverter().fromJson(json['display_text']),
      addedAt: const TimestampConverter().fromJson(json['time_added']),
    );

Map<String, dynamic> _$GenericLinkToJson(GenericLink instance) {
  final val = <String, dynamic>{
    'url': instance.url,
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'display_text', const SafeStringConverter().toJson(instance.displayText));
  writeNotNull(
      'time_added', const TimestampConverter().toJson(instance.addedAt));
  return val;
}
