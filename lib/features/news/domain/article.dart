class Article {
  const Article({
    required this.id,
    required this.title,
    required this.section,
    required this.url,
    required this.publishedAt,
    this.summary = '',
    this.paragraphs = const [],
    this.author,
    this.thumbnailUrl,
    this.imageUrl,
    this.wordCount = 0,
  });

  final String id;
  final String title;
  final String section;
  final String url;
  final DateTime publishedAt;
  final String summary;
  final List<String> paragraphs;
  final String? author;
  final String? thumbnailUrl;
  final String? imageUrl;
  final int wordCount;

  int get readingMinutes => (wordCount / 230).ceil();
}
