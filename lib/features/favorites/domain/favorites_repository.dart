import '../../news/domain/article.dart';

/// Articles the user saved to read later, kept on the device so they are
/// available offline.
abstract interface class FavoritesRepository {
  /// Every saved article, newest story first.
  List<Article> getAll();

  Future<void> save(Article article);

  Future<void> remove(String articleId);
}
