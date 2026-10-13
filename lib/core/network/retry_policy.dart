import '../error/failure.dart';

/// Retry rule for every provider in the app.
///
/// Riverpod retries failed providers by default, which would leave people
/// watching a spinner while offline. Only rate limit errors are retried,
/// because the free Guardian key allows one request per second and a short
/// pause is usually enough.
Duration? retryRateLimited(int retryCount, Object error) {
  if (error is RateLimitFailure && retryCount < 2) {
    return const Duration(seconds: 1);
  }
  return null;
}
