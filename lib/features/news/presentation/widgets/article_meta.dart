import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatting.dart';
import '../../domain/article.dart';

/// Uppercase desk name shown above a headline.
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

/// How old a story is and how long it takes to read, such as
/// "3h ago · 4 min read".
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
