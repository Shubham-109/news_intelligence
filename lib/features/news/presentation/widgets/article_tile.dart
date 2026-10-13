import 'package:flutter/material.dart';

import '../../domain/article.dart';
import '../screens/article_detail_screen.dart';
import 'article_image.dart';
import 'article_meta.dart';

/// Compact list row: desk, headline and details on the left, thumbnail on
/// the right.
class ArticleTile extends StatelessWidget {
  const ArticleTile({
    super.key,
    required this.article,
    this.showSection = true,
  });

  final Article article;

  /// Lists that already belong to one desk can leave the label out.
  final bool showSection;

  @override
  Widget build(BuildContext context) {
    final thumbnail = article.thumbnailUrl;

    return InkWell(
      onTap: () =>
          Navigator.of(context).push(ArticleDetailScreen.route(article)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSection && article.section.isNotEmpty) ...[
                    SectionLabel(article.section),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ArticleMeta(article: article),
                ],
              ),
            ),
            if (thumbnail != null) ...[
              const SizedBox(width: 16),
              ArticleImage(
                url: thumbnail,
                width: 88,
                height: 88,
                borderRadius: 10,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
