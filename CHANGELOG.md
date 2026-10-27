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