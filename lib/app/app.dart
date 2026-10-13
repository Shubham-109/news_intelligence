import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import 'home_shell.dart';

class NewsApp extends ConsumerWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(
      authControllerProvider.select((state) => state.value != null),
    );

    return MaterialApp(
      title: 'News Intelligence',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isSignedIn ? const HomeShell() : const LoginScreen(),
      ),
    );
  }
}
