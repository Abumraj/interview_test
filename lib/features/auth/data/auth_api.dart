import '../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    required String password,
  }) {
    final trimmedPhone = (phoneNumber ?? '').trim();
    return _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (trimmedPhone.isNotEmpty) 'phoneNumber': trimmedPhone,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> googleLogin({required String token}) {
    return _client.post<Map<String, dynamic>>(
      '/auth/firebase-login',
      data: <String, dynamic>{'token': token},
    );
  }

  Future<Map<String, dynamic>> requestOtp({required String email}) {
    return _client.post<Map<String, dynamic>>(
      '/auth/otp/request',
      data: <String, dynamic>{'email': email},
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: <String, dynamic>{'email': email, 'otp': otp},
    );
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) {
    return _client.post<Map<String, dynamic>>(
      '/auth/forgot-password',
      data: <String, dynamic>{'email': email},
    );
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/auth/reset-password',
      data: <String, dynamic>{
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/auth/change-password',
      data: <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<Map<String, dynamic>> refreshToken({required String refreshToken}) {
    return _client.post<Map<String, dynamic>>(
      '/auth/refresh-token',
      options: Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $refreshToken'},
        extra: const <String, dynamic>{'skipAuth': true, 'skipRefresh': true},
      ),
    );
  }
}
