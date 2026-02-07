# Project Structure

Directory and file organization for the Superthread Flutter app.

## Root Directory

```
superthread_app/
├── lib/                     # Source code
├── test/                    # Tests
├── android/                 # Android native code
├── ios/                     # iOS native code
├── web/                     # Web support
├── macos/                   # macOS support
├── wiki/                    # Documentation
├── .gitignore
├── pubspec.yaml             # Dependencies
└── README.md
```

## lib/ Directory Structure

### Core (lib/core/)

Shared utilities and configurations:

```
core/
├── constants/
│   ├── api_constants.dart      # API endpoints and URLs
│   └── app_constants.dart      # App-wide constants
│
├── themes/
│   ├── app_theme.dart          # App theming
│   ├── app_colors.dart         # Color definitions
│   └── app_text_styles.dart    # Typography styles
│
├── services/
│   ├── api/
│   │   ├── api_service.dart    # Retrofit API client
│   │   └── api_models.dart     # API request/response models
│   ├── storage/
│   │   └── storage_service.dart # Local storage service
│   ├── websocket/
│   │   └── websocket_service.dart # WebSocket client
│   ├── notifications/
│   │   └── superthread_notification_service.dart
│   └── service_locator.dart    # Dependency injection setup
│
├── router/
│   └── app_router.dart         # Navigation routes
│
├── utils/
│   ├── date_utils.dart         # Date formatting
│   └── string_utils.dart       # String helpers
│
└── errors/
    └── exceptions.dart         # Custom exceptions
```

### Data Layer (lib/data/)

Models and data sources:

```
data/
├── models/
│   ├── card.dart              # Card model
│   ├── board.dart             # Board model
│   ├── note.dart              # Note model
│   ├── page.dart              # Page model
│   ├── user.dart              # User model
│   ├── epic.dart              # Project/Epic model
│   ├── search_result.dart     # Search results
│   ├── notification_model.dart # Notification model
│   ├── external_link.dart     # NEW: External links
│   ├── card_hint.dart         # NEW: Card hints
│   ├── cover_image.dart       # NEW: Cover images
│   ├── public_settings.dart   # Board public settings
│   ├── webhook_notification.dart
│   ├── board_form.dart        # Form models
│   └── vcs_mapping.dart       # VCS integration
│
└── repositories/
    └── (repository implementations)
```

### Presentation Layer (lib/presentation/)

UI and state management:

```
presentation/
├── bloc/                     # State management
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   ├── cards/
│   │   ├── card_bloc.dart
│   │   ├── card_event.dart
│   │   └── card_state.dart
│   ├── boards/
│   ├── notes/
│   ├── pages/
│   ├── search/
│   ├── epics/
│   ├── sprint/
│   └── theme/
│
├── pages/                    # Screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── splash_screen.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── home_screen.dart
│   │   ├── cards_screen.dart
│   │   ├── notes_screen.dart
│   │   ├── pages_screen.dart
│   │   ├── projects_screen.dart
│   │   ├── search_screen.dart
│   │   └── profile_screen.dart
│   ├── card_detail_screen.dart
│   ├── kanban_board_screen.dart
│   ├── kanban/
│   │   └── kanban_board_screen.dart
│   ├── note_editor_screen.dart
│   ├── page_editor_screen.dart
│   ├── project_detail_screen.dart
│   ├── settings_screen.dart
│   └── notifications/
│       ├── notification_history_screen.dart
│       └── notifications_settings_screen.dart
│
└── widgets/                  # Reusable widgets
    ├── cards/
    │   ├── external_link_widget.dart      # NEW
    │   ├── card_hint_widget.dart          # NEW
    │   ├── cover_image_widget.dart        # NEW
    │   └── estimate_widget.dart           # NEW
    ├── comments/
    │   └── threaded_comment_widget.dart   # NEW
    ├── custom_button.dart
    ├── custom_text_field.dart
    ├── kanban_board.dart
    ├── kanban_column.dart
    ├── loading_widget.dart
    └── error_widget.dart
```

## File Naming Conventions

### Screens
- Pattern: `[name]_screen.dart`
- Examples: `login_screen.dart`, `card_detail_screen.dart`

### BLoCs
- Pattern: `[feature]_bloc.dart`
- Examples: `auth_bloc.dart`, `card_bloc.dart`

### Models
- Pattern: `[name].dart` (snake_case)
- Examples: `card.dart`, `external_link.dart`

### Widgets
- Pattern: `[name]_widget.dart` or `[name].dart`
- Examples: `custom_button.dart`, `external_link_widget.dart`

## Import Conventions

### File Header

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import '../../core/constants/api_constants.dart';
import '../../core/themes/app_colors.dart';

// Data layer imports
import '../../data/models/card.dart';

// Presentation layer imports
import '../bloc/cards/card_bloc.dart';
import '../widgets/custom_button.dart';
```

### Relative Imports

Use relative imports for files within the same layer:

```dart
import '../bloc/auth/auth_bloc.dart';
import '../widgets/custom_button.dart';
```

### Absolute Imports

Use absolute imports for cross-layer imports:

```dart
import '../../core/services/api/api_service.dart';
import '../../data/models/card.dart';
```

## Code Organization Best Practices

1. **One class per file** - Keep files focused
2. **Barrel exports** - Use `export` in index files
3. **Feature-based** - Group by feature, not type
4. **Shared widgets** - Keep reusable widgets separate
5. **Constants** - Centralize all constants

## File Size Guidelines

| File Type | Max Lines | Notes |
|-----------|-----------|-------|
| Screens | 500-800 | Split if larger |
| BLoCs | 300-500 | Split event/state |
| Models | 200-400 | Use composition |
| Widgets | 200-300 | Keep focused |

## Generated Files

### JSON Serialization

All `.g.dart` files are auto-generated:

```
data/models/
├── card.dart
├── card.g.dart              # Generated
├── external_link.dart
├── external_link.g.dart     # Generated
```

### API Client

```
core/services/api/
├── api_service.dart
├── api_service.g.dart       # Generated
├── api_models.dart
└── api_models.g.dart        # Generated
```

**Do not edit `.g.dart` files directly!**

---

*See [Architecture](Architecture) for design patterns.*
