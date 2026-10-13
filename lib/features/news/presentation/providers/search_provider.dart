import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/provider_cache.dart';
import '../../data/guardian_news_repository.dart';
import '../../domain/article_page.dart';
import '../../domain/news_category.dart';
import '../../domain/search_sort.dart';
import 'paged_articles.dart';
import 'paged_articles_notifier.dart';

@immutable
class SearchQuery {
  const SearchQuery({
    this.text = '',
    this.category,
    this.sort = SearchSort.relevance,
  });

  final String text;
  final NewsCategory? category;
  final SearchSort sort;

  bool get isSearchable => text.length >= 2;

  @override
  bool operator ==(Object other) {
    return other is SearchQuery &&
        other.text == text &&
        other.category == category &&
        other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(text, category, sort);
}

final searchQueryProvider =
    NotifierProvider.autoDispose<SearchQueryNotifier, SearchQuery>(
      SearchQueryNotifier.new,
    );

class SearchQueryNotifier extends Notifier<SearchQuery> {
  static final _whitespace = RegExp(r'\s+');

  @override
  SearchQuery build() => const SearchQuery();

  void setText(String text) {
    final normalized = text.trim().replaceAll(_whitespace, ' ');
    state = SearchQuery(
      text: normalized,
      category: state.category,
      sort: state.sort,
    );
  }

  void setCategory(NewsCategory? category) {
    state = SearchQuery(text: state.text, category: category, sort: state.sort);
  }

  void setSort(SearchSort sort) {
    state = SearchQuery(text: state.text, category: state.category, sort: sort);
  }
}

final searchResultsProvider = AsyncNotifierProvider.autoDispose
    .family<SearchResultsNotifier, PagedArticles, SearchQuery>(
      SearchResultsNotifier.new,
    );

class SearchResultsNotifier extends PagedArticlesNotifier {
  SearchResultsNotifier(this.query);

  final SearchQuery query;
  static const _debounce = Duration(milliseconds: 450);

  @override
  Future<PagedArticles> build() async {
    final repository = ref.watch(newsRepositoryProvider);

    await Future<void>.delayed(_debounce);
    if (!ref.mounted) throw Exception('Replaced by a newer search');

    final firstPage = await repository.searchArticles(
      query: query.text,
      category: query.category,
      sort: query.sort,
    );

    if (ref.mounted) ref.cacheFor(const Duration(minutes: 5));
    return PagedArticles.firstPage(firstPage);
  }

  @override
  Future<ArticlePage> fetchPage(int page) {
    return ref
        .read(newsRepositoryProvider)
        .searchArticles(
          query: query.text,
          category: query.category,
          sort: query.sort,
          page: page,
        );
  }
}
