import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../data/users_api.dart';
import '../data/users_repository.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  return UsersRepository(api: UsersApi(client));
});

final usersControllerProvider = AsyncNotifierProvider<UsersController, void>(
  UsersController.new,
);

class UsersController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> setPin({required String pin, required String password}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(usersRepositoryProvider);
      await repo.setPin(pin: pin, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> resetPin({
    required String currentPin,
    required String newPin,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(usersRepositoryProvider);
      await repo.resetPin(currentPin: currentPin, newPin: newPin);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> verifyPin({required String pin}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(usersRepositoryProvider);
      await repo.verifyPin(pin: pin);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
