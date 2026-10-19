<div align="center">

# flutter_pageable

**Typed pagination controllers, drop-in scrollable views, and multi-source interleaved feeds for Flutter.**

[![pub package](https://img.shields.io/pub/v/flutter_pageable.svg?logo=dart&logoColor=white&color=0b2ab5)](https://pub.dev/packages/flutter_pageable)
[![tests](https://img.shields.io/badge/tests-440%2B%20passing-brightgreen.svg?logo=github)](https://github.com/hapnium/flutter_pageable)
[![dependencies](https://img.shields.io/badge/dependencies-zero%203rd--party-success.svg)](pubspec.yaml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20linux%20%7C%20windows-lightgrey)](https://pub.dev/packages/flutter_pageable)

</div>

<p align="left">
  <a href="#-features">Features</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-core-concepts">Core Concepts</a> •
  <a href="#-interleaved-multi-source-feeds">Interleaved Feeds</a> •
  <a href="#️-resilience--caching">Resilience & Caching</a> •
  <a href="#-bundled-utilities">Utilities</a> •
  <a href="#-testing">Testing</a>
</p>

---

`flutter_pageable` is a complete, zero-dependency pagination engine for Flutter. It handles everything from standard offset/cursor lists to complex multi-source interleaved feeds (e.g., weaving organic posts, ads, and suggestions into a single scroll view) with per-source error isolation, snapshot caching, exponential backoff retries, background polling, and pull-to-refresh.

```dart
import 'package:flutter_pageable/flutter_pageable.dart';
```

---

## ✨ Features

* **`PageableController<PageKey, Item>`** — A `ValueNotifier`-based controller that owns the full pagination lifecycle: fetching, duplicate-fetch deduplication, retry with backoff, polling, snapshot caching, and lifecycle-safe disposal. Page keys are strictly typed — use `int` offsets, `String` cursors, or custom composite keys.
* **Drop-in Scrollable Views** — `PageableListView`, `PageableGridView`, `PageablePageView`, and `PageableStaggeredView`, each wired directly to a controller and a builder delegate.
* **`PageableBuilderDelegate`** — A single declarative delegate for your item builder alongside dedicated widget slots for every pagination state: first-page loading, next-page loading, previous-page loading, all three error states, empty list, and end-of-list.
* **Interleaved Multi-Source Feeds** — `InterleavablePageableController` merges multiple independent paginated sources (feed + ads + suggestions) into one unified stream with strategy-driven ordering and **per-source error isolation**.
* **Caching, Retry & Polling** — Pluggable snapshot cache (`PageableCache`), configurable `maxRetries` / `retryDelay` / `retryIf` / `retryDelayBuilder`, and automatic interval polling that pauses when hidden.
* **Pull-to-Refresh** — `PullToRefresh` wrapper supporting Material, Cupertino, and custom indicator types.
* **Bundled Utilities** — `Optional`, primitive extension methods, `EqualsAndHashCode`, typed streams (`IntStream`, `DoubleStream`, `GenericStream`), and `Collector` helpers vendored directly so the package stands completely alone.

---

## 📦 Installation

Add `flutter_pageable` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_pageable: ^0.0.1
```

Fetch the package:

```sh
flutter pub get
```

---

## 🚀 Quick Start

### 1. Create a Controller

#### Integer Offset Pagination
```dart
final PageableController<int, Post> controller = PageableController<int, Post>(
  fetchPage: (page) => api.fetchPosts(page: page, limit: 20),
  getFirstPageKey: 1,
  getNextPageKey: (page, items, total) => items.length < 20 ? null : page + 1,
  pageSize: 20,
);
```

* `fetchPage` receives the current `PageKey` and returns `Future<List<Item>>` (synchronous `List<Item>` is also supported). Returning an empty list automatically marks the source as exhausted.
* `getNextPageKey` computes the next key, or returns `null` when no more pages remain.

#### Cursor-Based Pagination
Use `String` (or any custom type) as the `PageKey`:

```dart
final PageableController<String, Post> controller = PageableController<String, Post>(
  fetchPage: (cursor) => api.fetchPosts(after: cursor),
  getFirstPageKey: 'start',
  getNextPageKey: (cursor, items, total) => items.last.nextCursor, // null = done
  pageSize: 20,
);
```

### 2. Render the View

Wire the controller to `PageableListView` (or any other pageable view) with a `PageableBuilderDelegate`:

```dart
PageableListView<int, Post>(
  controller: controller,
  builderDelegate: PageableBuilderDelegate<Post>(
    itemBuilder: (context, metadata) => ListTile(
      title: Text(metadata.item.title),
      // Per-item context: index, isFirst, isLast, totalItems, isSelected
      subtitle: metadata.isLast ? const Text('You reached the end') : null,
    ),
    firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
    newPageProgressIndicatorBuilder: (context) => const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    ),
    firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('Could not load posts')),
    noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No posts yet')),
    noMoreItemsIndicatorBuilder: (context) => const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('No more posts')),
    ),
  ),
)
```

> **Automatic Prefetching:** The controller loads the first page automatically, prefetches upcoming pages as the user scrolls (`invisibleItemsThreshold` defaults to `3` items, or configure `percentageThreshold` of the viewport), and swaps state indicators seamlessly.

---

## 🧠 Core Concepts

### `PageableStatus` State Machine

Every controller, view, and delegate communicates through a deterministic 10-state lifecycle:

| Status | Meaning |
| :--- | :--- |
| `LOADING_FIRST_PAGE` | First page is currently being fetched. |
| `LOADED_PAGE` | A page loaded successfully; additional pages may be available. |
| `LOADING_NEW_PAGE` | The next (subsequent) page is being fetched. |
| `LOADING_PREVIOUS_PAGE` | An earlier page is being fetched (for bidirectional lists). |
| `NO_ITEMS_FOUND` | First page loaded successfully, but returned zero items. |
| `FIRST_PAGE_ERROR` | Fetching the first page failed. |
| `NEW_PAGE_ERROR` | Fetching a subsequent page failed (already-loaded items remain visible). |
| `PREVIOUS_PAGE_ERROR` | Fetching an earlier page failed. |
| `COMPLETED` | All available pages have been loaded. |
| `REFRESHING` | A full refresh is currently in progress. |

---

### `PageableView` Snapshot

`PageableController` extends `ValueNotifier<PageableView<PageKey, Item>>`, exposing an immutable state snapshot you can inspect or listen to anywhere:

```dart
controller.pageable;   // Full immutable PageableView<PageKey, Item> snapshot
controller.itemList;   // Flattened List<Item> across all loaded pages
controller.status;     // Current PageableStatus
controller.error;      // Most recent error object, if any
controller.hasData;    // True if at least one item is loaded
controller.isLoading;  // True if any loading state is active
```

---

### Controller Imperative API

Drive or override pagination programmatically at any time:

```dart
await controller.fetchFirstPage();
await controller.fetchNextPage();
await controller.fetchPreviousPage();  // Active when getPreviousPageKey is configured
await controller.refresh();            // Hard reset + refetch from first page
await controller.retry();              // Re-attempt failed page fetches
controller.clear();                    // Wipe all items and reset state
await controller.setEnabled(false);    // Pause automatic scroll-driven loading
```

---

### Built-in Scrollable Views

All four view widgets share the exact same `controller` + `builderDelegate` contract:

```dart
PageableListView<int, Post>(controller: controller, builderDelegate: delegate);
PageableGridView<int, Post>(controller: controller, builderDelegate: delegate);
PageablePageView<int, Post>(controller: controller, builderDelegate: delegate);
PageableStaggeredView<int, Post>(controller: controller, builderDelegate: delegate);
```

#### Conditional Separators (`PageableListView.separated`)
`PageableListView` includes a `.separated` constructor powered by an index-aware `PageableSeparatorStrategy`:

```dart
PageableListView<int, Post>.separated(
  controller: controller,
  builderDelegate: delegate,
  separatorStrategy: (index) => index.isEven, // Render a separator after even rows
  separatorBuilder: (context, index) => const Divider(height: 1),
)
```

---

## 🔀 Interleaved Multi-Source Feeds

Merge several independent paginated sources — each maintaining **its own cursor, page size, and error boundary** — into a single unified feed:

```
[ Feed Source (page 1, 20 items) ] ──┐
                                     ├──► [ InterleaveStrategy ] ──► [ Unified Scrollable UI ]
[ Ads Source  (page 1, 5 items)  ] ──┘
```

```dart
final feed = PageableSource<int, Post>(
  id: 'feed',
  fetchPage: (page) => api.fetchFeed(page: page),
  firstPageKey: 1,
  getNextPageKey: (key, items, total) => key + 1,
  pageSize: 20,
);

final ads = PageableSource<int, Post>(
  id: 'ads',
  fetchPage: (page) => api.fetchAds(page: page),
  firstPageKey: 1,
  getNextPageKey: (key, items, total) => key + 1,
  pageSize: 5,
  priority: 1, // Lower value = higher priority
);

final controller = InterleavablePageableController<int, Post>(
  strategy: RoundRobinInterleaveStrategy<Post>(itemsPerSource: 5),
  sources: [feed, ads],
);
```

The controller emits synthetic integer "batch" pages to the UI while each `PageableSource` manages its own pagination state internally.

### Runtime Source Management
Add, remove, or inspect sources on the fly:

```dart
controller.addSource(sponsored);   // Throws ArgumentError on duplicate source id
controller.removeSource('ads');    // Purges source items and re-interleaves immediately
controller.getSource('feed');      // Returns PageableSource<int, Post>?
controller.sourceIds;              // Returns List<String> of active source IDs
```

### Interleaving Strategies

| Strategy | Behavior |
| :--- | :--- |
| `RoundRobinInterleaveStrategy(itemsPerSource: n)` | Takes `n` items from each source in sequential rotation. |
| `PriorityInterleaveStrategy()` | Drains higher-priority sources first before pulling from lower-priority sources. |
| `CustomInterleaveStrategy(interleaveFn: …, routingFn: …)` | Supply custom merge ordering and next-fetch routing functions inline. |

Need deeper control? Implement `InterleaveStrategy<Item>` directly to customize both item ordering and which sources are selected for the next fetch (`selectSourcesForFetch`).

### Per-Source Failure Isolation
Each source owns an isolated error boundary: if `ads` fails while `feed` succeeds, `feed` items continue rendering normally, the error is surfaced via `controller.error`, and calling `controller.retry()` re-fetches **only** the failed sources.

---

## 🛡️ Resilience & Caching

### Snapshot Caching
Hydrate views immediately from a previous session and persist state automatically as pages load:

```dart
PageableController<int, Post>(
  fetchPage: fetch,
  getFirstPageKey: 1,
  pageSize: 20,
  cacheKey: 'posts_v1', // Enables the built-in in-memory snapshot cache
)
```

For persistent storage (`shared_preferences`, Hive, SQLite, etc.), pass a custom implementation of `PageableCache<PageKey, Item>` via the `cache:` parameter.

---

### Smart Retry & Backoff
Configure automatic retry policies with conditional filtering and custom backoff curves:

```dart
PageableController<int, Post>(
  fetchPage: fetch,
  getFirstPageKey: 1,
  pageSize: 20,
  maxRetries: 3,
  retryDelay: const Duration(seconds: 2),
  retryIf: (error) => error is! SocketException, // Skip non-recoverable errors
  retryDelayBuilder: (attempt) => Duration(seconds: attempt), // Linear/exponential backoff
  onRetryAttempt: (attempt, error, stack, delay) => log('Retry $attempt in $delay: $error'),
)
```

---

### Polling & Reload Keys
Keep feeds fresh automatically on an interval, or trigger full reloads reactively when filter/query keys change:

```dart
PageableController<int, Post>(
  fetchPage: fetch,
  getFirstPageKey: 1,
  pageSize: 20,
  pollInterval: const Duration(minutes: 1), // Auto-refresh interval
  pausePollingWhenHidden: true,             // Pause polling when widget/app is backgrounded
)

// Control polling manually or trigger reactive reloads:
controller.startPolling();
controller.stopPolling();
await controller.setReloadKey(DateTime.now()); // Wipes current state and refetches
```

---

### Pull-to-Refresh
Wrap any pageable view in `PullToRefresh` for Material, Cupertino, or custom refresh indicators:

```dart
PullToRefresh(
  onAsyncRefreshed: controller.refresh,
  refreshType: PullToRefreshType.material, // .material, .cupertino, or .custom
  // customIndicator: MyCustomRefreshIndicator(),
  child: PageableListView<int, Post>(
    controller: controller,
    builderDelegate: delegate,
  ),
)
```

---

### Debug Logging
Enable built-in controller lifecycle logs or inject a custom logger:

```dart
PageableController<int, Post>(
  fetchPage: fetch,
  getFirstPageKey: 1,
  pageSize: 20,
  showLog: true, // Or pass a custom PageableLogger via `logger:`
)
```

---

## 🧰 Bundled Utilities

Vendored from the `hapnium` toolkit and exported out of the box so `flutter_pageable` requires zero external dependencies:

```dart
// Null-safe Optional container
final name = Optional.ofNullable(user?.profile?.name).orElse('anonymous');

// String extensions
'Hello World'.snakeCase();   // 'hello_world'
'42'.isNumeric;              // true
''.isBlank();                // true

// Int / num extensions
12.toDigits(4);              // '0012' — throws FlutterPageableException when digits <= 0
3300.prettyFormat;           // '3.3k'

// Iterable / List extensions
[1, 2, 3].firstWhereOrNull((n) => n > 1);  // 2
[1, 2, 3].all((n) => n > 0);               // true
final first = [1, 2, 3].shift();           // Returns 1 — mutates list to [2, 3]

// Duration extensions
Duration(minutes: 5, seconds: 7).asTime;   // '05:07'

// Chunk a plain List into PageResults (ideal for unit tests & UI previews)
final pages = List.generate(100, (i) => 'item $i').buildPageablePages(pageSize: 25);
```

**Additional bundled helpers:**
* `RegexUtils` — Common pattern validation utilities.
* `Instance` — Runtime type checking helpers.
* `EqualsAndHashCode` — Value-equality mixin.
* Typed functional streams — `IntStream`, `DoubleStream`, `GenericStream`, and `Collector` aggregation helpers.

---

## 🧪 Testing

The package is backed by **440+ passing tests** covering controllers, interleaved feeds, strategies, state models, delegates, and utilities:

```sh
flutter test
```

Use `PageableController.fromPages` alongside `.buildPageablePages()` to seed deterministic paginated state in your own widget tests without mocking network calls:

```dart
final controller = PageableController<int, String>.fromPages(
  pages: ['a', 'b', 'c'].buildPageablePages(pageSize: 2),
  fetchPage: (_) async => [],
  getFirstPageKey: 0,
  pageSize: 2,
);
```

---

## 📄 License

See [`LICENSE`](LICENSE) in this repository.