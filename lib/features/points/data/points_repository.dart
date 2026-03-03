import 'points_api.dart';

class PointsRepository {
  PointsRepository({required PointsApi api}) : _api = api;

  final PointsApi _api;

  Future<num> getBalance() async {
    final json = await _api.getBalance();
    final raw = json['data'] ?? json;
    if (raw is Map<String, dynamic>) {
      final v = raw['balance'] ?? raw['points'] ?? raw['amount'];
      if (v is num) return v;
      return num.tryParse('$v') ?? 0;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final json = await _api.getHistory();
    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['history'] ?? raw['items'] ?? raw['results'];
    }
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }
}
