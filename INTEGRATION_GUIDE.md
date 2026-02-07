# Integration Guide for New Widgets

This guide shows how to integrate the new UI widgets into the Superthread app.

## 1. External Links Integration

In `lib/presentation/screens/cards/card_detail_screen.dart`:

```dart
// Add to the build method after attachments section
if (card.externalLinks != null && card.externalLinks!.isNotEmpty)
  ExternalLinksList(
    links: card.externalLinks!,
    emptyMessage: 'No external links attached',
  ),
```

## 2. Comment Threading Integration

Replace existing comments list with:

```dart
ThreadedCommentsList(
  comments: card.comments ?? [],
  emptyMessage: 'No comments yet. Be the first to comment!',
  onReplyTap: (comment) {
    // Handle reply to specific comment
    _showReplyDialog(comment);
  },
),
```

## 3. Card Hints Integration

Add hints section in card detail:

```dart
if (card.hints != null && card.hints!.isNotEmpty)
  ...card.hints!.map((hint) =>
    CardHintWidget(
      hint: hint,
      onApply: () => _applyHint(hint),
      onDismiss: () => _dismissHint(hint),
    ),
  ).toList(),
```

## 4. Cover Image Integration

Add to card widget or detail screen:

```dart
if (card.coverImage != null)
  CoverImageWidget(
    coverImage: card.coverImage!,
    height: 200,
  ),
```

## 5. Estimate Badge Integration

Add to card list item:

```dart
Row(
  children: [
    Text(card.title),
    const Spacer(),
    EstimateWidget(
      estimate: card.estimate,
      onTap: () => _showEstimateEditor(card),
    ),
  ],
)
```

## Complete CardDetailScreen Example

```dart
class CardDetailScreen extends StatelessWidget {
  final Card card;

  const CardDetailScreen({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(card.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (card.coverImage != null)
              CoverImageWidget(coverImage: card.coverImage!),

            // Basic Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.title, style: Theme.of(context).textTheme.headlineMedium),
                  if (card.description != null) Text(card.description!),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      EstimateWidget(estimate: card.estimate),
                    ],
                  ),
                ],
              ),
            ),

            // Hints
            if (card.hints != null && card.hints!.isNotEmpty)
              ...card.hints!.map((hint) =>
                CardHintWidget(
                  hint: hint,
                  onApply: () {},
                  onDismiss: () {},
                ),
              ).toList(),

            // External Links
            if (card.externalLinks != null && card.externalLinks!.isNotEmpty)
              ExternalLinksList(links: card.externalLinks!),

            // Attachments
            if (card.attachments != null && card.attachments!.isNotEmpty)
              AttachmentsList(attachments: card.attachments!),

            // Comments
            ThreadedCommentsList(
              comments: card.comments ?? [],
              onReplyTap: (comment) {
                // Show reply dialog
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## BLoC Integration Example

```dart
// In your CardDetailBloc
class CardDetailBloc extends Bloc<CardDetailEvent, CardDetailState> {
  final GetCardUseCase _getCardUseCase;

  CardDetailBloc(this._getCardUseCase) : super(CardDetailInitial()) {
    on<LoadCard>(_onLoadCard);
    on<ReplyToComment>(_onReplyToComment);
    on<ApplyHint>(_onApplyHint);
  }

  Future<void> _onLoadCard(LoadCard event, Emitter<CardDetailState> emit) async {
    emit(CardDetailLoading());
    try {
      final card = await _getCardUseCase(event.cardId);
      emit(CardDetailLoaded(card));
    } catch (e) {
      emit(CardDetailError(e.toString()));
    }
  }

  Future<void> _onReplyToComment(ReplyToComment event, Emitter<CardDetailState> emit) async {
    // Handle reply logic
  }

  Future<void> _onApplyHint(ApplyHint event, Emitter<CardDetailState> emit) async {
    // Handle hint application
  }
}
```

## API Data Flow

All new fields are automatically parsed from the API:

```json
{
  "id": "card123",
  "title": "Example Card",
  "external_links": [
    {
      "type": "github",
      "github_pull_request": {
        "number": 123,
        "state": "open",
        "title": "Fix bug"
      }
    }
  ],
  "hints": [
    {
      "type": "tag",
      "tag": {"name": "bug"}
    }
  ],
  "cover_image": {
    "type": "image",
    "src": "https://example.com/image.jpg"
  },
  "estimate": 5,
  "comments": [
    {
      "id": "c1",
      "content": "Parent comment",
      "replies": [
        {"id": "c2", "content": "Reply", "parent_id": "c1"}
      ]
    }
  ]
}
```

## Testing

All widgets have comprehensive tests. Run them with:

```bash
flutter test test/presentation/widgets/
```

## Next Steps

1. Integrate widgets into CardDetailScreen
2. Connect to real API data
3. Add navigation between screens
4. Implement BLoC state management
5. Add error handling and loading states
6. Write integration tests

## Files Created

- `lib/presentation/widgets/cards/external_link_widget.dart` - GitHub/GitLab PR display
- `lib/presentation/widgets/comments/threaded_comment_widget.dart` - Nested comments
- `lib/presentation/widgets/cards/card_hint_widget.dart` - AI suggestions
- `lib/presentation/widgets/cards/cover_image_widget.dart` - Cover images
- `lib/presentation/widgets/cards/estimate_widget.dart` - Story points

All widgets follow Material Design guidelines and are fully responsive.
