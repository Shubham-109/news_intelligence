import 'package:html/parser.dart' show parseFragment;

import '../domain/article.dart';

/// Builds an [Article] from a content item returned by The Guardian API.
class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.section,
    required super.url,
    required super.publishedAt,
    super.summary,
    super.paragraphs,
    super.author,
    super.thumbnailUrl,
    super.imageUrl,
    super.wordCount,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final fields = json['fields'] as Map<String, dynamic>? ?? const {};
    final thumbnail = fields['thumbnail'] as String?;
    final byline = fields['byline'] as String?;

    return ArticleModel(
      id: json['id'] as String,
      title: _plainText(
        fields['headline'] as String? ?? json['webTitle'] as String,
      ),
      section: json['sectionName'] as String? ?? '',
      url: json['webUrl'] as String,
      publishedAt: DateTime.parse(json['webPublicationDate'] as String),
      summary: _plainText(fields['trailText'] as String? ?? ''),
      paragraphs: _paragraphs(fields['body'] as String? ?? ''),
      author: byline == null || byline.isEmpty ? null : byline,
      thumbnailUrl: thumbnail,
      imageUrl: thumbnail?.replaceFirst(_thumbnailWidth, '/1000.jpg'),
      wordCount: int.tryParse(fields['wordcount'] as String? ?? '') ?? 0,
    );
  }

  /// Guardian image links end in the rendered width, so the same crop can be
  /// requested at 1000 pixels for the article page.
  static final _thumbnailWidth = RegExp(r'/500\.jpg$');

  static final _lineBreak = RegExp(r'<br\s*/?>');
  static final _spaces = RegExp(r'[ \t\u00A0]+');

  static String _plainText(String html) {
    return _tidy(parseFragment(html).text ?? '');
  }

  /// Turns body HTML into plain paragraphs. Only top level text blocks are
  /// kept, which leaves out embedded media, captions and related links.
  static List<String> _paragraphs(String html) {
    if (html.isEmpty) return const [];

    final fragment = parseFragment(html.replaceAll(_lineBreak, '\n'));
    final blocks = <String>[];
    for (final element in fragment.children) {
      switch (element.localName) {
        case 'p' || 'h2' || 'h3' || 'blockquote':
          blocks.add(element.text);
        case 'ul' || 'ol':
          blocks.addAll(element.children.map((item) => '• ${item.text}'));
      }
    }
    return blocks.map(_tidy).where((text) => text.isNotEmpty).toList();
  }

  /// Collapses repeated spaces while keeping intentional line breaks.
  static String _tidy(String text) {
    return text
        .split('\n')
        .map((line) => line.replaceAll(_spaces, ' ').trim())
        .join('\n')
        .trim();
  }
}
