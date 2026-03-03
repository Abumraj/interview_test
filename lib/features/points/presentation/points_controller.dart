import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../data/points_api.dart';
import '../data/points_repository.dart';

final pointsRepositoryProvider = Provider<PointsRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  return PointsRepository(api: PointsApi(client));
});

final pointsBalanceProvider = FutureProvider<num>((ref) async {
  final repo = ref.read(pointsRepositoryProvider);
  return repo.getBalance();
});

final pointsHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.read(pointsRepositoryProvider);
  return repo.getHistory();
});
