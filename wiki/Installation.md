# Installation Guide

This guide will help you set up the Superthread Flutter app on your development machine.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.22.0 or higher)
- **Dart SDK** (3.10.8 or higher)
- **Android Studio** / **Xcode** (for mobile development)
- **Visual Studio Code** or **IntelliJ IDEA** (recommended IDE)

### Verify Flutter Installation

```bash
flutter doctor
```

All items should have checkmarks (✓). If not, install missing components.

## 🚀 Setup Steps

### 1. Clone the Repository

```bash
git clone https://github.com/miracuves/superthread-app.git
cd superthread_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

This project uses code generation for JSON serialization and API clients:

```bash
# Generate code (run after any model changes)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configure Environment

The app uses the following environment configuration:

**File:** `lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'https://api.superthread.com/v1';
  static const String websocketUrl = 'wss://api.superthread.com/realtime';
}
```

For development, you may need to update these URLs to point to your development API server.

### 5. Run the App

#### iOS Simulator
```bash
flutter run -d ios
```

#### Android Emulator
```bash
flutter run -d android
```

#### Web (Development)
```bash
flutter run -d chrome
```

#### Desktop (macOS)
```bash
flutter run -d macos
```

## 🔧 Firebase Setup

The app uses Firebase for push notifications. To set up Firebase:

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add an iOS app
4. Add an Android app

### 2. Download Configuration Files

- **iOS:** Download `GoogleService-Info.plist`
- **Android:** Download `google-services.json`

### 3. Add Configuration Files

**iOS:**
```bash
# Place in ios/Runner/
cp GoogleService-Info.plist ios/Runner/
```

**Android:**
```bash
# Place in android/app/
cp google-services.json android/app/
```

### 4. Update Dependencies

**android/build.gradle:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'
```

## 📱 Building for Production

### iOS

```bash
# Build IPA
flutter build ipa --release

# Or build for App Store
flutter build ios --release
```

### Android

```bash
# Build APK
flutter build apk --release

# Or build App Bundle
flutter build appbundle --release
```

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 🐛 Troubleshooting

### Build Issues

**Issue:** " CocoaPods not installed"

```bash
sudo gem install cocoapods
cd ios && pod install
```

**Issue:** "Flutter command not found"

Add Flutter to your PATH:

```bash
# Add to ~/.zshrc or ~/.bash_profile
export PATH="$PATH:/path/to/flutter/bin"
```

### Code Generation Issues

If you encounter issues with generated code:

```bash
# Clean build
flutter clean

# Delete generated files
rm -rf .dart_tool/build

# Regenerate
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📚 Next Steps

- Read [Project Structure](Project-Structure)
- Understand [Architecture](Architecture)
- Explore [Features](Features)

---

*Need help? Open an issue on GitHub.*
