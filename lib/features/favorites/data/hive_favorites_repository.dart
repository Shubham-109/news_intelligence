import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/storage/local_storage.dart';
import '../../news/domain/article.dart';
import '../domain/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => HiveFavoritesRepository(ref.watch(favoritesBoxProvider)),
);

class HiveFavoritesRepository implements FavoritesRepository {
  const HiveFavoritesRepository(this._box);

  final Box<Map> _box;

  @override
  List<Article> getAll() {
    return _box.values.map(_fromMap).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  @override
  Future<void> save(Article article) {
    return writeToStorage(() => _box.put(article.id, _toMap(article)));
  }

  @override
  Future<void> remove(String articleId) {
    return writeToStorage(() => _box.delete(articleId));
  }

  static Map<String, Object?> _toMap(Article article) {
    return {
      'id': article.id,
      'title': article.title,
      'section': article.section,
      'url': article.url,
      'publishedAt': article.publishedAt.toIso8601String(),
      'summary': article.summary,
      'paragraphs': article.paragraphs,
      'author': article.author,
      'thumbnailUrl': article.thumbnailUrl,
      'imageUrl': article.imageUrl,
      'wordCount': article.wordCount,
    };
  }

  static Article _fromMap(Map<dynamic, dynamic> map) {
    return Article(
      id: map['id'] as String,
      title: map['title'] as String,
      section: map['section'] as String,
      url: map['url'] as String,
      publishedAt: DateTime.parse(map['publishedAt'] as String),
      summary: map['summary'] as String,
      paragraphs: List<String>.from(map['paragraphs'] as List),
      author: map['author'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      imageUrl: map['imageUrl'] as String?,
      wordCount: map['wordCount'] as int,
    );
  }
}
