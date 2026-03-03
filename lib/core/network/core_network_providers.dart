import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../cache/cache_manager.dart';
import '../logging/network_logger.dart';
import 'api_client.dart';
import 'base_url_provider.dart';
import 'token_storage.dart';

final unauthorizedEventProvider = StateProvider<int>((ref) => 0);

final networkLoggerProvider = Provider<NetworkLogger>((ref) {
  return const NetworkLogger();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final cacheManager = ref.watch(cacheManagerProvider);

  return ApiClient(
    baseUrl: ref.watch(baseUrlProvider),
    getToken: tokenStorage.readAccessToken,
    getRefreshToken: tokenStorage.readRefreshToken,
    saveAccessToken: tokenStorage.writeAccessToken,
    saveRefreshToken: tokenStorage.writeRefreshToken,
    onUnauthorized: () async {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (e) {
        if (kDebugMode) print('FCM token delete on unauthorized failed: $e');
      }
      await tokenStorage.clear();
      await cacheManager.clearAll();
      ref.read(unauthorizedEventProvider.notifier).state++;
    },
    logger: ref.watch(networkLoggerProvider),
  );
});
