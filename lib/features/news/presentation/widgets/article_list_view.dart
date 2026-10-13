import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../providers/paged_articles.dart';
import 'article_tile.dart';
import 'lead_article_card.dart';

class ArticleListView extends StatelessWidget {
  const ArticleListView({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onLoadMore,
    this.showLead = false,
    this.showSection = true,
  });

  final PagedArticles data;
  final RefreshCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool showLead;
  final bool showSection;
  static const _prefetchExtent = 600.0;

  bool _handleScroll(ScrollNotification notification) {
    final canLoadMore =
        data.hasMore && !data.isLoadingMore && data.loadMoreError == null;
    if (canLoadMore && notification.metrics.extentAfter < _prefetchExtent) {
      onLoadMore();
    }
    return false;
  }

  Future<void> _refresh(BuildContext context) async {
    try {
      await onRefresh();
    } on Failure catch (error) {
      if (context.mounted) showSnackBar(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final articles = data.articles;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: RefreshIndicator.adaptive(
        onRefresh: () => _refresh(context),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: articles.length + 1,
          separatorBuilder: (_, index) => index < articles.length - 1
              ? const Divider(indent: 20, endIndent: 20)
              : const SizedBox.shrink(),
          itemBuilder: (context, index) {
            if (index == articles.length) {
              return _ListFooter(data: data, onRetry: onLoadMore);
            }
            final article = articles[index];
            return showLead && index == 0
                ? LeadArticleCard(article: article, showSection: showSection)
                : ArticleTile(article: article, showSection: showSection);
          },
        ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.data, required this.onRetry});

  final PagedArticles data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final error = data.loadMoreError;
    final Widget content;
    if (error != null) {
      content = Column(
        children: [
          Text(
            error.message,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      );
    } else if (data.hasMore) {
      content = const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      content = Text("You're all caught up", style: textTheme.bodySmall);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(child: content),
    );
  }
}
