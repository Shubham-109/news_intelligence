/// A news story, independent of the API it came from.
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

  /// Desk the story was filed under, such as "Business" or "World news".
  final String section;

  /// Link to the original story on the publisher's website.
  final String url;

  final DateTime publishedAt;
  final String summary;

  /// The full story as plain text paragraphs, ready to display.
  final List<String> paragraphs;

  final String? author;

  /// Small image for lists.
  final String? thumbnailUrl;

  /// Larger version of the same image for the article page.
  final String? imageUrl;

  final int wordCount;

  /// Estimated reading time at about 230 words a minute, or zero when the
  /// length is unknown.
  int get readingMinutes => (wordCount / 230).ceil();
}
