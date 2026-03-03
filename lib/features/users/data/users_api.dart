import '../../../core/network/api_client.dart';

class UsersApi {
  UsersApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> setPin({
    required String pin,
    required String password,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/users/set-pin',
      data: <String, dynamic>{'pin': pin, 'password': password},
    );
  }

  Future<Map<String, dynamic>> resetPin({
    required String currentPin,
    required String newPin,
  }) {
    return _client.put<Map<String, dynamic>>(
      '/users/reset-pin',
      data: <String, dynamic>{'currentPin': currentPin, 'newPin': newPin},
    );
  }

  Future<Map<String, dynamic>> verifyPin({required String pin}) {
    return _client.post<Map<String, dynamic>>(
      '/users/verify-pin',
      data: <String, dynamic>{'pin': pin},
    );
  }
}
