# Data Models

Complete reference for all data models in the Superthread Flutter app.

## Model Overview

All models support:
- JSON serialization/deserialization
- Equatable for comparison
- Immutable with copyWith methods
- Null-safe fields

## Core Models

### Card Model

**File:** lib/data/models/card.dart

Key fields:
- id, title, description
- boardId, listId, teamId
- status, tags, assignedTo
- comments, attachments
- externalLinks (NEW)
- hints (NEW)
- coverImage (NEW)
- estimate (NEW)

### User Model

**File:** lib/data/models/user.dart

Key fields:
- id, email, displayName
- avatarUrl
- timezoneId (NEW)
- locale (NEW)
- jobDescription (NEW)

### Board Model

**File:** lib/data/models/board.dart

Key fields:
- id, title, description
- teamId, projectId
- isPublic
- publicSettings (NEW)
- webhookNotifications (NEW)
- forms (NEW)
- vcsMapping (NEW)

## New Models

### ExternalLink

**File:** lib/data/models/external_link.dart

```dart
class ExternalLink {
  final String type;
  final GitHubPullRequest? githubPullRequest;
  final GitLabMergeRequest? gitlabMergeRequest;
  final GenericLink? generic;
}
```

Types:
- github_pull_request
- gitlab_merge_request
- generic

### CardHint

**File:** lib/data/models/card_hint.dart

```dart
class CardHint {
  final String type;  // 'tag' or 'relation'
  final HintTag? tag;
  final HintRelation? relation;
}
```

### CoverImage

**File:** lib/data/models/cover_image.dart

```dart
class CoverImage {
  final String type;  // 'image', 'gradient', 'color', 'emoji'
  final String? src;
  final String? color;
  final String? emoji;
  final int? positionY;
}
```

## Supporting Models

- PublicSettings
- WebhookNotification
- FormModel
- VCSMapping
- Comment
- Attachment
- ChecklistItem
- Notification

## Code Generation

All models use json_serializable:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

See [API Documentation](API-Documentation) for endpoint usage.
