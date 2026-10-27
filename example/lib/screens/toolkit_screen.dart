import 'package:flutter/material.dart';
import 'package:flutter_pageable/flutter_pageable.dart';

import '../demo_data.dart';

class ToolkitScreen extends StatefulWidget {
  const ToolkitScreen({super.key});

  @override
  State<ToolkitScreen> createState() => _ToolkitScreenState();
}

class _ToolkitScreenState extends State<ToolkitScreen> {
  final _repository = DemoRepository();
  late final PageableController<String, DemoItem> _cursorController =
      PageableController<String, DemoItem>(
        fetchPage: _repository.fetchCursorPage,
        getFirstPageKey: 'start',
        getNextPageKey: (cursor, items, total) => switch (cursor) {
          'start' => 'after-3',
          'after-3' => 'after-6',
          _ => null,
        },
        pageSize: 3,
        showLog: false,
      );

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = Optional.ofNullable<String>(null).orElse('anonymous');
    final digits = 42.toDigits(5);
    final duration = const Duration(minutes: 5, seconds: 7).asTime;
    final pages = List<int>.generate(
      10,
      (index) => index + 1,
    ).buildPageablePages(pageSize: 4);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Small helpers included with the package',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        const Text(
          'All examples below run locally; no extra package dependency is required.',
        ),
        const SizedBox(height: 16),
        _UtilityCard(
          icon: Icons.check_circle_outline,
          title: 'Optional',
          detail: 'Optional.ofNullable(null).orElse("anonymous") → $name',
        ),
        _UtilityCard(
          icon: Icons.format_list_numbered,
          title: 'Primitive extensions',
          detail:
              '42.toDigits(5) → $digits\nDuration(minutes: 5, seconds: 7).asTime → $duration',
        ),
        _UtilityCard(
          icon: Icons.layers_outlined,
          title: 'Page results',
          detail:
              'buildPageablePages(pageSize: 4) created ${pages.length} deterministic pages.',
        ),
        const _UtilityCard(
          icon: Icons.functions,
          title: 'Other exports',
          detail: 'Typed keys, PageableCache, PageableLogger, Collector, typed streams, equality and regex helpers.',
        ),
        const SizedBox(height: 8),
        Text(
          'Cursor pagination (String page keys)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 245,
          child: PageableListView<String, DemoItem>.builder(
            key: const Key('cursor-list'),
            controller: _cursorController,
            builderDelegate: PageableBuilderDelegate<DemoItem>(
              invisibleItemsThreshold: 1,
              itemBuilder: (context, metadata) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: DemoItemCard(item: metadata.item),
              ),
              firstPageProgressIndicatorBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              newPageProgressIndicatorBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              firstPageErrorIndicatorBuilder: (_) => Center(
                child: FilledButton(
                  onPressed: _cursorController.retry,
                  child: const Text('Retry cursor request'),
                ),
              ),
              noItemsFoundIndicatorBuilder: (_) =>
                  const Center(child: Text('No cursor results')),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _Callout(
          title: 'Controller lifecycle',
          detail: 'Inspect controller.pageable, itemList, status, error, hasData and isLoading. Drive fetchFirstPage, fetchNextPage, fetchPreviousPage, refresh, retry, clear and setEnabled as needed.',
        ),
        const SizedBox(height: 8),
        const _Callout(
          title: 'Delegate states',
          detail: 'Customize first/next/previous loading, first/next/previous errors, empty results and completed-footer builders independently.',
        ),
      ],
    );
  }
}

class _UtilityCard extends StatelessWidget {
  const _UtilityCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(detail),
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(detail),
          ],
        ),
      ),
    );
  }
}
