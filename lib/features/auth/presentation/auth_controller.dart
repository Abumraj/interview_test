import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/network/core_network_providers.dart';
import '../../../core/network/token_storage.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../profile/presentation/profile_controller.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

class AuthState {
  final AuthUser? user;

  const AuthState({this.user});
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  final TokenStorage storage = ref.watch(tokenStorageProvider);
  return AuthRepository(api: AuthApi(client), tokenStorage: storage);
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final cacheManager = ref.read(cacheManagerProvider);

    final access = await tokenStorage.readAccessToken();
    if (access == null || access.isEmpty) {
      return const AuthState();
    }

    final cached = await cacheManager.readJson('auth_user');
    if (cached == null) {
      return const AuthState();
    }
    return AuthState(user: AuthUser.fromJson(cached));
  }

  Future<void> loginWithGoogle({required String firebaseIdToken}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.googleLogin(token: firebaseIdToken);
      await ref
          .read(cacheManagerProvider)
          .writeJson('auth_user', user.toJson());
      state = AsyncData(AuthState(user: user));

      ref.read(profileControllerProvider.notifier).refresh();

      final notifRepo = ref.read(notificationsRepositoryProvider);
      registerFcmToken(notifRepo);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> registerAndRequestOtp({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      await repo.requestOtp(email: email);
      state = AsyncData(AuthState(user: user));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      await ref
          .read(cacheManagerProvider)
          .writeJson('auth_user', user.toJson());
      state = AsyncData(AuthState(user: user));

      ref.read(profileControllerProvider.notifier).refresh();

      final notifRepo = ref.read(notificationsRepositoryProvider);
      registerFcmToken(notifRepo);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final notifRepo = ref.read(notificationsRepositoryProvider);
      await unregisterFcmToken(notifRepo);
      await ref.read(authRepositoryProvider).logout();
      await ref.read(cacheManagerProvider).clearAll();
      state = const AsyncData(AuthState());
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> requestOtp({required String email}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.requestOtp(email: email);
      state = AsyncData(state.value ?? const AuthState());
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyOtp(email: email, otp: otp);
      state = AsyncData(state.value ?? const AuthState());
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> forgotPassword({required String email}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.forgotPassword(email: email);
      state = AsyncData(state.value ?? const AuthState());
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      state = AsyncData(state.value ?? const AuthState());
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      state = AsyncData(state.value ?? const AuthState());
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
