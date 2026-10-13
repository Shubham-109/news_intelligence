import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_intelligence/core/error/failure.dart';
import 'package:news_intelligence/core/network/api_client.dart';

DioException _error(DioExceptionType type, {int? status, Object? cause}) {
  final request = RequestOptions(path: '/search');
  return DioException(
    requestOptions: request,
    type: type,
    error: cause,
    response: status == null
        ? null
        : Response(requestOptions: request, statusCode: status),
  );
}

void main() {
  group('failureFromDioException', () {
    test('treats timeouts and lost connections as network failures', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(failureFromDioException(_error(type)), isA<NetworkFailure>());
      }
      expect(
        failureFromDioException(
          _error(
            DioExceptionType.unknown,
            cause: const SocketException('offline'),
          ),
        ),
        isA<NetworkFailure>(),
      );
    });

    test('maps HTTP status codes', () {
      Failure forStatus(int status) => failureFromDioException(
        _error(DioExceptionType.badResponse, status: status),
      );

      expect(forStatus(401), isA<ApiKeyFailure>());
      expect(forStatus(403), isA<ApiKeyFailure>());
      expect(forStatus(429), isA<RateLimitFailure>());
      expect(forStatus(500), isA<ServerFailure>());
    });
  });
}
