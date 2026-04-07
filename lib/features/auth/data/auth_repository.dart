import '../../../core/network/token_storage.dart';
import '../domain/auth_user.dart';
import 'auth_api.dart';

class AuthRepository {
  AuthRepository({required AuthApi api, required TokenStorage tokenStorage})
    : _api = api,
      _tokenStorage = tokenStorage;

  final AuthApi _api;
  final TokenStorage _tokenStorage;

  Map<String, dynamic> _normalizeAuthPayload(Map<String, dynamic> json) {
    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['result'] ?? raw;
    }
    return raw is Map<String, dynamic> ? raw : json;
  }

  Future<void> _persistTokensIfPresent(Map<String, dynamic> payload) async {
    final accessToken = payload['accessToken'] ?? payload['access_token'];
    if (accessToken is String && accessToken.isNotEmpty) {
      await _tokenStorage.writeAccessToken(accessToken);
    }

    final refreshToken = payload['refreshToken'] ?? payload['refresh_token'];
    if (refreshToken is String && refreshToken.isNotEmpty) {
      await _tokenStorage.writeRefreshToken(refreshToken);
    }
  }

  Map<String, dynamic>? _extractUserJson(
    Map<String, dynamic> json,
    Map<String, dynamic> payload,
  ) {
    final fromPayload = payload['user'];
    if (fromPayload is Map<String, dynamic>) return fromPayload;

    final fromRoot = json['user'];
    if (fromRoot is Map<String, dynamic>) return fromRoot;

    // New backend shape can return the user object directly.
    if (payload.containsKey('id') && payload['id'] is String) return payload;
    if (json.containsKey('id') && json['id'] is String) return json;

    return null;
  }

  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    required String password,
  }) async {
    final json = await _api.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
    print(json);
    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      return AuthUser.fromJson(userJson);
    }
    return const AuthUser(id: '');
  }

  Future<AuthUser> googleLogin({required String token}) async {
    final json = await _api.googleLogin(token: token);

    final payload = _normalizeAuthPayload(json);
    await _persistTokensIfPresent(payload);

    final userJson = _extractUserJson(json, payload);
    if (userJson != null) return AuthUser.fromJson(userJson);

    return const AuthUser(id: '');
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final json = await _api.login(email: email, password: password);

    final payload = _normalizeAuthPayload(json);
    await _persistTokensIfPresent(payload);

    final userJson = _extractUserJson(json, payload);
    if (userJson != null) return AuthUser.fromJson(userJson);

    return const AuthUser(id: '');
  }

  Future<String?> refreshAccessToken() async {
    final refresh = await _tokenStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    final json = await _api.refreshToken(refreshToken: refresh);
    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['result'] ?? raw;
    }
    if (raw is Map<String, dynamic>) {
      final accessToken = raw['accessToken'] ?? raw['access_token'];
      if (accessToken is String && accessToken.isNotEmpty) {
        await _tokenStorage.writeAccessToken(accessToken);
        final newRefresh = raw['refreshToken'] ?? raw['refresh_token'];
        if (newRefresh is String && newRefresh.isNotEmpty) {
          await _tokenStorage.writeRefreshToken(newRefresh);
        }
        return accessToken;
      }
    }
    return null;
  }

  Future<void> requestOtp({required String email}) async {
    await _api.requestOtp(email: email);
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    await _api.verifyOtp(email: email, otp: otp);
  }

  Future<void> forgotPassword({required String email}) async {
    await _api.forgotPassword(email: email);
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _api.resetPassword(email: email, otp: otp, newPassword: newPassword);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> logout() => _tokenStorage.clear();
}
