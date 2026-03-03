import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

typedef JsonMap = Map<String, dynamic>;

class CacheEntry {
  const CacheEntry({required this.value, required this.savedAt});

  final JsonMap value;
  final DateTime savedAt;

  JsonMap toJson() => <String, dynamic>{
    'value': value,
    'savedAt': savedAt.toIso8601String(),
  };

  static CacheEntry? fromJson(Object? json) {
    if (json is! JsonMap) return null;
    final value = json['value'];
    final savedAt = json['savedAt'];

    if (value is! JsonMap) return null;
    if (savedAt is! String) return null;

    final parsed = DateTime.tryParse(savedAt);
    if (parsed == null) return null;

    return CacheEntry(value: value, savedAt: parsed);
  }
}

class CacheManager {
  Duration ttl;

  CacheManager({this.ttl = const Duration(minutes: 15)});

  Duration? _ttlForKey(String key) {
    // auth_user drives persistent login; do not expire it automatically.
    if (key == 'auth_user') return null;

    // Active payment id should expire quickly to avoid stale carts.
    if (key == 'active_payment_id') return const Duration(minutes: 8);

    return ttl;
  }

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<JsonMap?> readJson(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      await prefs.remove(key);
      return null;
    }
    final entry = CacheEntry.fromJson(decoded);
    if (entry == null) return null;

    final keyTtl = _ttlForKey(key);
    if (keyTtl != null) {
      final isExpired = DateTime.now().difference(entry.savedAt) > keyTtl;
      if (isExpired) {
        await prefs.remove(key);
        return null;
      }
    }

    return entry.value;
  }

  Future<void> writeJson(String key, JsonMap value) async {
    final prefs = await _prefs;
    final entry = CacheEntry(value: value, savedAt: DateTime.now());
    await prefs.setString(key, jsonEncode(entry.toJson()));
  }

  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
