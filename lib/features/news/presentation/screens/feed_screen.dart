import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/message_view.dart';
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

class _FeedHeader extends StatelessWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE d MMMM').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            today.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text('Your business briefing', style: theme.textTheme.headlineMedium),
        ],
      ),
    );
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
