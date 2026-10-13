import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/error/failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/article_page.dart';
import '../domain/news_category.dart';
import '../domain/news_repository.dart';
import 'article_model.dart';

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => GuardianNewsRepository(ref.watch(apiClientProvider)),
);

/// [NewsRepository] backed by the search endpoint of The Guardian Open
/// Platform.
class GuardianNewsRepository implements NewsRepository {
  const GuardianNewsRepository(this._client);

  final ApiClient _client;

  /// Asking for the body up front means the article page and offline
  /// favorites never need a second request.
  static const _fields = 'headline,trailText,byline,thumbnail,wordcount,body';

  /// Keeps results to written articles, leaving out live blogs, galleries,
  /// video and audio.
  static const _articlesOnly = 'type/article';

  @override
  Future<ArticlePage> getHeadlines({
    required NewsCategory category,
    int page = 1,
  }) {
    return _search(category: category, orderBy: 'newest', page: page);
  }

  Future<ArticlePage> _search({
    required NewsCategory category,
    required String orderBy,
    required int page,
  }) async {
    final json = await _client.get(
      '/search',
      queryParameters: {
        ..._filterFor(category),
        'order-by': orderBy,
        'page': page,
        'page-size': ApiConfig.pageSize,
        'show-fields': _fields,
      },
    );
    return _parsePage(json);
  }

  /// Guardian filters behind each desk. A comma combines tags with AND.
  static Map<String, String> _filterFor(NewsCategory category) {
    return switch (category) {
      NewsCategory.business => {'section': 'business', 'tag': _articlesOnly},
      NewsCategory.markets => {'tag': 'business/stock-markets,$_articlesOnly'},
      NewsCategory.economy => {'tag': 'business/economics,$_articlesOnly'},
      NewsCategory.banking => {'tag': 'business/banking,$_articlesOnly'},
      NewsCategory.energy => {'tag': 'business/energy-industry,$_articlesOnly'},
      NewsCategory.technology => {
        'section': 'technology',
        'tag': _articlesOnly,
      },
    };
  }

  ArticlePage _parsePage(Map<String, dynamic> json) {
    try {
      final response = json['response'] as Map<String, dynamic>;
      final results = response['results'] as List<dynamic>;
      return ArticlePage(
        articles: [
          for (final item in results)
            ArticleModel.fromJson(item as Map<String, dynamic>),
        ],
        page: response['currentPage'] as int,
        totalPages: response['pages'] as int,
        totalResults: response['total'] as int,
      );
    } on TypeError {
      // The payload did not have the shape the API documents.
      throw const ServerFailure();
    } on FormatException {
      throw const ServerFailure();
    }
  }
}
