import 'package:flutter/material.dart';

const demoPageSize = 6;

class DemoItem {
  const DemoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.source,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String source;
  final Color color;
}

class DemoRepository {
  bool _failNextFeedRequest = false;
  bool failAds = false;

  void failNextFeedRequest() {
    _failNextFeedRequest = true;
  }

  Future<List<DemoItem>> fetchFeedPage(
    int page, {
    required String category,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    if (_failNextFeedRequest) {
      _failNextFeedRequest = false;
      throw StateError('A one-time demo request failure');
    }

    final filtered = _feedItems
        .where((item) => category == 'All' || item.category == category)
        .toList();
    final start = (page - 1) * demoPageSize;
    if (start >= filtered.length) return [];
    return filtered.skip(start).take(demoPageSize).toList();
  }

  Future<List<DemoItem>> fetchSourcePage(String source, int page) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    if (source == 'sponsored' && failAds) {
      failAds = false;
      throw StateError('Sponsored source failed once');
    }
    final entries = _itemsForSource(source);
    final start = (page - 1) * 4;
    if (start >= entries.length) return [];
    return entries.skip(start).take(4).toList();
  }

  Future<List<DemoItem>> fetchCursorPage(String cursor) async {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    final page = switch (cursor) {
      'start' => 0,
      'after-3' => 1,
      'after-6' => 2,
      _ => 3,
    };
    return _cursorItems.skip(page * 3).take(3).toList();
  }

  static final _cursorItems = List.generate(
    8,
    (index) => DemoItem(
      id: 'cursor-${index + 1}',
      title: 'Cursor result ${index + 1}',
      description:
          'Fetched with a String page key instead of an integer offset.',
      category: 'Cursor',
      source: 'Cursor API',
      color: const Color(0xFFE7EEFF),
    ),
  );

  static final _feedItems = List.generate(24, (index) {
    final categories = const ['Design', 'Engineering', 'Product'];
    final category = categories[index % categories.length];
    return DemoItem(
      id: 'feed-${index + 1}',
      title: '$category story ${index + 1}',
      description:
          'A locally generated example item for page ${(index ~/ demoPageSize) + 1}.',
      category: category,
      source: 'Community',
      color: _colors[index % _colors.length],
    );
  });

  static List<DemoItem> _itemsForSource(String source) {
    final count = source == 'sponsored' ? 8 : 16;
    return List.generate(count, (index) {
      final isAd = source == 'sponsored';
      return DemoItem(
        id: '$source-${index + 1}',
        title: isAd
            ? 'Partner pick ${index + 1}'
            : '${source[0].toUpperCase()}${source.substring(1)} item ${index + 1}',
        description: isAd
            ? 'Sponsored content, kept in its own paging source.'
            : 'Interleaved from the $source source.',
        category: isAd ? 'Sponsored' : source,
        source: source,
        color: isAd ? const Color(0xFFFFF1D6) : _colors[index % _colors.length],
      );
    });
  }

  static const _colors = [
    Color(0xFFE7EEFF),
    Color(0xFFE5F5EF),
    Color(0xFFFFE9E5),
    Color(0xFFF2E9FF),
    Color(0xFFFFF4D6),
    Color(0xFFE5F2F9),
  ];
}

class DemoItemCard extends StatelessWidget {
  const DemoItemCard({required this.item, this.index, super.key});

  final DemoItem item;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.color,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (index != null)
                  Text(
                    '#${index! + 1}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(item.source),
              avatar: const Icon(Icons.layers_outlined, size: 15),
            ),
          ],
        ),
      ),
    );
  }
}
