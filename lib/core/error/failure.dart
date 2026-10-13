sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'You seem to be offline. Check your connection and try again.',
  ]);
}

final class RateLimitFailure extends Failure {
  const RateLimitFailure()
    : super('The news service is busy. Please wait a moment and try again.');
}

final class ApiKeyFailure extends Failure {
  const ApiKeyFailure()
    : super(
        'The Guardian API key is missing or invalid. '
        'See the README for how to add one.',
      );
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message =
        'The news service is having trouble right now. Please try again shortly.',
  ]);
}

final class StorageFailure extends Failure {
  const StorageFailure([
    super.message =
        'Could not save this change on your device. Please try again.',
  ]);
}
