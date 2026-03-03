import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../domain/ticket.dart';
import 'tickets_api.dart';

class TicketsRepository {
  TicketsRepository({required TicketsApi api, required CacheManager cache})
    : _api = api,
      _cache = cache;

  final TicketsApi _api;
  final CacheManager _cache;

  Object? _unwrapTicketsPayload(Object? json) {
    Object? raw = json;

    // Handle Map<dynamic, dynamic> as well.
    if (raw is Map) {
      final v =
          raw['flattenedTickets'] ??
          raw['tickets'] ??
          raw['results'] ??
          raw['items'] ??
          raw['data'];
      raw = v;

      // Common backend shape: { data: { flattenedTickets: [...] } }
      if (raw is Map) {
        raw =
            raw['flattenedTickets'] ??
            raw['tickets'] ??
            raw['results'] ??
            raw['items'] ??
            raw['data'] ??
            raw;
      }
    }

    return raw;
  }

  List<Ticket> _parseTickets(Object? json) {
    final raw = _unwrapTicketsPayload(json);

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Ticket.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }

    return const <Ticket>[];
  }

  Future<List<Ticket>> getTicketsCachedFirst() async {
    final cached = await _cache.readJson(CacheKeys.ticketsList);
    if (cached != null) {
      return _parseTickets(cached);
    }

    final fresh = await _api.getMyTickets();
    if (fresh is Map<String, dynamic>) {
      await _cache.writeJson(CacheKeys.ticketsList, fresh);
    } else if (fresh is List) {
      await _cache.writeJson(CacheKeys.ticketsList, <String, dynamic>{
        'data': fresh,
      });
    }

    return _parseTickets(fresh);
  }

  Future<void> revalidateTicketsInBackground() async {
    try {
      final fresh = await _api.getMyTickets();
      if (fresh is Map<String, dynamic>) {
        await _cache.writeJson(CacheKeys.ticketsList, fresh);
      } else if (fresh is List) {
        await _cache.writeJson(CacheKeys.ticketsList, <String, dynamic>{
          'data': fresh,
        });
      }
    } catch (e) {
      print(e);
      // ignore
    }
  }
}
