import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../../../models/notification.dart';
import '../data/notifications_api.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final ApiClient client = ref.watch(apiClientProvider);
  return NotificationsRepository(api: NotificationsApi(client));
});

// ── Unread count ──────────────────────────────────────────────────────────────

final unreadCountProvider = AsyncNotifierProvider<UnreadCountController, int>(
  UnreadCountController.new,
);

class UnreadCountController extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      return await repo.getUnreadCount();
    } catch (_) {
      return 0;
    }
  }

  Future<void> refresh() async {
    try {
      final count =
          await ref.read(notificationsRepositoryProvider).getUnreadCount();
      state = AsyncData(count);
    } catch (_) {
      state = AsyncData(state.value ?? 0);
    }
  }

  void decrement() {
    final current = state.value ?? 0;
    if (current > 0) {
      state = AsyncData(current - 1);
    }
  }
}

// ── Notifications list ────────────────────────────────────────────────────────

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsListController, List<NotificationData>>(
      NotificationsListController.new,
    );

class NotificationsListController
    extends AsyncNotifier<List<NotificationData>> {
  @override
  Future<List<NotificationData>> build() async {
    final repo = ref.read(notificationsRepositoryProvider);
    return repo.getMyNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final list =
          await ref.read(notificationsRepositoryProvider).getMyNotifications();
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ref
          .read(notificationsRepositoryProvider)
          .markAsRead(notificationId: notificationId);

      final current = state.value ?? [];
      state = AsyncData(
        current
            .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
            .toList(),
      );

      ref.read(unreadCountProvider.notifier).decrement();
    } catch (e) {
      if (kDebugMode) print('Failed to mark notification as read: $e');
    }
  }
}

// ── FCM token registration ───────────────────────────────────────────────────

Future<void> registerFcmToken(NotificationsRepository repo) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    final deviceType = Platform.isIOS ? 'ios' : 'android';
    await repo.registerToken(token: token, deviceType: deviceType);
  } catch (e) {
    if (kDebugMode) print('FCM token registration failed: $e');
  }
}

Future<void> unregisterFcmToken(NotificationsRepository repo) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    await repo.unregisterToken(token: token);
  } catch (e) {
    if (kDebugMode) print('FCM token unregistration failed: $e');
  }
}
