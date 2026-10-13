import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/article.dart';
import '../widgets/article_image.dart';
import '../widgets/article_meta.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  static Route<void> route(Article article) {
    return MaterialPageRoute(
      builder: (_) => ArticleDetailScreen(article: article),
    );
  }

  static const _maxContentWidth = 680.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        actions: [
          _FavoriteButton(article: article),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sidePadding = math.max(
            20.0,
            (constraints.maxWidth - _maxContentWidth) / 2,
          );

          return SelectionArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(sidePadding, 4, sidePadding, 40),
              children: [
                if (article.section.isNotEmpty) ...[
                  SectionLabel(article.section),
                  const SizedBox(height: 10),
                ],
                Text(article.title, style: theme.textTheme.headlineMedium),
                if (article.summary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    article.summary,
                    style: theme.textTheme.standfirst.copyWith(
                      fontSize: 18,
                      color: mutedColor,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _Byline(article: article),
                if (article.imageUrl != null) ...[
                  const SizedBox(height: 20),
                  AspectRatio(
                    aspectRatio: 5 / 3,
                    child: ArticleImage(
                      url: article.imageUrl,
                      fallbackUrl: article.thumbnailUrl,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (article.paragraphs.isEmpty)
                  Text(
                    'The full text of this story is only available on '
                    'theguardian.com.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                    ),
                  ),
                for (final paragraph in article.paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Text(paragraph, style: theme.textTheme.articleBody),
                  ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 20),
                _SourceLink(url: article.url),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isFavoriteProvider(article.id));

    return IconButton(
      tooltip: isSaved ? 'Remove from favorites' : 'Save to favorites',
      isSelected: isSaved,
      icon: const Icon(Icons.bookmark_border_rounded),
      selectedIcon: Icon(
        Icons.bookmark_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () => _toggle(context, ref),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      final saved = await ref.read(favoritesProvider.notifier).toggle(article);
      await HapticFeedback.selectionClick();
      if (context.mounted) {
        showSnackBar(
          context,
          saved ? 'Saved to favorites' : 'Removed from favorites',
        );
      }
    } on Failure catch (error) {
      if (context.mounted) showSnackBar(context, error.message);
    }
  }
}

class _Byline extends StatelessWidget {
  const _Byline({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final author = article.author;
    final minutes = article.readingMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (author != null) ...[
          Text(author, style: textTheme.titleSmall),
          const SizedBox(height: 2),
        ],
        Text(
          [
            formatFullDate(article.publishedAt),
            if (minutes > 0) '$minutes min read',
          ].join('  ·  '),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.url});

  final String url;

  Future<void> _open(BuildContext context) async {
    bool opened;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppBrowserView,
      );
    } on PlatformException {
      opened = false;
    }
    if (!opened && context.mounted) {
      showSnackBar(context, 'Could not open the original article.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () => _open(context),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('Read on theguardian.com'),
        ),
        const SizedBox(height: 14),
        Text(
          'Powered by The Guardian. © Guardian News & Media Limited.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
