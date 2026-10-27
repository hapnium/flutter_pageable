import 'package:flutter/material.dart';
import 'package:flutter_pageable/flutter_pageable.dart';

import '../demo_data.dart';

enum DemoStrategy { roundRobin, priority, custom }

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  final _repository = DemoRepository();
  late InterleavablePageableController<int, DemoItem> _controller;
  DemoStrategy _strategy = DemoStrategy.roundRobin;
  bool _showSponsored = true;
  bool _hasRecommendations = false;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  InterleavablePageableController<int, DemoItem> _createController() {
    final sources = <PageableSource<int, DemoItem>>[
      _source('community', priority: 0),
      if (_showSponsored) _source('sponsored', priority: 2),
      if (_hasRecommendations) _source('recommendations', priority: 1),
    ];
    return InterleavablePageableController<int, DemoItem>(
      strategy: switch (_strategy) {
        DemoStrategy.roundRobin => const RoundRobinInterleaveStrategy<DemoItem>(
          itemsPerSource: 2,
        ),
        DemoStrategy.priority => const PriorityInterleaveStrategy<DemoItem>(),
        DemoStrategy.custom => CustomInterleaveStrategy<DemoItem>(
          interleaveFn: (sources) {
            final items = sources.values
                .expand((state) => state.items)
                .toList();
            items.sort((a, b) => a.title.compareTo(b.title));
            return items;
          },
          routingFn: (sources) =>
              sources.values
                  .where((state) => state.canLoadMore && !state.isFetching)
                  .map((state) => state.id)
                  .toList()
                ..sort(),
        ),
      },
      sources: sources,
      showLog: false,
    );
  }

  PageableSource<int, DemoItem> _source(String id, {required int priority}) {
    return PageableSource<int, DemoItem>(
      id: id,
      fetchPage: (page) => _repository.fetchSourcePage(id, page),
      firstPageKey: 1,
      getNextPageKey: (key, items, total) => items.length == 4 ? key + 1 : null,
      pageSize: 4,
      priority: priority,
    );
  }

  Future<void> _resetForOptions() async {
    final previous = _controller;
    _controller = _createController();
    setState(() {});
    previous.dispose();
    await _controller.fetchFirstPage();
  }

  Future<void> _toggleSponsored(bool value) async {
    setState(() => _showSponsored = value);
    if (value) {
      _controller.addSource(_source('sponsored', priority: 2));
    } else {
      _controller.removeSource('sponsored');
    }
    await _controller.fetchFirstPage();
  }

  Future<void> _toggleRecommendations() async {
    setState(() => _hasRecommendations = !_hasRecommendations);
    if (_hasRecommendations) {
      _controller.addSource(_source('recommendations', priority: 1));
    } else {
      _controller.removeSource('recommendations');
    }
    await _controller.fetchFirstPage();
  }

  Future<void> _failSponsoredOnce() async {
    _repository.failAds = true;
    await _controller.fetchNextPage();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sponsored source failed; community items stay visible.'),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PageableBuilderDelegate<DemoItem> _delegate(
    InterleavablePageableController<int, DemoItem> controller,
  ) {
    return PageableBuilderDelegate<DemoItem>(
      invisibleItemsThreshold: 2,
      itemBuilder: (context, metadata) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DemoItemCard(item: metadata.item, index: metadata.index),
      ),
      firstPageProgressIndicatorBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
      newPageProgressIndicatorBuilder: (_) => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      firstPageErrorIndicatorBuilder: (_) => Center(
        child: FilledButton(
          onPressed: controller.retry,
          child: const Text('Retry failed sources'),
        ),
      ),
      newPageErrorIndicatorBuilder: (_) => Center(
        child: TextButton(
          onPressed: controller.retry,
          child: const Text('Retry failed sources'),
        ),
      ),
      noItemsFoundIndicatorBuilder: (_) =>
          const Center(child: Text('No source items')),
      noMoreItemsIndicatorBuilder: (_) =>
          const Center(child: Text('All sources are exhausted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Independent cursors and failures, one strategy-ordered feed.',
              ),
              DropdownButtonFormField<DemoStrategy>(
                key: const Key('strategy-selector'),
                initialValue: _strategy,
                decoration: const InputDecoration(
                  labelText: 'Interleave strategy',
                ),
                items: const [
                  DropdownMenuItem(
                    value: DemoStrategy.roundRobin,
                    child: Text('Round robin'),
                  ),
                  DropdownMenuItem(
                    value: DemoStrategy.priority,
                    child: Text('Priority'),
                  ),
                  DropdownMenuItem(
                    value: DemoStrategy.custom,
                    child: Text('Custom alphabetical'),
                  ),
                ],
                onChanged: (value) async {
                  if (value == null) return;
                  setState(() => _strategy = value);
                  await _resetForOptions();
                },
              ),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    key: const Key('sponsored-source'),
                    label: const Text('Sponsored source'),
                    selected: _showSponsored,
                    onSelected: _toggleSponsored,
                  ),
                  ActionChip(
                    key: const Key('recommendations-source'),
                    label: Text(
                      _hasRecommendations
                          ? 'Remove recommendations'
                          : 'Add recommendations',
                    ),
                    onPressed: _toggleRecommendations,
                  ),
                  OutlinedButton(
                    key: const Key('source-fail-ads'),
                    onPressed: _failSponsoredOnce,
                    child: const Text('Fail sponsored once'),
                  ),
                ],
              ),
              ValueListenableBuilder(
                key: const Key('source-status'),
                valueListenable: _controller,
                builder: (context, state, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_controller.sourceIds.length} sources · ${state.itemCount} items · ${state.status.name}'
                      '${state.error == null ? '' : ' · partial source failure'}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (state.error != null)
                      TextButton(
                        key: const Key('source-retry'),
                        onPressed: _controller.retry,
                        child: const Text('Retry failed sources only'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageableListView<int, DemoItem>.builder(
            key: ValueKey(_controller),
            controller: _controller,
            builderDelegate: _delegate(_controller),
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
