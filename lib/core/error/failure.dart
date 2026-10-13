/// An error the app knows how to explain to the user.
///
/// Repositories translate low level exceptions from Dio, Hive or JSON parsing
/// into one of these types, so the presentation layer only ever deals with a
/// small, closed set of failures.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// A short explanation that can be shown to the user as is.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The device is offline, or the connection dropped or timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'You seem to be offline. Check your connection and try again.',
  ]);
}

/// Too many requests were sent in a short time.
final class RateLimitFailure extends Failure {
  const RateLimitFailure()
    : super('The news service is busy. Please wait a moment and try again.');
}

/// The API key is missing or was rejected.
final class ApiKeyFailure extends Failure {
  const ApiKeyFailure()
    : super(
        'The Guardian API key is missing or invalid. '
        'See the README for how to add one.',
      );
}

/// The server failed, or sent a response the app could not understand.
final class ServerFailure extends Failure {
  const ServerFailure([
    super.message =
        'The news service is having trouble right now. Please try again shortly.',
  ]);
}

/// Reading from or writing to storage on the device failed.
final class StorageFailure extends Failure {
  const StorageFailure([
    super.message =
        'Could not save this change on your device. Please try again.',
  ]);
}
