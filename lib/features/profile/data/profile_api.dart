import '../../../core/network/api_client.dart';

class ProfileApi {
  ProfileApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getMe(String userId) {
    return _client.get<Map<String, dynamic>>('/users/profile/$userId');
  }

  Future<Map<String, dynamic>> getBonusPoint() {
    return _client.get<Map<String, dynamic>>('/points');
  }

  Future<Map<String, dynamic>> updateMe({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
  }) {
    final normalizedPhone = (phoneNumber ?? '').trim();
    return _client.put<Map<String, dynamic>>(
      '/users/profile',
      data: <String, dynamic>{
        'id': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (normalizedPhone.isNotEmpty) 'phoneNumber': normalizedPhone,
      },
    );
  }

  Future<void> deleteAccount() async {
    await _client.delete<Object?>('/users/remove-account');
  }
}
