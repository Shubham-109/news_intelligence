import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/guardian_news_repository.dart';
import '../../domain/article_page.dart';
import '../../domain/news_category.dart';
import 'paged_articles.dart';
import 'paged_articles_notifier.dart';

final feedProvider =
    AsyncNotifierProvider.family<FeedNotifier, PagedArticles, NewsCategory>(
      FeedNotifier.new,
    );

class FeedNotifier extends PagedArticlesNotifier {
  FeedNotifier(this.category);

  final NewsCategory category;

  @override
  Future<PagedArticles> build() async {
    final repository = ref.watch(newsRepositoryProvider);
    final firstPage = await repository.getHeadlines(category: category);
    return PagedArticles.firstPage(firstPage);
  }

  @override
  Future<ArticlePage> fetchPage(int page) {
    return ref
        .read(newsRepositoryProvider)
        .getHeadlines(category: category, page: page);
  }
}
