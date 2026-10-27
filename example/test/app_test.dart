import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pageable_example/main.dart';

void main() {
  Future<void> openShowcase(WidgetTester tester) async {
    await tester.pumpWidget(const PageableShowcaseApp());
    await tester.pumpAndSettle();
  }

  testWidgets(
    'loads local feed, refreshes after an injected error, and retries',
    (tester) async {
      await openShowcase(tester);

      expect(find.text('Design story 7'), findsOneWidget);
      expect(find.byKey(const Key('feed-status')), findsOneWidget);

      await tester.tap(find.byKey(const Key('feed-fail-next')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('feed-first-error')), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('feed-first-error')), findsNothing);

      await tester.tap(find.byKey(const Key('feed-load-previous')));
      await tester.pumpAndSettle();
      expect(find.text('Design story 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('feed-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nothing').last);
      await tester.pumpAndSettle();
      expect(find.text('No matching items'), findsOneWidget);
    },
  );

  testWidgets('switches among all five pageable layouts', (tester) async {
    await openShowcase(tester);
    await tester.tap(find.text('Views'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('layout-list')), findsOneWidget);
    for (final entry in const [
      ('ListView.separated', 'layout-separated'),
      ('GridView', 'layout-grid'),
      ('PageView', 'layout-page'),
      ('Staggered / masonry', 'layout-staggered'),
    ]) {
      await tester.tap(find.byKey(const Key('layout-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.$1).last);
      await tester.pumpAndSettle();
      expect(find.byKey(Key(entry.$2)), findsOneWidget);
    }
  });

  testWidgets('renders and changes the multi-source feed', (tester) async {
    await openShowcase(tester);
    await tester.tap(find.text('Sources'));
    await tester.pumpAndSettle();

    expect(find.textContaining('2 sources'), findsOneWidget);
    expect(find.text('Community item 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recommendations-source')));
    await tester.pumpAndSettle();
    expect(find.textContaining('3 sources'), findsOneWidget);

    await tester.tap(find.byKey(const Key('strategy-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Priority').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('strategy-selector')), findsOneWidget);

    await tester.tap(find.byKey(const Key('source-fail-ads')));
    await tester.pumpAndSettle();
    expect(find.textContaining('partial source failure'), findsOneWidget);
    expect(find.text('Community item 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('source-retry')));
    await tester.pumpAndSettle();
    expect(find.textContaining('partial source failure'), findsNothing);
  });

  testWidgets('shows bundled utility examples', (tester) async {
    await openShowcase(tester);
    await tester.tap(find.text('Toolkit'));
    await tester.pumpAndSettle();

    expect(find.textContaining('anonymous'), findsOneWidget);
    expect(find.textContaining('00042'), findsOneWidget);
    expect(find.textContaining('3 deterministic pages'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('cursor-list')), 200);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cursor-list')), findsOneWidget);
    expect(find.text('Cursor result 1'), findsOneWidget);
  });
}
