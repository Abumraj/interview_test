import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../../auth/domain/auth_user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/profile_api.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  return ProfileRepository(api: ProfileApi(client));
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, AuthUser?>(ProfileController.new);

class ProfileController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    final authUser = ref.watch(authControllerProvider).value?.user;
    final userId = authUser?.id;
    if (userId == null || userId.isEmpty) return authUser;

    final repo = ref.read(profileRepositoryProvider);
    final user = await repo.getMe(userId);
    return user ?? authUser;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<AuthUser?>().copyWithPrevious(state);
    state = await AsyncValue.guard(build);
  }

  Future<AuthUser?> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    state = const AsyncLoading<AuthUser?>().copyWithPrevious(state);

    final repo = ref.read(profileRepositoryProvider);
    final user = await repo.updateMe(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
    );

    final next = user ?? state.value;
    state = AsyncData(next);
    return next;
  }
}
