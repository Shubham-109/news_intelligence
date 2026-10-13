import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../news/domain/article.dart';
import '../../data/hive_favorites_repository.dart';

/// Saved articles, newest story first. Every change is written to Hive
/// straight away, so the list survives restarts and works offline.
final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Article>>(
  FavoritesNotifier.new,
);

/// Whether the article with the given id is saved.
final isFavoriteProvider = Provider.autoDispose.family<bool, String>(
  (ref, articleId) =>
      ref.watch(favoritesProvider).any((article) => article.id == articleId),
);

class FavoritesNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() => ref.watch(favoritesRepositoryProvider).getAll();

  Future<void> add(Article article) async {
    final repository = ref.read(favoritesRepositoryProvider);
    await repository.save(article);
    state = repository.getAll();
  }

  /// Takes [article] out of the list at once, so a swiped row disappears
  /// immediately, then removes it from storage. The list is restored if the
  /// write fails.
  Future<void> remove(Article article) async {
    final previous = state;
    state = [
      for (final saved in state)
        if (saved.id != article.id) saved,
    ];
    try {
      await ref.read(favoritesRepositoryProvider).remove(article.id);
    } on Failure {
      state = previous;
      rethrow;
    }
  }

  /// Saves [article], or removes it when it is already saved. Returns whether
  /// the article ends up saved.
  Future<bool> toggle(Article article) async {
    final isSaved = state.any((saved) => saved.id == article.id);
    if (isSaved) {
      await remove(article);
    } else {
      await add(article);
    }
    return !isSaved;
  }
}
