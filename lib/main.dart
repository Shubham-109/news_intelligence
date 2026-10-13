import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/error/failure.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  runApp(const ProviderScope(retry: _retryRateLimited, child: NewsApp()));
}

/// Riverpod retries failed providers by default, which would leave people
/// watching a spinner while offline. Only rate limit errors are retried,
/// because the free Guardian key allows one request per second.
Duration? _retryRateLimited(int retryCount, Object error) {
  if (error is RateLimitFailure && retryCount < 2) {
    return const Duration(seconds: 1);
  }
  return null;
}
