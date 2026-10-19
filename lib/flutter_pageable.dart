/// {@template flutter_pageable}
/// # flutter_pageable
///
/// Pagination for Flutter: typed page controllers, scrollable views,
/// multi-source interleaved feeds, caching, retry, polling and
/// pull-to-refresh — with zero third-party dependencies beyond Flutter
/// itself and `meta`.
///
/// ## Import
///
/// ```dart
/// import 'package:flutter_pageable/flutter_pageable.dart';
/// ```
///
/// ## Core concepts
///
/// - **[PageableController]** — a `ValueNotifier` over a [PageableView]
///   that owns fetching, deduplication, retry, polling and caching for a
///   single paginated stream. Generic over `<PageKey, Item>` so page keys
///   can be `int` offsets, `String` cursors, or anything else.
/// - **[PageableView]** — the immutable state: loaded [PageResult]s,
///   current [PageableStatus], cursors and the last error.
/// - **[PageResult]** — one fetched page: a `[PageKey]` plus its items.
/// - **[PageableStatus]** — the unified loading/error/completed state
///   machine shared by controllers, views and delegates.
///
/// ## Views
///
/// Drop-in scrollables that listen to a [PageableController] and render
/// items, loading indicators and errors:
///
/// - [PageableListView]
/// - [PageableGridView]
/// - [PageablePageView]
/// - [PageableStaggeredView]
///
/// Each takes a [PageableBuilderDelegate], which defines the item builder
/// plus optional widgets for every pagination state (first-page loading,
/// next-page loading, errors, empty list, end-of-list).
///
/// ## Interleaved multi-source feeds
///
/// [InterleavablePageableController] merges several independent
/// [PageableSource]s — each with its own pagination cursor — into one
/// unified feed, driven by an [InterleaveStrategy] such as
/// [RoundRobinInterleaveStrategy], [PriorityInterleaveStrategy] or
/// [CustomInterleaveStrategy]. Per-source errors are isolated, so one
/// failing source never blanks the others.
///
/// ## Utilities
///
/// The package also bundles a small set of utilities it was built on,
/// free to use:
///
/// - [Optional] — null-safe container with `map`/`flatMap`/`filter`/`orElse`
/// - Extension methods on primitives ([IntExtensions], [StringExtensions],
///   [ListExtensions], [MapExtensions], …)
/// - Stream helpers ([IntStream], [DoubleStream], [GenericStream]) and
///   [Collector] for reduce-style aggregation
/// - [PageableLogger] for opt-in debug logging (`showLog: true`)
/// - [PageableSeparatorStrategy] for index-aware separators
/// {@endtemplate}
library;

// ─────────────────────────────────────────────────────────────────
// 🧩 MODELS — the pagination state machine
// ─────────────────────────────────────────────────────────────────

/// [PageableView] — the immutable, `Listenable` pagination state.
export 'src/models/pageable.dart';

/// [PageResult] — a single fetched page (`pageKey` + `items`).
export 'src/models/page_result.dart';

/// [PageableStatus] — unified loading/error/completed states.
export 'src/models/pageable_status.dart';

/// [PageableCache] — pluggable snapshot storage (hydrate + persist).
export 'src/models/pageable_cache.dart' hide InMemoryPageableCache;

/// [ItemMetadata] — per-item context (`index`, `isFirst`, `isLast`, …)
/// handed to item builders.
export 'src/models/item_metadata.dart';

/// [PageableBuilderDelegate] — item builder + per-state indicators.
export 'src/models/pageable_builder_delegate.dart';

/// [FloatingConfig] — floating-overlay configuration used by the views.
export 'src/models/floating_config.dart';

/// [Collector] — reduce-style aggregation helpers.
export 'src/models/collector.dart';

// ─────────────────────────────────────────────────────────────────
// 🎛 CONTROLLERS — fetching, retry, polling, caching
// ─────────────────────────────────────────────────────────────────

/// [PageableController] — the core `<PageKey, Item>` pagination
/// controller (`fetchFirstPage`, `fetchNextPage`, `fetchPreviousPage`,
/// `refresh`, `retry`, polling, caching, safe-mode guards).
export 'src/controller/pageable_controller.dart';

/// Convenience extensions on controllers and page results
/// (e.g. building [PageResult]s from plain lists).
export 'src/controller/extensions.dart';

// ─────────────────────────────────────────────────────────────────
// 🔀 INTERLEAVED FEEDS — multiple sources, one list
// ─────────────────────────────────────────────────────────────────

/// [InterleavablePageableController] — merges several paginated sources
/// into a single synthetic feed with per-source error isolation.
export 'src/controller/interleavable_pageable_controller.dart';

/// [PageableSource] — a lightweight, self-contained paginated source
/// (fetch callback + first key + next-key generator).
export 'src/models/pageable_source.dart';

/// [InterleavedSourceState] — immutable per-source snapshot passed to
/// strategies.
export 'src/models/interleaved_source_state.dart';

/// [InterleaveStrategy] and the built-in strategies:
/// [RoundRobinInterleaveStrategy], [PriorityInterleaveStrategy],
/// [CustomInterleaveStrategy].
export 'src/controller/interleave_strategy.dart';

// ─────────────────────────────────────────────────────────────────
// 🧱 BUILDERS — internal layout plumbing shared by the views
// ─────────────────────────────────────────────────────────────────

/// [PageableBuilder] — renders items and indicators from a delegate.
export 'src/builders/pageable_builder.dart';

/// [PageableLayoutBuilder] — wires controller state to slivers/layout.
export 'src/builders/pageable_layout_builder.dart';

/// [PageableListener] — listen to pagination notifications in-tree.
export 'src/builders/pageable_listener.dart';

// ─────────────────────────────────────────────────────────────────
// 📜 VIEWS — drop-in paginated scrollables
// ─────────────────────────────────────────────────────────────────

/// [PageableListView] — paginated `ListView` (plus `.separated`).
export 'src/types/pageable_list_view.dart';

/// [PageableGridView] — paginated `GridView`.
export 'src/types/pageable_grid_view.dart';

/// [PageablePageView] — paginated `PageView`.
export 'src/types/pageable_page_view.dart';

/// [PageableStaggeredView] — paginated staggered/masonry grid.
export 'src/types/pageable_staggered_view.dart';

// ─────────────────────────────────────────────────────────────────
// 🔄 PULL TO REFRESH
// ─────────────────────────────────────────────────────────────────

/// [PullToRefresh] — refresh indicator wrapper (Material/Cupertino/
/// custom via [PullToRefreshType]).
export 'src/pull_to_refresh/pull_to_refresh.dart';

/// [PullToRefreshType] — refresh indicator variants.
export 'src/pull_to_refresh/pull_to_refresh_type.dart';

// ─────────────────────────────────────────────────────────────────
// 🧰 SUPPORT — logging, separators, exceptions
// ─────────────────────────────────────────────────────────────────

/// [PageableLogger] — opt-in logging interface. Provide your own, or set
/// `showLog: true` on a controller to use the built-in console logger.
export 'src/helpers/pageable_logger.dart' hide ConsolePageableLogger;

/// [PageableSeparatorStrategy] — decide per index whether a separator
/// row should be rendered in `.separated` views.
export 'src/helpers/pageable_helper.dart' show PageableSeparatorStrategy;

/// [FlutterPageableException] — the package's exception type.
export 'src/flutter_pageable_exception.dart';

// ─────────────────────────────────────────────────────────────────
// 🔧 BUNDLED UTILITIES
//
// A curated subset of the `hapnium` toolkit that this package was
// built on, vendored so the package stands alone.
// ─────────────────────────────────────────────────────────────────

/// [Optional] — null-safe container (`of`, `map`, `flatMap`, `filter`,
/// `orElse`, `orElseThrow`, …).
export 'src/classes/optional.dart';

/// Paging primitives ([Page], [PageSlice], [Pageable],
/// [AbstractPageRequest]) for backend-style page metadata.
export 'src/classes/paging.dart';

/// Stream foundations used by the typed streams below.
export 'src/classes/base_stream.dart';
export 'src/classes/stream_support.dart';

/// Typed stream helpers: [IntStream], [DoubleStream], [GenericStream]
/// (and their internal implementations).
export 'src/classes/int/int_stream.dart';
export 'src/classes/int/_int_stream.dart';
export 'src/classes/double/double_stream.dart';
export 'src/classes/double/_double_stream.dart';
export 'src/classes/generic/generic_stream.dart';
export 'src/classes/generic/_generic_stream.dart';

// ▸ Primitive extensions
export 'src/extensions/primitives/string.dart';
export 'src/extensions/primitives/bool.dart';
export 'src/extensions/primitives/int.dart';
export 'src/extensions/primitives/double.dart';
export 'src/extensions/primitives/num.dart';
export 'src/extensions/primitives/list.dart';
export 'src/extensions/primitives/map.dart';
export 'src/extensions/primitives/iterable.dart';
export 'src/extensions/primitives/pageable.dart';

// ▸ Other extensions
export 'src/extensions/others/dynamic.dart';
export 'src/extensions/others/t.dart';
export 'src/extensions/others/duration.dart';
export 'src/extensions/others/date_time.dart';

// ▸ Helpers
export 'src/helpers/instance.dart';
export 'src/helpers/regex_utils.dart';
export 'src/helpers/typedefs.dart';
export 'src/helpers/equals_and_hash_code.dart';
export 'src/helpers/to_string.dart';
