import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../../../auth/domain/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/news_category.dart';
import '../providers/feed_provider.dart';
import '../widgets/article_list_skeleton.dart';
import '../widgets/article_list_view.dart';

/// Latest business stories, with one tab per desk.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: NewsCategory.values.length,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FeedHeader(),
              TabBar(
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  for (final category in NewsCategory.values)
                    Tab(text: category.label),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (final category in NewsCategory.values)
                      _CategoryFeed(category: category),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedHeader extends ConsumerWidget {
  const _FeedHeader();

  static String _greeting(DateTime now) {
    return switch (now.hour) {
      < 12 => 'Good morning',
      < 17 => 'Good afternoon',
      _ => 'Good evening',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE d MMMM').format(now).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user == null
                      ? 'Your business briefing'
                      : '${_greeting(now)}, ${user.firstName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          if (user != null) _AccountButton(user: user),
        ],
      ),
    );
  }
}

/// Avatar that opens a sheet with the signed in email and sign out.
class _AccountButton extends ConsumerWidget {
  const _AccountButton({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: 'Account',
      onPressed: () => _showAccountSheet(context, ref),
      icon: CircleAvatar(
        radius: 18,
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: Text(
          user.firstName[0],
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: colors.onPrimaryContainer),
        ),
      ),
    );
  }

  Future<void> _showAccountSheet(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Signed in as', style: textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(user.email, style: textTheme.titleMedium),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _signOut(context, ref);
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } on Failure catch (error) {
      if (context.mounted) showSnackBar(context, error.message);
    }
  }
}

class _CategoryFeed extends ConsumerWidget {
  const _CategoryFeed({required this.category});

  final NewsCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = feedProvider(category);

    // Loaded stories win over everything else, so a failed refresh keeps them
    // on screen. A retry keeps the old error while it runs, which is why the
    // error view also requires that nothing is loading.
    return switch (ref.watch(provider)) {
      AsyncValue(:final value?) when value.articles.isEmpty =>
        const MessageView(
          icon: Icons.article_outlined,
          title: 'No stories yet',
          message: 'Nothing has been published on this desk recently.',
        ),
      AsyncValue(:final value?) => ArticleListView(
        key: PageStorageKey(category),
        data: value,
        showLead: true,
        showSection: false,
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
      ),
      AsyncValue(:final error?, isLoading: false) => MessageView.error(
        error,
        onRetry: () => ref.invalidate(provider),
      ),
      _ => const ArticleListSkeleton(showLead: true),
    };
  }
}
