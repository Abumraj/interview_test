import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../data/payments_api.dart';
import '../data/payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  return PaymentsRepository(api: PaymentsApi(client));
});

final paymentsControllerProvider =
    AsyncNotifierProvider<PaymentsController, PaymentInit?>(
      PaymentsController.new,
    );

class PaymentsController extends AsyncNotifier<PaymentInit?> {
  @override
  Future<PaymentInit?> build() async {
    return null;
  }

  Future<PaymentInit> initialize({
    required String paymentId,
    required String redirectUrl,
    required int amount,
    bool isBonusPointUsed = false,
    bool isNewPayment = false,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final init = await repo.initialize(
        paymentId: paymentId,
        redirectUrl: redirectUrl,
        amount: amount,
        isBonusPointUsed: isBonusPointUsed,
        isNewPayment: isNewPayment,
      );
      state = AsyncData(init);
      return init;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> verify({required String txRef, String? transactionId}) async {
    final previous = state.value;
    state = const AsyncLoading();
    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final ok = await repo.verify(txRef: txRef, transactionId: transactionId);
      state = AsyncData(previous);
      return ok;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
