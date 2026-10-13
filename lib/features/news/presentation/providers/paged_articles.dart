import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/article.dart';
import '../../domain/article_page.dart';

/// Articles loaded so far for an endless list, plus the paging status.
@immutable
class PagedArticles {
  const PagedArticles({
    required this.articles,
    required this.page,
    required this.hasMore,
    required this.totalResults,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  factory PagedArticles.firstPage(ArticlePage page) {
    return PagedArticles(
      articles: page.articles,
      page: page.page,
      hasMore: page.hasMore,
      totalResults: page.totalResults,
    );
  }

  final List<Article> articles;
  final int page;
  final bool hasMore;
  final int totalResults;
  final bool isLoadingMore;

  /// Why the last attempt to load the next page failed. The articles already
  /// on screen stay visible.
  final Failure? loadMoreError;

  PagedArticles loadingMore() => _withStatus(isLoadingMore: true);

  PagedArticles loadMoreFailed(Failure error) {
    return _withStatus(loadMoreError: error);
  }

  /// Adds the next page. Stories can shift between pages while new ones are
  /// published, so anything already in the list is skipped.
  PagedArticles append(ArticlePage next) {
    final seenIds = {for (final article in articles) article.id};
    return PagedArticles(
      articles: [
        ...articles,
        ...next.articles.where((article) => seenIds.add(article.id)),
      ],
      page: next.page,
      hasMore: next.hasMore,
      totalResults: next.totalResults,
    );
  }

  PagedArticles _withStatus({
    bool isLoadingMore = false,
    Failure? loadMoreError,
  }) {
    return PagedArticles(
      articles: articles,
      page: page,
      hasMore: hasMore,
      totalResults: totalResults,
      isLoadingMore: isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }
}
