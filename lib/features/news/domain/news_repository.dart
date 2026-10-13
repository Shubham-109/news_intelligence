import 'article_page.dart';
import 'news_category.dart';
import 'search_sort.dart';

abstract interface class NewsRepository {
  Future<ArticlePage> getHeadlines({
    required NewsCategory category,
    int page = 1,
  });

  Future<ArticlePage> searchArticles({
    required String query,
    NewsCategory? category,
    SearchSort sort = SearchSort.relevance,
    int page = 1,
  });
}
