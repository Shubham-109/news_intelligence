import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_intelligence/core/error/failure.dart';
import 'package:news_intelligence/features/news/data/guardian_news_repository.dart';
import 'package:news_intelligence/features/news/domain/article.dart';
import 'package:news_intelligence/features/news/domain/article_page.dart';
import 'package:news_intelligence/features/news/domain/news_category.dart';
import 'package:news_intelligence/features/news/domain/news_repository.dart';
import 'package:news_intelligence/features/news/domain/search_sort.dart';
import 'package:news_intelligence/features/news/presentation/providers/feed_provider.dart';

Article _article(String id) {
  return Article(
    id: id,
    title: 'Story $id',
    section: 'Business',
    url: 'https://example.com/$id',
    publishedAt: DateTime.utc(2026, 10, 13),
  );
}

ArticlePage _page(int page, List<String> ids, {int totalPages = 3}) {
  return ArticlePage(
    articles: [for (final id in ids) _article(id)],
    page: page,
    totalPages: totalPages,
    totalResults: totalPages * 2,
  );
}

/// Serves canned pages, and can be told to fail or stall a request.
class _FakeNewsRepository implements NewsRepository {
  final pages = <int, ArticlePage>{};
  final failingPages = <int>{};
  final stalledPages = <int, Completer<ArticlePage>>{};

  @override
  Future<ArticlePage> getHeadlines({
    required NewsCategory category,
    int page = 1,
  }) async {
    if (failingPages.contains(page)) throw const NetworkFailure();
    if (stalledPages[page] case final stall?) return stall.future;
    return pages[page]!;
  }

  @override
  Future<ArticlePage> searchArticles({
    required String query,
    NewsCategory? category,
    SearchSort sort = SearchSort.relevance,
    int page = 1,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeNewsRepository repository;
  late ProviderContainer container;
  final provider = feedProvider(NewsCategory.markets);

  setUp(() {
    repository = _FakeNewsRepository()
      ..pages[1] = _page(1, ['a', 'b'])
      ..pages[2] = _page(2, ['b', 'c']);
    container = ProviderContainer.test(
      overrides: [newsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  List<String> loadedIds() {
    return [
      for (final article in container.read(provider).requireValue.articles)
        article.id,
    ];
  }

  test('loads the first page', () async {
    final feed = await container.read(provider.future);

    expect(loadedIds(), ['a', 'b']);
    expect(feed.hasMore, isTrue);
  });

  test('appends the next page and skips stories already shown', () async {
    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();

    expect(loadedIds(), ['a', 'b', 'c']);
    expect(container.read(provider).requireValue.page, 2);
  });

  test('keeps the list when the next page fails', () async {
    repository.failingPages.add(2);
    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();

    final feed = container.read(provider).requireValue;
    expect(loadedIds(), ['a', 'b']);
    expect(feed.loadMoreError, isA<NetworkFailure>());
    expect(feed.isLoadingMore, isFalse);
  });

  test('drops a page that arrives after a refresh', () async {
    final stalledPage = Completer<ArticlePage>();
    repository.stalledPages[2] = stalledPage;
    await container.read(provider.future);

    final loadingMore = container.read(provider.notifier).loadMore();
    repository.pages[1] = _page(1, ['x', 'y']);
    await container.read(provider.notifier).refresh();
    stalledPage.complete(_page(2, ['z']));
    await loadingMore;

    expect(loadedIds(), ['x', 'y']);
  });
}
