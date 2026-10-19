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
