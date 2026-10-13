import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/news/presentation/screens/feed_screen.dart';

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Intelligence',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const FeedScreen(),
    );
  }
}
