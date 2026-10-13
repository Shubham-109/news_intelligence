import 'article.dart';

class ArticlePage {
  const ArticlePage({
    required this.articles,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  final List<Article> articles;
  final int page;
  final int totalPages;
  final int totalResults;

  bool get hasMore => page < totalPages;
}
