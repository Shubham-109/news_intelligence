import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/message_view.dart';
import '../../domain/news_category.dart';
import '../../domain/search_sort.dart';
import '../providers/search_provider.dart';
import '../widgets/article_list_skeleton.dart';
import '../widgets/article_list_view.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String text) {
    ref.read(searchQueryProvider.notifier).setText(text);
  }

  void _searchFor(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _search(text);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final queryNotifier = ref.read(searchQueryProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Text(
                'Search',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchField(
                controller: _controller,
                onChanged: _search,
                onClear: () => _searchFor(''),
              ),
            ),
            const SizedBox(height: 6),
            _DeskFilter(
              selected: query.category,
              onSelected: queryNotifier.setCategory,
            ),
            const SizedBox(height: 6),
            const Divider(),
            if (query.isSearchable) ...[
              _ResultsBar(query: query, onSortChanged: queryNotifier.setSort),
              Expanded(child: _SearchResults(query: query)),
            ] else
              Expanded(child: _SearchPrompt(onSuggestion: _searchFor)),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.search,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Companies, markets or topics',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClear,
                  ),
          ),
        );
      },
    );
  }
}

class _DeskFilter extends StatelessWidget {
  const _DeskFilter({required this.selected, required this.onSelected});

  final NewsCategory? selected;
  final ValueChanged<NewsCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          for (final category in [null, ...NewsCategory.values])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category?.label ?? 'All desks'),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultsBar extends ConsumerWidget {
  const _ResultsBar({required this.query, required this.onSortChanged});

  final SearchQuery query;
  final ValueChanged<SearchSort> onSortChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final results = ref.watch(searchResultsProvider(query));
    final summary = switch (results.value?.totalResults) {
      null when results.isLoading => 'Searching',
      null => '',
      1 => '1 result',
      final count => '${NumberFormat.decimalPattern().format(count)} results',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 8, 0),
      child: Row(
        children: [
          Expanded(child: Text(summary, style: theme.textTheme.bodySmall)),
          PopupMenuButton<SearchSort>(
            initialValue: query.sort,
            tooltip: 'Sort results',
            onSelected: onSortChanged,
            itemBuilder: (_) => [
              for (final sort in SearchSort.values)
                PopupMenuItem(value: sort, child: Text(sort.label)),
            ],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(query.sort.label, style: theme.textTheme.labelMedium),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final SearchQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = searchResultsProvider(query);

    return switch (ref.watch(provider)) {
      AsyncValue(:final value?) when value.articles.isEmpty => MessageView(
        icon: Icons.search_off_rounded,
        title: 'No stories found',
        message: query.category == null
            ? 'Try a different keyword or a broader phrase.'
            : 'Try a different keyword, or search all desks.',
      ),
      AsyncValue(:final value?) => ArticleListView(
        key: PageStorageKey(query),
        data: value,
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
      ),
      AsyncValue(:final error?, isLoading: false) => MessageView.error(
        error,
        onRetry: () => ref.invalidate(provider),
      ),
      _ => const ArticleListSkeleton(),
    };
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt({required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  static const _suggestions = [
    'Interest rates',
    'Inflation',
    'Oil prices',
    'Artificial intelligence',
    'Housing market',
  ];

  @override
  Widget build(BuildContext context) {
    return MessageView(
      icon: Icons.manage_search_rounded,
      title: 'Search the news',
      message: 'Look up any company or topic, then narrow it down by desk.',
      action: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final suggestion in _suggestions)
            ActionChip(
              label: Text(suggestion),
              onPressed: () => onSuggestion(suggestion),
            ),
        ],
      ),
    );
  }
}
