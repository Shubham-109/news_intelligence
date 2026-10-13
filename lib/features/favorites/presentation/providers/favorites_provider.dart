import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../news/domain/article.dart';
import '../../data/hive_favorites_repository.dart';

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Article>>(
  FavoritesNotifier.new,
);

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
