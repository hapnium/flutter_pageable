import 'package:flutter/material.dart';
import 'package:flutter_pageable/flutter_pageable.dart';

import '../demo_data.dart';

enum DemoLayout { list, separated, grid, page, staggered }

class LayoutsScreen extends StatefulWidget {
  const LayoutsScreen({super.key});

  @override
  State<LayoutsScreen> createState() => _LayoutsScreenState();
}

class _LayoutsScreenState extends State<LayoutsScreen> {
  final _repository = DemoRepository();
  late final PageableController<int, DemoItem> _controller;
  DemoLayout _layout = DemoLayout.list;

  @override
  void initState() {
    super.initState();
    _controller = PageableController<int, DemoItem>(
      fetchPage: (page) => _repository.fetchFeedPage(page, category: 'All'),
      getFirstPageKey: 1,
      getNextPageKey: (key, items, total) => key < 4 ? key + 1 : null,
      pageSize: demoPageSize,
      showLog: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PageableBuilderDelegate<DemoItem> get _delegate =>
      PageableBuilderDelegate<DemoItem>(
        invisibleItemsThreshold: 2,
        itemBuilder: (context, metadata) => Padding(
          padding: const EdgeInsets.all(6),
          child: DemoItemCard(item: metadata.item, index: metadata.index),
        ),
        firstPageProgressIndicatorBuilder: (_) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        newPageProgressIndicatorBuilder: (_) => const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
        firstPageErrorIndicatorBuilder: (_) => Center(
          child: FilledButton(
            onPressed: _controller.retry,
            child: const Text('Retry'),
          ),
        ),
        noItemsFoundIndicatorBuilder: (_) =>
            const Center(child: Text('No items found')),
        noMoreItemsIndicatorBuilder: (_) =>
            const Center(child: Text('End of examples')),
      );

  Widget _buildView() {
    switch (_layout) {
      case DemoLayout.list:
        return PageableListView<int, DemoItem>.builder(
          key: const Key('layout-list'),
          controller: _controller,
          builderDelegate: _delegate,
          padding: const EdgeInsets.all(10),
        );
      case DemoLayout.separated:
        return PageableListView<int, DemoItem>.separated(
          key: const Key('layout-separated'),
          controller: _controller,
          builderDelegate: _delegate,
          separatorStrategy: (index) => index.isEven,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        );
      case DemoLayout.grid:
        return PageableGridView<int, DemoItem>.builder(
          key: const Key('layout-grid'),
          controller: _controller,
          builderDelegate: _delegate,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
        );
      case DemoLayout.page:
        return PageablePageView<int, DemoItem>.builder(
          key: const Key('layout-page'),
          controller: _controller,
          builderDelegate: _delegate,
        );
      case DemoLayout.staggered:
        return PageableStaggeredView<int, DemoItem>.builder(
          key: const Key('layout-staggered'),
          controller: _controller,
          builderDelegate: _delegate,
          crossAxisCount: 2,
          padding: const EdgeInsets.all(10),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The same controller and delegate power each drop-in scrollable.',
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DemoLayout>(
                key: const Key('layout-selector'),
                initialValue: _layout,
                decoration: const InputDecoration(
                  labelText: 'Layout',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: DemoLayout.list,
                    child: Text('ListView'),
                  ),
                  DropdownMenuItem(
                    value: DemoLayout.separated,
                    child: Text('ListView.separated'),
                  ),
                  DropdownMenuItem(
                    value: DemoLayout.grid,
                    child: Text('GridView'),
                  ),
                  DropdownMenuItem(
                    value: DemoLayout.page,
                    child: Text('PageView'),
                  ),
                  DropdownMenuItem(
                    value: DemoLayout.staggered,
                    child: Text('Staggered / masonry'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _layout = value);
                },
              ),
            ],
          ),
        ),
        Expanded(child: _buildView()),
      ],
    );
  }
}
