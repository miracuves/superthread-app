# Development Workflow

Guidelines for contributing to the Superthread Flutter app.

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Submit a pull request

## Branch Naming

```
feature/your-feature-name
fix/bug-description
hotfix/critical-fix
refactor/code-cleanup
```

## Code Style

### Dart Style

Follow [Effective Dart](https://dart.dev/guides/language/effective-dart):

- Use `camelCase` for variables and methods
- Use `PascalCase` for types and classes
- Use `lower_snake_case` for files and folders
- Add documentation comments for public APIs

### Example

```dart
/// Creates a new card.
/// 
/// The [title] must not be empty.
/// Returns the created [Card].
Future<Card> createCard({
  required String title,
  String? description,
}) async {
  // Implementation
}
```

## Commit Messages

Follow conventional commits:

```
feat: add external links widget
fix: resolve comment threading bug
docs: update API documentation
refactor: simplify card loading logic
test: add widget tests for card detail
chore: upgrade dependencies
```

## Pull Requests

### PR Template

```
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
- [ ] Code follows style guide
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests pass locally
```

## Testing

### Run Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test
flutter test test/widget_test.dart
```

### Run Widget Tests

```bash
flutter test test/presentation/widgets/
```

## Code Generation

After modifying models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Before Pushing

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Build (optional)
flutter build apk --debug
```

## Code Review

All PRs require:
- At least one approval
- All tests passing
- No merge conflicts
- Documentation updated

## Release Process

1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Create git tag
4. Build release artifacts
5. Deploy to stores

---

*See [Installation](Installation) for setup instructions.*
