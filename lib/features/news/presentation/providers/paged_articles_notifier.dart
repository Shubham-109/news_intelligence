import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../domain/article_page.dart';
import 'paged_articles.dart';

/// Paging behaviour shared by every list that loads articles page by page.
abstract class PagedArticlesNotifier extends AsyncNotifier<PagedArticles> {
  /// Loads a single page of articles.
  Future<ArticlePage> fetchPage(int page);

  /// Reloads the first page. The current articles stay on screen until the
  /// new ones arrive, and a failure is rethrown so the caller can report it.
  Future<void> refresh() async {
    final firstPage = await fetchPage(1);
    if (!ref.mounted) return;
    state = AsyncData(PagedArticles.firstPage(firstPage));
  }

  /// Appends the next page. Does nothing while the list is loading or once
  /// every page has been loaded.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        state.isLoading ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    final loading = current.loadingMore();
    state = AsyncData(loading);
    try {
      final next = await fetchPage(current.page + 1);
      if (_isStale(loading)) return;
      state = AsyncData(loading.append(next));
    } on Failure catch (error) {
      if (_isStale(loading)) return;
      state = AsyncData(loading.loadMoreFailed(error));
    }
  }

  /// Whether the list was refreshed or disposed while a page was loading. The
  /// page then belongs to an older list and is dropped.
  bool _isStale(PagedArticles snapshot) {
    return !ref.mounted || !identical(state.value, snapshot);
  }
}
