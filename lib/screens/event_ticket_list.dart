import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/features/tickets/presentation/tickets_controller.dart';
import 'package:interview/helpers/date_extension.dart';
import 'package:interview/screens/event_ticket_detail_screen.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/screens/widgets/event_ticket_card.dart';
import 'package:interview/utils/page_transitions.dart';

class EventTicketList extends ConsumerWidget {
  const EventTicketList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(
        // stepText: "Step 1 of 4",
        showProgress: false,
        title: 'Event Tickets',
        // textColor: AppTheme.scaffoldDark,
        // Colors automatically use AppTheme
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ticketsAsync.when(
            loading:
                () => Center(
                  child: SpinKitFadingCircle(
                    size: 30,
                    color: AppColors.whiteColor,
                  ),
                ),
            error:
                (err, st) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.whiteColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          st.toString(),
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.whiteColor.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.whiteColor,
                          ),
                          onPressed: () {
                            ref
                                .read(myTicketsControllerProvider.notifier)
                                .retry();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
            data: (tickets) {
              print(tickets);
              if (tickets.isEmpty) {
                return const Center(child: Text('No tickets found'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(myTicketsControllerProvider.notifier).retry();
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    final title =
                        ticket.eventName ?? ticket.eventTitle ?? 'Event';

                    final rawDate = ticket.date ?? ticket.eventDate ?? '';
                    final formattedDate =
                        rawDate.isEmpty ? '' : formatDateIso(rawDate);

                    final time = ticket.time;
                    final dateText =
                        time == null || time.trim().isEmpty
                            ? formattedDate
                            : '$formattedDate at ${time.trim()}';

                    final qr = ticket.qrPayload ?? ticket.qr ?? '';

                    return EventTicketCard(
                      eventImage: ticket.eventImage ?? 'assets/event.jpg',
                      eventDate: dateText,
                      eventTitle: title,
                      qrCode: qr,
                      onViewTicket: () {
                        Navigator.of(context).push(
                          SlideRightRoute(
                            page: EventTicketDetailScreen(
                              ticket: ticket,
                              dateLine: dateText,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
