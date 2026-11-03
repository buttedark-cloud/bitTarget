import 'dart:async';

import 'package:dio/dio.dart';

/// Причины сбоя, которые мы показываем пользователю
enum ApiErrorKind { network, timeout, server, rateLimited, unknown }

class ApiException implements Exception {
  final ApiErrorKind kind;
  final String? details; // техническая подробность, только для консоли

  const ApiException(this.kind, [this.details]);

  @override
  String toString() => 'ApiException($kind${details == null ? '' : ': $details'})';
}

/// Единый HTTP-клиент приложения: таймауты, повтор при сбое и понятные ошибки.
class ApiClient {
  static final ApiClient shared = ApiClient._();

  static const Duration _attemptTimeout = Duration(seconds: 7);
  // Жёсткий предел на весь запрос с повтором. В браузере таймауты Dio ненадёжны, этот работает всегда
  static const Duration _totalTimeout = Duration(seconds: 18);

  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(BaseOptions(connectTimeout: _attemptTimeout, receiveTimeout: _attemptTimeout));
    _dio.interceptors.add(_RetryInterceptor(_dio, retries: 1));
  }

  Future<T> get<T>(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get<T>(url, queryParameters: queryParameters).timeout(_totalTimeout);
      final data = response.data;
      if (data == null) throw const ApiException(ApiErrorKind.unknown, 'empty response');
      return data;
    } catch (e) {
      throw _map(e);
    }
  }

  // Любую техническую ошибку превращаем в одну из наших категорий
  ApiException _map(Object e) {
    if (e is ApiException) return e;
    if (e is TimeoutException) return ApiException(ApiErrorKind.timeout, e.toString());

    if (e is DioException) {
      if (_isTimeout(e.type)) return ApiException(ApiErrorKind.timeout, e.message);
      if (e.type == DioExceptionType.connectionError) return ApiException(ApiErrorKind.network, e.message);

      if (e.type == DioExceptionType.badResponse) {
        final code = e.response?.statusCode ?? 0;
        if (code == 429 || code == 418) return ApiException(ApiErrorKind.rateLimited, 'HTTP $code');
        if (code >= 500) return ApiException(ApiErrorKind.server, 'HTTP $code');
        return ApiException(ApiErrorKind.unknown, 'HTTP $code');
      }

      // Остальное без ответа сервера — почти всегда нет связи
      return ApiException(e.response == null ? ApiErrorKind.network : ApiErrorKind.unknown, e.message ?? '${e.error}');
    }

    return ApiException(ApiErrorKind.unknown, e.toString());
  }
}

// Любой вид таймаута: проверяем по имени, чтобы код работал в любой версии Dio
bool _isTimeout(DioExceptionType type) => type.name.toLowerCase().contains('timeout');

// Повторяет запрос один раз, если сбой временный (обрыв, таймаут, ошибка сервера)
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int retries;

  _RetryInterceptor(this._dio, {required this.retries});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra['retryAttempt'] as int?) ?? 0;

    if (attempt < retries && _isTransient(err)) {
      await Future<void>.delayed(Duration(milliseconds: 800 * (attempt + 1)));
      final options = err.requestOptions;
      options.extra['retryAttempt'] = attempt + 1;
      try {
        final response = await _dio.fetch<dynamic>(options);
        handler.resolve(response);
      } on DioException catch (e) {
        handler.next(e);
      }
      return;
    }
    handler.next(err);
  }

  bool _isTransient(DioException e) {
    final type = e.type;
    if (_isTimeout(type) || type == DioExceptionType.connectionError) return true;

    if (type == DioExceptionType.badResponse) {
      final code = e.response?.statusCode ?? 0;
      return code == 429 || code >= 500;
    }

    if (type == DioExceptionType.unknown) return e.response == null;
    return false;
  }
}
