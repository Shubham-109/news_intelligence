import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatting.dart';
import '../../domain/article.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.section, {super.key});

  final String section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      section.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class ArticleMeta extends StatelessWidget {
  const ArticleMeta({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final minutes = article.readingMinutes;
    return Text(
      [
        formatRelativeTime(article.publishedAt),
        if (minutes > 0) '$minutes min read',
      ].join('  ·  '),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
