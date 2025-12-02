import 'package:dio/dio.dart';
import 'package:frontend/core/error/api_exception.dart';

class ApiClient {
  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://osrs-bingo.globeapp.dev'),
        validateStatus: (code) => code != null && code < 500,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['withCredentials'] = true;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final transformed = _transformResponse(response);
          return handler.next(transformed);
        },
        onError: (error, handler) {
          if (error.response != null) {
            final apiException = _parseError(error.response!);
            return handler.reject(DioException(requestOptions: error.requestOptions, response: error.response, type: error.type, error: apiException));
          }
          return handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;

  Response<dynamic> _transformResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode == 204) {
      return response;
    }

    if (statusCode >= 200 && statusCode < 300) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] == true && data.containsKey('data')) {
          return Response<dynamic>(
            requestOptions: response.requestOptions,
            data: data['data'],
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            headers: response.headers,
            extra: response.extra,
          );
        }
      }
      return response;
    }

    if (statusCode >= 400) {
      throw _parseError(response);
    }

    return response;
  }

  ApiException _parseError(Response<dynamic> response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ApiException(
        message: data['error'] as String? ?? 'An error occurred',
        code: data['code'] as String? ?? 'UNKNOWN_ERROR',
        details: data['details'] as Map<String, dynamic>?,
        statusCode: response.statusCode,
      );
    }

    return ApiException(message: 'An error occurred', code: _getCodeFromStatus(response.statusCode), statusCode: response.statusCode);
  }

  String _getCodeFromStatus(int? statusCode) {
    return switch (statusCode) {
      400 => 'BAD_REQUEST',
      401 => 'UNAUTHORIZED',
      403 => 'FORBIDDEN',
      404 => 'NOT_FOUND',
      409 => 'RESOURCE_EXISTS',
      _ => 'UNKNOWN_ERROR',
    };
  }
}

extension DioExceptionX on DioException {
  ApiException toApiException() {
    if (error is ApiException) {
      return error as ApiException;
    }

    return ApiException(message: message ?? 'Network error occurred', code: 'NETWORK_ERROR', statusCode: response?.statusCode);
  }
}
