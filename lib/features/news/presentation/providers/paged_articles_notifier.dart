import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../domain/article_page.dart';
import 'paged_articles.dart';

abstract class PagedArticlesNotifier extends AsyncNotifier<PagedArticles> {
  Future<ArticlePage> fetchPage(int page);

  Future<void> refresh() async {
    final firstPage = await fetchPage(1);
    if (!ref.mounted) return;
    state = AsyncData(PagedArticles.firstPage(firstPage));
  }

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

  bool _isStale(PagedArticles snapshot) {
    return !ref.mounted || !identical(state.value, snapshot);
  }
}
