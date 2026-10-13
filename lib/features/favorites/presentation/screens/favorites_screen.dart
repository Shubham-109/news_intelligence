import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../../../news/domain/article.dart';
import '../../../news/presentation/widgets/article_tile.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Favorites', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(switch (favorites.length) {
                    0 => 'Stories you save appear here',
                    1 => '1 story, available offline',
                    final count => '$count stories, available offline',
                  }, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: favorites.isEmpty
                  ? const MessageView(
                      icon: Icons.bookmark_border_rounded,
                      title: 'No favorites yet',
                      message:
                          'Tap the bookmark on any story to keep it here. '
                          'Saved stories open even without a connection.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: favorites.length,
                      separatorBuilder: (_, _) =>
                          const Divider(indent: 20, endIndent: 20),
                      itemBuilder: (_, index) {
                        final article = favorites[index];
                        return Dismissible(
                          key: ValueKey(article.id),
                          direction: DismissDirection.endToStart,
                          background: const _RemoveBackground(),
                          onDismissed: (_) => _remove(context, ref, article),
                          child: ArticleTile(article: article),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    final favorites = ref.read(favoritesProvider.notifier);
    try {
      await favorites.remove(article);
    } on Failure catch (error) {
      if (context.mounted) showSnackBar(context, error.message);
      return;
    }
    if (!context.mounted) return;

    showSnackBar(
      context,
      'Removed from favorites',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          try {
            await favorites.add(article);
          } on Failure catch (error) {
            if (context.mounted) showSnackBar(context, error.message);
          }
        },
      ),
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_remove_outlined, color: color),
              const SizedBox(width: 8),
              Text(
                'Remove',
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
