import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:news_intelligence/features/favorites/data/hive_favorites_repository.dart';
import 'package:news_intelligence/features/news/domain/article.dart';

void main() {
  late Directory directory;
  late Box<Map> box;
  late HiveFavoritesRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('favorites_test');
    Hive.init(directory.path);
    box = await Hive.openBox<Map>('favorites');
    repository = HiveFavoritesRepository(box);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await directory.delete(recursive: true);
  });

  final older = Article(
    id: 'older',
    title: 'Older story',
    section: 'Business',
    url: 'https://example.com/older',
    publishedAt: DateTime.utc(2026, 10, 1),
    summary: 'Summary',
    paragraphs: const ['First paragraph', 'Second paragraph'],
    author: 'Jane Doe',
    thumbnailUrl: 'https://example.com/older/500.jpg',
    imageUrl: 'https://example.com/older/1000.jpg',
    wordCount: 640,
  );

  final newer = Article(
    id: 'newer',
    title: 'Newer story',
    section: 'Technology',
    url: 'https://example.com/newer',
    publishedAt: DateTime.utc(2026, 10, 12),
  );

  test('stores the full article so it can be read offline', () async {
    await repository.save(older);

    final saved = repository.getAll().single;
    expect(saved.id, older.id);
    expect(saved.title, older.title);
    expect(saved.publishedAt, older.publishedAt);
    expect(saved.paragraphs, older.paragraphs);
    expect(saved.author, older.author);
    expect(saved.imageUrl, older.imageUrl);
    expect(saved.wordCount, older.wordCount);
  });

  test('lists the newest story first and survives reopening', () async {
    await repository.save(older);
    await repository.save(newer);
    await box.close();

    final reopened = HiveFavoritesRepository(
      await Hive.openBox<Map>('favorites'),
    );
    expect(
      [for (final article in reopened.getAll()) article.id],
      ['newer', 'older'],
    );
  });

  test('removes an article', () async {
    await repository.save(older);
    await repository.remove(older.id);

    expect(repository.getAll(), isEmpty);
  });
}
