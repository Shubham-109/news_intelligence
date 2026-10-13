import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/api_config.dart';
import '../error/failure.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      queryParameters: {'api-key': ApiConfig.apiKey},
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    );
  }
  ref.onDispose(dio.close);
  return ApiClient(dio);
});

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, Object>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data == null) throw const ServerFailure();
      return data;
    } on DioException catch (error) {
      throw failureFromDioException(error);
    }
  }
}

Failure failureFromDioException(DioException error) {
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const NetworkFailure(
      'The connection timed out. Please try again.',
    ),
    DioExceptionType.connectionError => const NetworkFailure(),
    DioExceptionType.unknown when error.error is SocketException =>
      const NetworkFailure(),
    DioExceptionType.badResponse => switch (error.response?.statusCode) {
      401 || 403 => const ApiKeyFailure(),
      429 => const RateLimitFailure(),
      _ => const ServerFailure(),
    },
    _ => const ServerFailure(),
  };
}
