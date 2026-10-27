import 'package:flutter/material.dart';
import 'package:flutter_pageable/flutter_pageable.dart';

import '../demo_data.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _repository = DemoRepository();
  late final PageableController<int, DemoItem> _controller;
  String _category = 'All';
  bool _polling = false;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  PageableController<int, DemoItem> _createController() {
    return PageableController<int, DemoItem>(
      fetchPage: (page) => _repository.fetchFeedPage(page, category: _category),
      getFirstPageKey: 2,
      getNextPageKey: (key, items, total) => key < 4 ? key + 1 : null,
      getPreviousPageKey: (key, items, total) => key > 1 ? key - 1 : null,
      pageSize: demoPageSize,
      cacheKey: 'flutter-pageable-showcase-feed',
      pollInterval: const Duration(seconds: 45),
      retryIf: (error, stackTrace, attempt) => error is! StateError,
      maxRetries: 0,
      pausePollingWhenHidden: true,
      showLog: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _changeCategory(String? category) async {
    if (category == null || category == _category) return;
    setState(() => _category = category);
    await _controller.setReloadKey(category);
  }

  Future<void> _toggleEnabled() async {
    await _controller.setEnabled(!_controller.enabled);
    if (mounted) setState(() {});
  }

  void _togglePolling() {
    if (_polling) {
      _controller.stopPolling();
    } else {
      _controller.startPolling();
    }
    setState(() => _polling = !_polling);
  }

  PageableBuilderDelegate<DemoItem> get _delegate =>
      PageableBuilderDelegate<DemoItem>(
        invisibleItemsThreshold: 2,
        itemBuilder: (context, metadata) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DemoItemCard(item: metadata.item, index: metadata.index),
        ),
        firstPageProgressIndicatorBuilder: (_) => const _StatePanel(
          key: Key('feed-loading'),
          icon: Icons.downloading,
          title: 'Loading the feed',
          detail: 'The first page is on its way.',
          busy: true,
        ),
        newPageProgressIndicatorBuilder: (_) => const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
        previousPageProgressIndicatorBuilder: (_) => const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
        firstPageErrorIndicatorBuilder: (_) => _StatePanel(
          key: const Key('feed-first-error'),
          icon: Icons.cloud_off,
          title: 'Could not load this page',
          detail: 'The demo fails once when you choose “Fail next request”.',
          action: FilledButton.icon(
            onPressed: _controller.retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ),
        newPageErrorIndicatorBuilder: (_) =>
            _RetryFooter(onRetry: _controller.retry),
        previousPageErrorIndicatorBuilder: (_) =>
            _RetryFooter(onRetry: _controller.retry),
        noItemsFoundIndicatorBuilder: (_) => const _StatePanel(
          icon: Icons.inbox_outlined,
          title: 'No matching items',
          detail: 'Choose another category or refresh.',
        ),
        noMoreItemsIndicatorBuilder: (_) => const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('You have reached the end of this feed.')),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'One typed controller, two-way paging, in-memory snapshot cache, reload keys, polling and retry.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<String>(
                    key: const Key('feed-category'),
                    value: _category,
                    onChanged: _changeCategory,
                    items:
                        const [
                              'All',
                              'Design',
                              'Engineering',
                              'Product',
                              'Nothing',
                            ]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                  ),
                  IconButton.filledTonal(
                    key: const Key('feed-refresh'),
                    tooltip: 'Refresh feed',
                    onPressed: _controller.refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                  OutlinedButton.icon(
                    key: const Key('feed-fail-next'),
                    onPressed: () async {
                      _repository.failNextFeedRequest();
                      _controller.clear();
                      await _controller.fetchFirstPage();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'First-page error injected. Use Try again to recover.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Fail next request'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _toggleEnabled,
                    icon: Icon(
                      _controller.enabled ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(
                      _controller.enabled
                          ? 'Pause auto-load'
                          : 'Resume auto-load',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _togglePolling,
                    icon: Icon(_polling ? Icons.timer_off : Icons.timer),
                    label: Text(_polling ? 'Stop polling' : 'Start polling'),
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, state, _) => Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Status: ${state.status.name}  ·  ${state.itemCount} items  ·  ${state.pageCount} pages',
                      key: const Key('feed-status'),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (_controller.canLoadPrevious)
                      OutlinedButton.icon(
                        key: const Key('feed-load-previous'),
                        onPressed: _controller.fetchPreviousPage,
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('Load earlier'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PullToRefresh(
            onAsyncRefreshed: _controller.refresh,
            refreshType: PullToRefreshType.material,
            child: PageableListView<int, DemoItem>.separated(
              controller: _controller,
              builderDelegate: _delegate,
              separatorStrategy: (index) => index.isOdd,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
    this.busy = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? action;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 34),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(detail, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}

class _RetryFooter extends StatelessWidget {
  const _RetryFooter({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Could not load more · retry'),
      ),
    );
  }
}
