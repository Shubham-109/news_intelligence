import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/article.dart';
import 'article_image.dart';
import 'article_meta.dart';

/// Top story of a desk, shown with a large image and its summary.
class LeadArticleCard extends StatelessWidget {
  const LeadArticleCard({
    super.key,
    required this.article,
    this.showSection = true,
  });

  final Article article;
  final bool showSection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl != null) ...[
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ArticleImage(
                url: article.imageUrl,
                fallbackUrl: article.thumbnailUrl,
                borderRadius: 14,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (showSection && article.section.isNotEmpty) ...[
            SectionLabel(article.section),
            const SizedBox(height: 8),
          ],
          Text(article.title, style: theme.textTheme.headlineSmall),
          if (article.summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              article.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.standfirst.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ArticleMeta(article: article),
        ],
      ),
    );
  }
}
