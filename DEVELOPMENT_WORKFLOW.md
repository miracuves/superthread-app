# Development Workflow - Superthread Flutter App

This document outlines the development workflow, conventions, and best practices for the Superthread Flutter App project.

## 📋 Table of Contents

- [Development Environment Setup](#development-environment-setup)
- [Branching Strategy](#branching-strategy)
- [Commit Conventions](#commit-conventions)
- [Code Style & Quality](#code-style--quality)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)
- [Troubleshooting](#troubleshooting)

---

## 🛠️ Development Environment Setup

### Prerequisites

- Flutter SDK >= 3.4.0
- Dart SDK >= 3.4.0
- Git
- VS Code or Android Studio
- iOS Simulator (Mac) or Android Emulator

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/miracuves/superthread-app.git
cd superthread-app

# Install Flutter dependencies
flutter pub get

# Install Git hooks (if available)
chmod +x .git/hooks/*

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### VS Code Extensions

Recommended extensions:
- Flutter
- Dart
- Awesome Flutter Snippets
- GitLens
- Error Lens

---

## 🌳 Branching Strategy

We use a simplified Git flow:

### Main Branches

- `main` - Production-ready code
- `develop` - Integration branch for features

### Feature Branches

```bash
# Format: feature/issue-number-description
git checkout -b feature/123-add-external-links-support
```

### Branch Types

- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation updates
- `refactor/*` - Code refactoring
- `test/*` - Adding tests
- `chore/*` - Maintenance tasks

### Workflow

1. Create a feature branch from `develop`
2. Make commits following our conventions
3. Push to your fork
4. Create a Pull Request to `develop`
5. After review, merge to `develop`
6. Periodically merge `develop` to `main` for releases

---

## 📝 Commit Conventions

We follow [Conventional Commits](https://www.conventionalcommits.org/):

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements

### Examples

```bash
# Feature
git commit -m "feat(card): add external links support for GitHub PRs"

# Bug fix
git commit -m "fix(auth): resolve token validation error on iOS"

# Documentation
git commit -m "docs(readme): update setup instructions"

# Refactoring
git commit -m "refactor(api): simplify dio client configuration"
```

### Good Commit Messages

✅ Good:
```
feat(card): add external links support

- Add ExternalLink model with GitHub PR support
- Integrate with Card model
- Add UI for displaying external links
- Handle link states (open, closed, merged)

Closes #123
```

❌ Bad:
```
updated stuff
fixed bugs
```

---

## 🎨 Code Style & Quality

### Dart/Flutter Conventions

We follow:
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)
- [very_good_analysis](https://pub.dev/packages/very_good_analysis) lints

### Code Formatting

```bash
# Format all code
dart format .

# Check formatting
dart format --output=none --set-exit-if-changed .
```

### Linting

```bash
# Run linter
flutter analyze

# Fix issues automatically
dart fix --apply
```

### Code Generation

After modifying models with `@JsonSerializable`:

```bash
# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes during development
flutter pub run build_runner watch --delete-conflicting-outputs
```

### File Organization

```
lib/
├── core/
│   ├── constants/          # Constants (API keys, etc.)
│   ├── network/            # Network layer
│   ├── services/           # Services (API, storage, etc.)
│   ├── themes/             # App theming
│   ├── router/             # Routing
│   ├── service_locator.dart # DI setup
│   └── utils/              # Utility functions
│
├── data/
│   └── models/             # Data models
│       ├── *.dart          # Models
│       └── *.g.dart        # Generated files
│
├── presentation/
│   ├── bloc/              # BLoC state management
│   ├── pages/             # Screens
│   └── widgets/           # Reusable widgets
│
└── main.dart
```

### Naming Conventions

- **Files**: `snake_case.dart` (e.g., `card_detail_screen.dart`)
- **Classes**: `PascalCase` (e.g., `CardDetailScreen`)
- **Variables/Methods**: `camelCase` (e.g., `fetchCards()`)
- **Constants**: `camelCase` (e.g., `apiBaseUrl`)
- **Private members**: prefix with `_` (e.g., `_methodName()`)

### Best Practices

1. **Use const constructors** wherever possible
2. **Prefer composition over inheritance**
3. **Keep widgets small** - single responsibility
4. **Use async/await** over Future.then()
5. **Don't block the main thread** - use Isolates for heavy computation
6. **Handle errors gracefully** - never let exceptions crash the app
7. **Use Equatable** for value equality in models and states

---

## 🧪 Testing Guidelines

### Test Structure

```
test/
├── unit/                  # Unit tests
│   ├── bloc/
│   ├── models/
│   └── services/
├── widget/                # Widget tests
└── integration/           # Integration tests
```

### Unit Tests

Test business logic in isolation:

```dart
// test/unit/bloc/card_bloc_test.dart
void main() {
  late CardBloc cardBloc;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    cardBloc = CardBloc(mockApiService, MockStorageService());
  });

  tearDown(() {
    cardBloc.close();
  });

  test('emits [CardLoading, CardLoaded] when LoadCards is added', () {
    // Arrange
    when(mockApiService.getCards(any, any))
        .thenAnswer((_) async => CardsResponse(cards: []));

    // Act
    final expected = [
      CardLoading(),
      CardLoaded(cards: []),
    ];
    expectLater(cardBloc.stream, emitsInOrder(expected));

    // Assert
    cardBloc.add(LoadCards(teamId: 'test'));
  });
}
```

### Widget Tests

Test UI components:

```dart
// test/widget/card_widget_test.dart
void main() {
  testWidgets('CardWidget displays title and description', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CardWidget(
          card: Card(
            id: '1',
            title: 'Test Card',
            description: 'Test Description',
            boardId: 'board-1',
            createdAt: DateTime.now(),
          ),
        ),
      ),
    );

    expect(find.text('Test Card'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
  });
}
```

### Running Tests

```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# With coverage
flutter test --coverage
```

---

## 🔀 Pull Request Process

### Before Creating a PR

1. **Update your branch**

```bash
git checkout develop
git pull origin develop
git checkout feature/your-feature
git rebase develop
```

2. **Run tests**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed .
```

3. **Generate code** (if models changed)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project conventions
- [ ] Self-review completed
- [ ] Comments added to complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally
- [ ] Ready for review

## Related Issues
Closes #issue-number
```

### PR Review Guidelines

- Be respectful and constructive
- Focus on what needs to be improved
- Approve when satisfied or suggest changes
- Request changes if something needs work

---

## 📦 Release Process

### Version Bumping

We use [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

```bash
# Example versions
1.0.0    # Initial release
1.0.1    # Bug fix
1.1.0    # New feature (backward compatible)
2.0.0    # Breaking changes
```

### Release Steps

1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Create release branch: `release/x.y.z`
4. Run full test suite
5. Create tag: `git tag -a vx.y.z -m "Release x.y.z"`
6. Push tag: `git push origin vx.y.z`
7. Merge `release/x.y.z` to `main`
8. Create GitHub Release

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS IPA
flutter build ios --release

# Web
flutter build web --release
```

---

## 🔧 Troubleshooting

### Common Issues

#### Build Runner Issues

```bash
# Clean and regenerate
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

#### CocoaPods Issues (iOS)

```bash
cd ios
pod deintegrate
pod repo update
pod install
cd ..
flutter clean
flutter pub get
```

#### Outdated Dependencies

```bash
flutter pub outdated
flutter pub upgrade --major-versions
```

#### Flutter Doctor

```bash
flutter doctor -v
```

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [BLoC Library](https://bloclibrary.dev)
- [Superthread API Docs](https://superthread.com/docs/api-docs)

---

## 🤝 Contributing

Thank you for following this workflow! It helps maintain code quality and makes collaboration easier.

For questions or suggestions, please open an issue or contact the maintainers.

