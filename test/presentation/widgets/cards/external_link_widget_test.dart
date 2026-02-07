import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superthread_app/presentation/widgets/cards/external_link_widget.dart';
import 'package:superthread_app/data/models/external_link.dart';

void main() {
  group('ExternalLinkWidget', () {
    testWidgets('displays GitHub PR correctly', (WidgetTester tester) async {
      final link = ExternalLink(
        type: 'github',
        githubPullRequest: GitHubPullRequest(
          id: 1,
          number: 123,
          state: 'open',
          title: 'Test PR',
          htmlUrl: 'https://github.com/test/repo/pull/123',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ExternalLinkWidget(externalLink: link)),
        ),
      );

      expect(find.text('PR #123'), findsOneWidget);
      expect(find.text('Test PR'), findsOneWidget);
    });

    testWidgets('displays generic link correctly', (WidgetTester tester) async {
      final link = ExternalLink(
        type: 'generic',
        generic: GenericLink(
          url: 'https://example.com',
          id: '1',
          displayText: 'Example Site',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ExternalLinkWidget(externalLink: link)),
        ),
      );

      expect(find.text('Example Site'), findsOneWidget);
    });

    testWidgets('shows empty state when no links', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExternalLinksList(
              links: [],
              emptyMessage: 'No links',
            ),
          ),
        ),
      );

      expect(find.text('No links'), findsOneWidget);
    });

    testWidgets('displays link count badge', (WidgetTester tester) async {
      final links = [
        ExternalLink(type: 'github', githubPullRequest: GitHubPullRequest(
          id: 1, number: 1, state: 'open',
        )),
        ExternalLink(type: 'github', githubPullRequest: GitHubPullRequest(
          id: 2, number: 2, state: 'open',
        )),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ExternalLinksList(links: links)),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('External Links'), findsOneWidget);
    });
  });
}
