import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../data/tickets_api.dart';
import '../data/tickets_repository.dart';
import '../domain/ticket.dart';

final ticketsRepositoryProvider = Provider<TicketsRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  final CacheManager cache = ref.watch(cacheManagerProvider);
  return TicketsRepository(api: TicketsApi(client), cache: cache);
});

final myTicketsControllerProvider =
    AsyncNotifierProvider<MyTicketsController, List<Ticket>>(
      MyTicketsController.new,
    );

class MyTicketsController extends AsyncNotifier<List<Ticket>> {
  @override
  Future<List<Ticket>> build() async {
    final repo = ref.read(ticketsRepositoryProvider);

    final tickets = await repo.getTicketsCachedFirst();

    unawaited(
      repo.revalidateTicketsInBackground().then((_) async {
        final updated = await repo.getTicketsCachedFirst();
        state = AsyncData(updated);
      }),
    );

    return tickets;
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
