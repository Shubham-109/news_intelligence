import '../error/failure.dart';

Duration? retryRateLimited(int retryCount, Object error) {
  if (error is RateLimitFailure && retryCount < 2) {
    return const Duration(seconds: 1);
  }
  return null;
}
