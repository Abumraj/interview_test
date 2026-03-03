import 'dart:async';

import 'package:dio/dio.dart';

import '../logging/network_logger.dart';
import 'api_exceptions.dart';

typedef TokenProvider = FutureOr<String?> Function();
typedef UnauthorizedHandler = FutureOr<void> Function();
typedef RefreshTokenProvider = FutureOr<String?> Function();
typedef TokenSaver = FutureOr<void> Function(String token);

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getToken});

  final TokenProvider getToken;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required this.getRefreshToken,
    required this.saveAccessToken,
    required this.saveRefreshToken,
    required this.onUnauthorized,
  });

  final RefreshTokenProvider getRefreshToken;
  final TokenSaver saveAccessToken;
  final TokenSaver saveRefreshToken;
  final UnauthorizedHandler onUnauthorized;

  Completer<String?>? _refreshCompleter;

  bool _isRefreshRequest(RequestOptions options) {
    return options.path.contains('/auth/refresh-token') ||
        options.extra['skipRefresh'] == true;
  }

  Future<String?> _refreshAccessToken(String baseUrl) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final refresh = await getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        completer.complete(null);
        return null;
      }

      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: <String, dynamic>{'refreshToken': refresh},
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      Object? raw = data;
      if (raw is Map<String, dynamic>) {
        raw = raw['data'] ?? raw['result'] ?? raw;
      }
      String? access;
      String? newRefresh;
      if (raw is Map<String, dynamic>) {
        final v = raw['accessToken'] ?? raw['access_token'];
        if (v is String && v.isNotEmpty) access = v;

        final r = raw['refreshToken'] ?? raw['refresh_token'];
        if (r is String && r.isNotEmpty) newRefresh = r;
      }

      if (access == null || access.isEmpty) {
        completer.complete(null);
        return null;
      }

      await saveAccessToken(access);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await saveRefreshToken(newRefresh);
      }
      completer.complete(access);
      return access;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    String token,
  ) {
    final dio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $token';
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        followRedirects: requestOptions.followRedirects,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      ),
    );
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final options = err.requestOptions;

    if (statusCode != 401 || _isRefreshRequest(options)) {
      handler.next(err);
      return;
    }

    final newToken = await _refreshAccessToken(options.baseUrl);
    if (newToken == null || newToken.isEmpty) {
      await onUnauthorized();
      handler.next(err);
      return;
    }

    try {
      final response = await _retry(options, newToken);
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }
}

class NetworkLoggingInterceptor extends Interceptor {
  NetworkLoggingInterceptor({required this.logger});

  final NetworkLogger logger;

  final Map<int, DateTime> _requestStartTimes = <int, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestStartTimes[options.hashCode] = DateTime.now();
    logger.logRequest(
      method: options.method,
      uri: options.uri,
      requestSize:
          options.data is String ? (options.data as String).length : null,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final start = _requestStartTimes.remove(response.requestOptions.hashCode);
    final duration =
        start == null ? Duration.zero : DateTime.now().difference(start);

    logger.logResponse(
      method: response.requestOptions.method,
      uri: response.requestOptions.uri,
      statusCode: response.statusCode ?? -1,
      duration: duration,
      responseSize:
          response.data is String
              ? (response.data as String).length
              : response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final start = _requestStartTimes.remove(err.requestOptions.hashCode);
    final duration =
        start == null ? Duration.zero : DateTime.now().difference(start);

    logger.logError(
      method: err.requestOptions.method,
      uri: err.requestOptions.uri,
      duration: duration,
      error: err,
    );

    handler.next(err);
  }
}

class ErrorNormalizationInterceptor extends Interceptor {
  ErrorNormalizationInterceptor({required this.onUnauthorized});

  final UnauthorizedHandler onUnauthorized;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final exception = _mapDioError(err);

    if (exception is UnauthorizedException) {
      await onUnauthorized();
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  ApiException _mapDioError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return RequestTimeoutException(cause: err);
    }

    if (err.type == DioExceptionType.connectionError) {
      return NetworkUnavailableException(cause: err);
    }

    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    final message = _extractMessage(data) ?? err.message ?? 'Request failed';

    if (statusCode == 400) {
      return ValidationException(
        message: message,
        statusCode: statusCode,
        details: data is Map<String, dynamic> ? data : null,
        cause: err,
      );
    }
    if (statusCode == 401) {
      return UnauthorizedException(message: message, cause: err);
    }
    if (statusCode == 403) {
      return ForbiddenException(message: message, cause: err);
    }
    if (statusCode == 404) {
      return NotFoundException(message: message, cause: err);
    }
    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        message: message,
        statusCode: statusCode,
        cause: err,
      );
    }

    return UnknownApiException(
      message: message,
      statusCode: statusCode,
      cause: err,
    );
  }

  String? _extractMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
      final err = data['error'];
      if (err is String && err.trim().isNotEmpty) return err.trim();
    }
    return null;
  }
}
