import 'package:flutter_test/flutter_test.dart';
import 'package:news_intelligence/features/news/data/article_model.dart';

Map<String, dynamic> _guardianItem({Map<String, dynamic>? fields}) {
  return {
    'id': 'business/2026/oct/13/markets-rally',
    'sectionName': 'Business',
    'webTitle': 'Markets rally (web title)',
    'webUrl': 'https://www.theguardian.com/business/2026/oct/13/markets-rally',
    'webPublicationDate': '2026-10-13T08:30:00Z',
    'fields': fields ?? const <String, dynamic>{},
  };
}

void main() {
  group('ArticleModel.fromJson', () {
    test('reads the core fields and cleans up HTML', () {
      final article = ArticleModel.fromJson(
        _guardianItem(
          fields: {
            'headline': 'Markets rally as inflation cools',
            'trailText': '<strong>Live:</strong> Shares rise &amp; bonds fall',
            'byline': 'Jane Doe',
            'thumbnail': 'https://media.guim.co.uk/abc/0_0_5000_3000/500.jpg',
            'wordcount': '1150',
          },
        ),
      );

      expect(article.id, 'business/2026/oct/13/markets-rally');
      expect(article.title, 'Markets rally as inflation cools');
      expect(article.summary, 'Live: Shares rise & bonds fall');
      expect(article.section, 'Business');
      expect(article.author, 'Jane Doe');
      expect(article.publishedAt, DateTime.utc(2026, 10, 13, 8, 30));
      expect(article.readingMinutes, 5);
      expect(
        article.imageUrl,
        'https://media.guim.co.uk/abc/0_0_5000_3000/1000.jpg',
      );
    });

    test('keeps text blocks and drops embeds from the body', () {
      final article = ArticleModel.fromJson(
        _guardianItem(
          fields: {
            'body':
                '<p>First paragraph with <a href="/x">a link</a>.</p> '
                '<aside class="element-rich-link"><p>Related: Other</p></aside> '
                '<figure><img src="photo.jpg"><figcaption>Caption</figcaption>'
                '</figure> '
                '<h2>Market reaction</h2> '
                '<p>Line one<br>Line two</p> '
                '<ul><li>First point</li><li>Second point</li></ul> '
                '<p>   </p>',
          },
        ),
      );

      expect(article.paragraphs, [
        'First paragraph with a link.',
        'Market reaction',
        'Line one\nLine two',
        '• First point',
        '• Second point',
      ]);
    });

    test('falls back sensibly when optional fields are missing', () {
      final article = ArticleModel.fromJson(
        _guardianItem(fields: {'byline': ''}),
      );

      expect(article.title, 'Markets rally (web title)');
      expect(article.author, isNull);
      expect(article.summary, isEmpty);
      expect(article.paragraphs, isEmpty);
      expect(article.imageUrl, isNull);
      expect(article.readingMinutes, 0);
    });
  });
}
