import '../../auth/domain/auth_user.dart';
import 'profile_api.dart';

class ProfileRepository {
  ProfileRepository({required ProfileApi api}) : _api = api;

  final ProfileApi _api;

  AuthUser? _parseUser(Object? json) {
    Object? raw = json;

    // Unwrap common API envelopes like {data: {...}}, {result: {...}}, {user: {...}}
    // Some backends nest these multiple times.
    while (raw is Map<String, dynamic>) {
      final map = raw;
      final next =
          map['data'] ?? map['user'] ?? map['result'] ?? map['userData'];
      if (next == null || identical(next, raw)) {
        break;
      }
      raw = next;
    }

    if (raw is Map<String, dynamic>) {
      return AuthUser.fromJson(raw);
    }

    return null;
  }

  Future<AuthUser?> getMe(String userId) async {
    final json = await _api.getMe(userId);
    return _parseUser(json);
  }

  Future<AuthUser?> updateMe({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    print(firstName);
    final json = await _api.updateMe(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
    );
    print(json);
    return _parseUser(json);
  }
}
