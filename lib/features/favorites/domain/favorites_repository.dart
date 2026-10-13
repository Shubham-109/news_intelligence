import '../../news/domain/article.dart';

abstract interface class FavoritesRepository {
  List<Article> getAll();

  Future<void> save(Article article);

  Future<void> remove(String articleId);
}
