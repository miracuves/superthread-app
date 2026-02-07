import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superthread_app/presentation/widgets/comments/threaded_comment_widget.dart';
import 'package:superthread_app/data/models/card.dart';

void main() {
  group('ThreadedCommentWidget', () {
    testWidgets('displays comment', (tester) async {
      final c = Comment(id: '1', cardId: 'c1', content: 'Test', authorId: 'u1', authorName: 'John', createdAt: DateTime.now());
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ThreadedCommentWidget(comment: c))));
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
    });

    testWidgets('displays replies', (tester) async {
      final r = Comment(id: '2', cardId: 'c1', content: 'Reply', authorId: 'u2', authorName: 'Jane', createdAt: DateTime.now());
      final c = Comment(id: '1', cardId: 'c1', content: 'Parent', authorId: 'u1', authorName: 'John', createdAt: DateTime.now(), replies: [r]);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ThreadedCommentWidget(comment: c))));
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Reply'), findsOneWidget);
    });

    testWidgets('collapses replies', (tester) async {
      final r = Comment(id: '2', cardId: 'c1', content: 'Reply', authorId: 'u2', authorName: 'Jane', createdAt: DateTime.now());
      final c = Comment(id: '1', cardId: 'c1', content: 'Parent', authorId: 'u1', authorName: 'John', createdAt: DateTime.now(), replies: [r]);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ThreadedCommentWidget(comment: c))));
      expect(find.text('Reply'), findsOneWidget);
      await tester.tap(find.text('1 replies'));
      await tester.pump();
      expect(find.text('Reply'), findsNothing);
    });

    testWidgets('empty state', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ThreadedCommentsList(comments: [], emptyMessage: 'No comments'))));
      expect(find.text('No comments'), findsOneWidget);
    });
  });
}
