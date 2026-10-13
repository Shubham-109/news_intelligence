import 'article.dart';

/// One page of articles, plus the paging details reported by the API.
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
