import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';

import '../../../core/cache/cache_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../data/history_api.dart';
import '../data/history_repository.dart';
import '../domain/purchase.dart';
import '../domain/purchase_details.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  final CacheManager cache = ref.watch(cacheManagerProvider);
  return HistoryRepository(api: HistoryApi(client), cache: cache);
});

final purchasesControllerProvider =
    AsyncNotifierProvider<PurchasesController, List<Purchase>>(
      PurchasesController.new,
    );

final purchaseDetailsProvider = FutureProvider.family<PurchaseDetails?, String>(
  (ref, bookingId) async {
    final repo = ref.read(historyRepositoryProvider);
    return repo.getPurchaseDetails(bookingId);
  },
);

class PurchasesController extends AsyncNotifier<List<Purchase>> {
  @override
  Future<List<Purchase>> build() async {
    final repo = ref.read(historyRepositoryProvider);
    final userId = ref.read(authControllerProvider).value!.user!.id;
    final purchases = await repo.getPurchasesCachedFirst(userId);

    unawaited(
      repo.revalidatePurchasesInBackground(userId).then((_) async {
        final updated = await repo.getPurchasesCachedFirst(userId);
        state = AsyncData(updated);
      }),
    );

    return purchases;
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
