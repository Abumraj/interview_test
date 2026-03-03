import 'dart:async';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../domain/event.dart';
import 'events_api.dart';

class EventsRepository {
  EventsRepository({required EventsApi api, required CacheManager cache})
    : _api = api,
      _cache = cache;

  final EventsApi _api;
  final CacheManager _cache;

  List<Event> _parseEvents(Object? json) {
    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['events'] ?? raw['results'] ?? raw['items'];
    }

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Event.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }

    return const <Event>[];
  }

  Event? _parseEvent(Object? json) {
    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['event'];
      if (data is Map<String, dynamic>) {
        raw = data;
      }
    }

    if (raw is Map<String, dynamic>) {
      return Event.fromJson(raw);
    }
    return null;
  }

  Future<List<Event>> getEventsCachedFirst() async {
    final cached = await _cache.readJson(CacheKeys.eventsList);
    if (cached != null) {
      return _parseEvents(cached);
    }

    final fresh = await _api.getEvents();
    if (fresh is Map<String, dynamic>) {
      await _cache.writeJson(CacheKeys.eventsList, fresh);
    } else if (fresh is List) {
      await _cache.writeJson(CacheKeys.eventsList, <String, dynamic>{
        'data': fresh,
      });
    }

    return _parseEvents(fresh);
  }

  Future<void> revalidateEventsInBackground() async {
    try {
      final fresh = await _api.getEvents();
      if (fresh is Map<String, dynamic>) {
        await _cache.writeJson(CacheKeys.eventsList, fresh);
      } else if (fresh is List) {
        await _cache.writeJson(CacheKeys.eventsList, <String, dynamic>{
          'data': fresh,
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<Event?> getEventDetailsCachedFirst(String id) async {
    final key = CacheKeys.eventDetails(id);
    final cached = await _cache.readJson(key);
    if (cached != null) {
      return _parseEvent(cached);
    }

    final fresh = await _api.getEventById(id);
    if (fresh is Map<String, dynamic>) {
      await _cache.writeJson(key, fresh);
    }

    return _parseEvent(fresh);
  }

  Future<void> revalidateEventDetailsInBackground(String id) async {
    final key = CacheKeys.eventDetails(id);
    try {
      final fresh = await _api.getEventById(id);
      if (fresh is Map<String, dynamic>) {
        await _cache.writeJson(key, fresh);
      }
    } catch (_) {
      // ignore
    }
  }
}
