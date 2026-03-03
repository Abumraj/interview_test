import 'package:dio/dio.dart';

import '../logging/network_logger.dart';
import 'api_exceptions.dart';
import 'interceptors.dart';
import 'network_constants.dart';

typedef DioFactory = Dio Function(BaseOptions options);

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenProvider getToken,
    required RefreshTokenProvider getRefreshToken,
    required TokenSaver saveAccessToken,
    required TokenSaver saveRefreshToken,
    required UnauthorizedHandler onUnauthorized,
    NetworkLogger? logger,
    DioFactory? dioFactory,
  }) : _dio = (dioFactory ?? (options) => Dio(options)).call(
         BaseOptions(
           baseUrl: NetworkConstants.resolveBaseUrl(configuredBaseUrl: baseUrl),
           connectTimeout: NetworkConstants.connectTimeout,
           receiveTimeout: NetworkConstants.receiveTimeout,
           sendTimeout: NetworkConstants.sendTimeout,
           headers: <String, dynamic>{
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       ) {
    _dio.interceptors.addAll([
      AuthInterceptor(getToken: getToken),
      RefreshTokenInterceptor(
        getRefreshToken: getRefreshToken,
        saveAccessToken: saveAccessToken,
        saveRefreshToken: saveRefreshToken,
        onUnauthorized: onUnauthorized,
      ),
      ErrorNormalizationInterceptor(onUnauthorized: onUnauthorized),
      NetworkLoggingInterceptor(logger: logger ?? const NetworkLogger()),
    ]);
  }

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      print(e);
      final mapped = e.error;
      if (mapped is ApiException) throw mapped;
      throw UnknownApiException(
        cause: e,
        message: e.message ?? 'Request failed',
      );
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print(data);
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      print(response);
      return response.data as T;
    } on DioException catch (e) {
      print(e);
      final mapped = e.error;
      if (mapped is ApiException) throw mapped;
      throw UnknownApiException(
        cause: e,
        message: e.message ?? 'Request failed',
      );
    }
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      print(e);
      final mapped = e.error;
      if (mapped is ApiException) throw mapped;
      throw UnknownApiException(
        cause: e,
        message: e.message ?? 'Request failed',
      );
    }
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      final mapped = e.error;
      if (mapped is ApiException) throw mapped;
      throw UnknownApiException(
        cause: e,
        message: e.message ?? 'Request failed',
      );
    }
  }

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      final mapped = e.error;
      if (mapped is ApiException) throw mapped;
      throw UnknownApiException(
        cause: e,
        message: e.message ?? 'Request failed',
      );
    }
  }
}
