import 'package:flutter/material.dart';

import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/news/presentation/screens/feed_screen.dart';
import '../features/news/presentation/screens/search_screen.dart';

/// Main area of the app with bottom navigation. Each tab keeps its state,
/// such as the scroll position, while another one is open.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [FeedScreen(), SearchScreen(), FavoritesScreen()],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) {
            // A focused field on a hidden tab would keep the keyboard open.
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _index = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}
