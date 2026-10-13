import 'article_page.dart';
import 'news_category.dart';

/// Source of news stories. Screens depend on this contract rather than on a
/// specific API, so the provider can change without touching the UI.
abstract interface class NewsRepository {
  /// Latest stories for [category], newest first.
  Future<ArticlePage> getHeadlines({
    required NewsCategory category,
    int page = 1,
  });
}
