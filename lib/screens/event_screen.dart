import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/features/events/presentation/events_controller.dart';
import 'package:interview/screens/widgets/dashboard_header.dart';
import 'package:interview/screens/widgets/event_card.dart';
import 'package:interview/screens/widgets/section_header.dart';
import 'package:interview/utils/heights.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(eventsListControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsListControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            height10,
            DashboardHeader(),
            height10,
            const SectionHeader(title: "Latest Events 🔥"),
            height16,
            Expanded(
              child: eventsAsync.when(
                loading:
                    () => Center(
                      child: SpinKitFadingCircle(
                        size: 30,
                        color: AppColors.whiteColor,
                      ),
                    ),
                error:
                    (_, __) => Center(
                      child: TextButton(
                        onPressed: () {
                          ref
                              .read(eventsListControllerProvider.notifier)
                              .retry();
                        },
                        child: const Text('Retry'),
                      ),
                    ),
                data: (state) {
                  if (state.all.isEmpty) {
                    return const Center(child: Text('No events found'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(eventsListControllerProvider.notifier)
                          .retry();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.visible.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.visible.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: SpinKitFadingCircle(
                                size: 30,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          );
                        }

                        final event = state.visible[index];
                        final title = event.title ?? 'Event';
                        final description = event.description ?? '';
                        final imageUrl = event.eventImg ?? '';

                        const monthAbbr = <String>[
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        String dateLabel = '---';
                        String dayLabel = '--';
                        final raw = event.displayDay;
                        if (raw != null && raw.isNotEmpty) {
                          final parsed = DateTime.tryParse(raw);
                          if (parsed != null) {
                            dateLabel = monthAbbr[parsed.month - 1];
                            dayLabel = parsed.day.toString().padLeft(2, '0');
                          }
                        }

                        return EventCard(
                          eventId: event.id,
                          imageUrl:
                              imageUrl.isEmpty
                                  ? 'https://picsum.photos/500/300?${index + 1}'
                                  : imageUrl,
                          date: dateLabel,
                          day: dayLabel,
                          title: title,
                          description: description,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
