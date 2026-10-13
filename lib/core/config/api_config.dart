import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Settings for The Guardian Open Platform content API.
abstract final class ApiConfig {
  static const baseUrl = 'https://content.guardianapis.com';

  static String get apiKey => dotenv.maybeGet('GUARDIAN_API_KEY') ?? '';

  static const pageSize = 20;
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 20);
}
