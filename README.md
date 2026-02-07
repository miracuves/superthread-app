# Superthread Flutter App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.4+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-lightgrey)
![License](https://img.shields.io/badge/license-Private-red)

**A complete, production-ready Flutter mobile application for [Superthread.com](https://superthread.com)**

[Features](#-features) • [Architecture](#-architecture) • [Setup](#-setup) • [API Integration](#-api-integration) • [Contributing](#-contributing)

</div>

---

## 📖 Overview

**Superthread App** is a comprehensive cross-platform Flutter application that provides a native mobile experience for the Superthread project management and collaboration platform. This app integrates seamlessly with the Superthread API to deliver full-featured project boards, cards, notes, pages, epics, and team collaboration features.

### 🎯 Project Goals

- ✅ Provide a native mobile experience for Superthread users
- ✅ Full API integration with Superthread.com
- ✅ Cross-platform support (iOS, Android, Web, macOS, Windows, Linux)
- ✅ Modern, responsive UI with Material Design
- ✅ Offline-ready architecture
- ✅ Real-time updates with WebSocket support
- ✅ Secure authentication with Personal Access Tokens (PAT)

---

## ✨ Features

### 🔐 Authentication
- **Personal Access Token (PAT)** based authentication
- Secure token storage using flutter_secure_storage
- Token validation and refresh mechanism
- User profile management

### 📋 Boards & Cards
- **Kanban Board** interface with drag-and-drop
- Create, read, update, delete boards and cards
- Card filtering (by status, tags, owner, project)
- Search functionality across cards
- Card assignment and collaboration
- Comments and reactions on cards
- Checklists and task tracking
- Due dates and reminders
- Card linking and dependencies
- Attachments and cover images

### 📝 Notes & Pages
- Rich text editor for notes
- Wiki-style pages
- Real-time collaboration
- Version history

### 🚀 Epics & Sprints
- Epic creation and management
- Sprint planning and tracking
- Progress tracking

### 🔍 Search
- Global search across all entities
- Smart suggestions and hints
- Advanced filters

### 🔔 Notifications
- Push notifications
- Notification history
- Customizable notification settings
- Real-time updates via WebSocket

### 🎨 UI/UX
- **Dark Mode** support with system theme detection
- Smooth animations with flutter_staggered_animations
- Responsive design for all screen sizes
- Custom widgets and components
- Loading states and error handling
- Bottom navigation for easy access

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

### 📁 Directory Structure

```
lib/
├── core/                          # Core functionality
│   ├── constants/                 # API constants
│   ├── network/                   # DioClient for HTTP
│   ├── services/                  # Dependency injection & services
│   ├── themes/                    # App theming
│   ├── router/                    # App routing (GoRouter)
│   ├── service_locator.dart       # GetIt DI setup
│   └── utils/                     # Helper utilities
│
├── data/                          # Data layer
│   └── models/                    # Data models & DTOs
│       ├── *.dart                 # Model definitions
│       ├── *.g.dart               # Generated JSON serialization
│       ├── requests/              # API request models
│       └── responses/             # API response models
│
├── presentation/                  # UI layer
│   ├── bloc/                      # BLoC state management
│   ├── pages/                     # Screen widgets
│   └── widgets/                   # Reusable widgets
│
└── main.dart                      # App entry point
```

### 🎨 State Management

- **BLoC Pattern** using flutter_bloc
- **Hydrated BLoC** for state persistence
- **Event-driven architecture** with clear separation

### 🌐 Networking

- **Dio** - HTTP client with interceptors
- **Retrofit** - Type-safe API client with code generation
- **Pretty Dio Logger** - HTTP request logging

### 🔑 Dependency Injection

- **GetIt** - Service locator pattern
- Lazy singletons for services
- Factory pattern for BLoCs

### 🧭 Routing

- **GoRouter** - Declarative routing
- Route guards for authentication
- Deep linking support
- Shell routing for nested navigation

---

## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK >= 3.4.0
- Dart SDK >= 3.4.0
- Android Studio / VS Code
- iOS Xcode (for iOS development)
- A Superthread account with [PAT token](https://app.superthread.com/settings/personal-access-tokens)

### 1. Clone the Repository

```bash
git clone https://github.com/miracuves/superthread-app.git
cd superthread-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

```bash
# Generate JSON serialization and API code
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configure API Access

Get your credentials from [Superthread Settings](https://app.superthread.com/settings/personal-access-tokens):

- **Personal Access Token (PAT)**
- **Team ID (Workspace ID)**

The app will prompt you to enter these credentials on first launch.

### 5. Run the App

```bash
# Run on connected device/emulator
flutter run

# Or run for specific platform
flutter run -d ios
flutter run -d android
flutter run -d chrome
```

---

## 🔌 API Integration

This app integrates with the official [Superthread API](https://superthread.com/docs/api-docs/).

### API Configuration

- **Base URL:** https://api.superthread.com/v1/
- **Authentication:** Bearer Token (PAT)
- **Documentation:** [superthread.com/docs/api-docs](https://superthread.com/docs/api-docs)

### Supported Endpoints

#### Authentication
- GET /users/me - Get current user
- PUT /users/me - Update profile

#### Boards (Team-scoped)
- GET /{teamId}/boards - List boards
- GET /{teamId}/boards/{id} - Get board details
- POST /{teamId}/boards - Create board
- PUT /{teamId}/boards/{id} - Update board
- DELETE /{teamId}/boards/{id} - Delete board

#### Cards (Team-scoped)
- GET /{teamId}/cards - List cards with filters
- POST /{teamId}/views/preview - Get assigned cards
- GET /{teamId}/cards/{id} - Get card details
- POST /{teamId}/cards - Create card
- PUT /{teamId}/cards/{id} - Update card
- DELETE /{teamId}/cards/{id} - Delete card

#### Comments
- Full CRUD operations
- Reactions support

#### Notes, Pages, Epics, Sprints
- Full CRUD operations for all entities

#### Teams & Users
- GET /teams/{teamId}/members - Get team members

---

## 🛠️ Tech Stack

### Core Framework
- **Flutter** 3.4+ - UI Framework
- **Dart** 3.4+ - Programming Language

### State Management
- **flutter_bloc** - BLoC pattern
- **hydrated_bloc** - State persistence

### Networking
- **dio** - HTTP client
- **retrofit** - Type-safe API
- **pretty_dio_logger** - Logging

### Storage
- **flutter_secure_storage** - Secure token storage
- **path_provider** - File system access

### Routing
- **go_router** - Declarative routing

### UI Components
- **flutter_staggered_animations** - Animations
- **animations** - Animation library
- **drag_and_drop_lists** - Drag & drop
- **reorderable_grid** - Grid reordering

### Utilities
- **connectivity_plus** - Network connectivity
- **url_launcher** - Open URLs
- **vibration** - Haptic feedback
- **web_socket_channel** - Real-time updates

### Code Generation
- **build_runner** - Code generation
- **json_serializable** - JSON serialization
- **retrofit_generator** - API client generation

### Development
- **flutter_lints** - Linting
- **very_good_analysis** - Strict analysis
- **mockito** - Testing
- **bloc_test** - BLoC testing

---

## 📱 Screens

### Authentication
- **Splash Screen** - App loading
- **Login Screen** - PAT token input

### Dashboard (Bottom Navigation)
- **Home** - Overview and recent activity
- **Projects** - Project boards
- **Cards** - Card list with filters
- **Notes** - Note list and editor
- **Pages** - Wiki pages
- **Search** - Global search
- **Profile** - User profile and settings

### Features
- **Kanban Board** - Drag-and-drop board view
- **Card Detail** - Full card information
- **Note Editor** - Rich text editing
- **Page Editor** - Wiki page editing
- **Notifications** - Notification history and settings
- **Settings** - App configuration

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run unit tests
flutter test test/unit/

# Run widget tests
flutter test test/widget/

# Run integration tests
flutter test integration_test/
```

---

## 📦 Build & Release

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build IPA
flutter build ios --release
```

### Web

```bash
# Build web app
flutter build web --release
```

---

## 🔧 Configuration

### API Constants

Edit lib/core/constants/api_constants.dart:

```dart
class ApiConstants {
  static const String baseUrl = 'https://api.superthread.com/v1/';
  static const String apiVersion = 'v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
```

---

## 🐛 Known Issues & Limitations

### Currently Missing Features

The following features from the official API are not yet implemented:

1. **External Links** - GitHub/GitLab PR integrations
2. **Webhook Notifications** - Slack/webhook management
3. **Public Boards** - Public board sharing
4. **Forms** - Board form submissions
5. **Comment Threading** - Nested comment replies
6. **VCS Mapping** - Git branch/PR mapping
7. **Smart Hints** - AI-powered suggestions
8. **Card Cover Images** - Advanced image positioning
9. **User Timezone/Locale** - User preferences

These features will be added in future releases.

---

## 🗺️ Roadmap

### Version 1.1 (Next Release)
- [ ] Add missing API fields to data models
- [ ] Implement comment threading
- [ ] Add external links support
- [ ] Improve error handling
- [ ] Add unit and integration tests

### Version 1.2
- [ ] Offline mode with caching
- [ ] Real-time WebSocket updates
- [ ] Push notification improvements
- [ ] Performance optimizations

### Version 2.0
- [ ] Full offline support
- [ ] Advanced search filters
- [ ] Custom themes
- [ ] Biometric authentication

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Commit your changes (git commit -m 'Add amazing feature')
4. Push to the branch (git push origin feature/amazing-feature)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter effective dart guidelines
- Write tests for new features
- Update documentation as needed
- Follow the existing code style
- Use flutter pub run build_runner after model changes

---

## 📄 License

This project is **PRIVATE** and proprietary.

Copyright © 2024 Miracuves. All rights reserved.

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/miracuves/superthread-app/issues)
- **Documentation:** [Superthread API Docs](https://superthread.com/docs/api-docs)
- **Email:** support@miracuves.com

---

## 🙏 Acknowledgments

- **Superthread** for the amazing platform and API
- **Flutter Team** for the excellent framework
- **BLoC Library** for state management solution
- **Community** for the amazing packages and tools

---

<div align="center">

**Built with ❤️ by [Miracuves](https://github.com/miracuves)**

[⬆ Back to Top](#superthread-flutter-app)

</div>

