## 0.0.3

* **Breaking:** `PageableController.refresh()` is now a hard refresh. It clears
  loaded pages, cursors, and errors immediately, sets
  `PageableStatus.LOADING_FIRST_PAGE`, and then loads the first page exactly
  like an initial load. A failed refresh now resolves to `FIRST_PAGE_ERROR`
  instead of preserving the previous items.
* Added `PageableController.refreshSilently()` for the previous behavior:
  existing items stay visible behind `PageableStatus.REFRESHING` while the
  first page is re-fetched, and are preserved if the refresh fails.
* Automatic polling, non-reset `setReloadKey()` reloads, and cache hydration now
  use `refreshSilently()` so background updates no longer flash the first-load
  UI.
* Added the same `refresh()` / `refreshSilently()` split to
  `InterleavablePageableController`, with hard refresh clearing the interleaved
  feed before re-fetching all sources.
* Fixed an off-by-one bug in `PageableStaggeredView` where `baseItemCount` was
  calculated as `widgetBuilder != null ? count - 1 : count`. Once a page
  completed, `PageableBuilder` supplied `noMoreItemsBuilder`, making
  `widgetBuilder != null` and reducing `baseItemCount` to `0`, which discarded
  the loaded item(s). `baseItemCount` is now always `count`, matching the fix
  previously applied to `PageableGridView` and `PageablePageView`.
* Updated controller tests and documentation for the new refresh semantics.

## 0.0.2

* Added a runnable Flutter showcase in [`example/`](example/) with
  deterministic local data and web support. It demonstrates the pageable
  views, typed offset and cursor pagination, bidirectional loading, state
  indicators, retry, refresh, caching, polling, reload keys, interleaved
  sources and strategies, runtime source management, failure isolation, and
  bundled helpers.
* Added widget tests for the example app's feed/error/retry flow, five view
  layouts, interleaved source management and isolated source retry, and cursor
  and utility demonstrations.
* Exported `BigInteger`, `Uuid`, `UuidRangeBuilder`,
  `MathUuidRangeBuilder`, and `CryptoUuidRangeBuilder` from the package entry
  point. These provide arbitrary-precision arithmetic and UUID parsing,
  validation, serialization, random/time/name-based generation, namespaces,
  and configurable byte generation.
* Added a unique UUID identity to each `PageableController`; controller
  equality now distinguishes instances, and controller/interleaved-controller
  log tags identify their instance.
* Added controller identity tests and math/UUID tests.
* Verified 464 package tests and all 4 example-app widget tests pass.

## 0.0.1

* Initial standalone release of `flutter_pageable`, extracted from `smart`.
* **`PageableController<PageKey, Item>`** — typed pagination controller with
  first/next/previous page fetching, refresh, retry with backoff, polling,
  snapshot caching and lifecycle-safe disposal.
* **Views** — `PageableListView` (incl. `.separated`), `PageableGridView`,
  `PageablePageView` and `PageableStaggeredView`, driven by a
  `PageableBuilderDelegate` with indicators for every pagination state.
* **Interleaved feeds** — `InterleavablePageableController` merges multiple
  `PageableSource`s into one feed via `InterleaveStrategy`
  (round-robin, priority, or custom) with per-source error isolation.
* **`PullToRefresh`** — Material / Cupertino / custom refresh indicators.
* Bundled utilities vendored from `hapnium`: `Optional`, primitive
  extensions, typed streams, `Collector`, `RegexUtils` and
  `EqualsAndHashCode`.
* 440+ passing tests covering controllers, strategies, models, delegates
  and utilities.