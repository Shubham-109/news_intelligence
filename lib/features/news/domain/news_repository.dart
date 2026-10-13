import 'article_page.dart';
import 'news_category.dart';
import 'search_sort.dart';

/// Source of news stories. Screens depend on this contract rather than on a
/// specific API, so the provider can change without touching the UI.
abstract interface class NewsRepository {
  /// Latest stories for [category], newest first.
  Future<ArticlePage> getHeadlines({
    required NewsCategory category,
    int page = 1,
  });

  /// Stories matching [query], optionally limited to one desk.
  Future<ArticlePage> searchArticles({
    required String query,
    NewsCategory? category,
    SearchSort sort = SearchSort.relevance,
    int page = 1,
  });
}
