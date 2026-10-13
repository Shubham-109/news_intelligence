/// Settings for The Guardian Open Platform content API.
abstract final class ApiConfig {
  static const baseUrl = 'https://content.guardianapis.com';

  /// Passed in at build time as GUARDIAN_API_KEY so the key never lands in
  /// source control. The README shows the exact command.
  static const apiKey = String.fromEnvironment('GUARDIAN_API_KEY');

  static const pageSize = 20;
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 20);
}
