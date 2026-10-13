import 'package:flutter_test/flutter_test.dart';
import 'package:news_intelligence/core/error/failure.dart';
import 'package:news_intelligence/core/network/retry_policy.dart';

void main() {
  test('retries rate limits twice and nothing else', () {
    expect(retryRateLimited(0, const RateLimitFailure()), isNotNull);
    expect(retryRateLimited(1, const RateLimitFailure()), isNotNull);
    expect(retryRateLimited(2, const RateLimitFailure()), isNull);
    expect(retryRateLimited(0, const NetworkFailure()), isNull);
    expect(retryRateLimited(0, const ServerFailure()), isNull);
  });
}
