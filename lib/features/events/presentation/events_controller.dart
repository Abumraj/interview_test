import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../data/events_api.dart';
import '../data/events_repository.dart';
import '../domain/event.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  final CacheManager cache = ref.watch(cacheManagerProvider);
  return EventsRepository(api: EventsApi(client), cache: cache);
});

class EventsListState {
  final List<Event> all;
  final int visibleCount;
  final bool isLoadingMore;

  const EventsListState({
    required this.all,
    required this.visibleCount,
    required this.isLoadingMore,
  });

  List<Event> get visible {
    final end = visibleCount.clamp(0, all.length);
    return all.take(end).toList(growable: false);
  }

  bool get hasMore => visibleCount < all.length;
}

final eventsListControllerProvider =
    AsyncNotifierProvider<EventsListController, EventsListState>(
      EventsListController.new,
    );

class EventsListController extends AsyncNotifier<EventsListState> {
  static const int _pageSize = 10;

  @override
  Future<EventsListState> build() async {
    final repo = ref.read(eventsRepositoryProvider);

    final events = await repo.getEventsCachedFirst();

    unawaited(
      repo.revalidateEventsInBackground().then((_) async {
        final updated = await repo.getEventsCachedFirst();
        final current = state.value;
        final visibleCount = current?.visibleCount ?? _pageSize;
        state = AsyncData(
          EventsListState(
            all: updated,
            visibleCount: visibleCount.clamp(0, updated.length),
            isLoadingMore: false,
          ),
        );
      }),
    );

    return EventsListState(
      all: events,
      visibleCount: events.length < _pageSize ? events.length : _pageSize,
      isLoadingMore: false,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (current.isLoadingMore) return;
    if (!current.hasMore) return;

    state = AsyncData(
      EventsListState(
        all: current.all,
        visibleCount: current.visibleCount,
        isLoadingMore: true,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 150));

    final nextCount = (current.visibleCount + _pageSize).clamp(
      0,
      current.all.length,
    );

    state = AsyncData(
      EventsListState(
        all: current.all,
        visibleCount: nextCount,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final eventDetailsProvider = FutureProvider.family<Event?, String>((
  ref,
  id,
) async {
  final repo = ref.read(eventsRepositoryProvider);
  final event = await repo.getEventDetailsCachedFirst(id);

  unawaited(repo.revalidateEventDetailsInBackground(id));

  return event;
});
