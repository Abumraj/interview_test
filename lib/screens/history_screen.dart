import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:interview/const.dart';
import 'package:interview/features/history/presentation/history_controller.dart';
import 'package:interview/helpers/date_extension.dart';
import 'package:interview/screens/event_ticket_list.dart';
import 'package:interview/screens/order_screen.dart';
import 'package:interview/screens/widgets/dashboard_header.dart';
import 'package:interview/screens/widgets/section_header.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/money_formatter.dart';
import 'package:interview/utils/page_transitions.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            height10,
            // Profile + Icons Row
            DashboardHeader(),
            const SectionHeader(title: "History"),
            Expanded(
              child: purchasesAsync.when(
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
                              .read(purchasesControllerProvider.notifier)
                              .retry();
                        },
                        child: const Text('Retry'),
                      ),
                    ),
                data: (purchases) {
                  if (purchases.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(purchasesControllerProvider.notifier)
                            .retry();
                      },
                      child: const Center(child: Text('No history found')),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(purchasesControllerProvider.notifier)
                          .retry();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = purchases[index];
                        final amount =
                            purchase.totalPrice ??
                            (purchase.raw?['amount'] as num?) ??
                            0;
                        final subtitle = purchase.createdAt ?? '';
                        final mainAmount = MoneyFormatter.ngn(amount);

                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  SlideRightRoute(
                                    page:
                                        purchase.raw!['type']
                                                    .toString()
                                                    .toLowerCase() ==
                                                'event'
                                            ? EventTicketList()
                                            : OrderScreen(
                                              bookingId: purchase.id,
                                            ),
                                  ),
                                );
                              },
                              leading: Container(
                                width: 36.h,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: AppColors.subcolor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    purchase.raw!['type']
                                                .toString()
                                                .toLowerCase() ==
                                            'event'
                                        ? 'assets/images/calendar-tick.svg'
                                        : 'assets/images/bag-happy-inline.svg',

                                    colorFilter: const ColorFilter.mode(
                                      AppColors.whiteTextColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                purchase.raw!['title'] ?? '',
                                style: CustomTextStyle.bodyLarge.copyWith(
                                  color: AppColors.whiteTextColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                formatDateTimeToLocal(
                                  purchase.raw!['date'] ?? subtitle,
                                ),
                                style: CustomTextStyle.caption1.copyWith(
                                  color: AppColors.whiteTextColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              trailing: Text(
                                mainAmount,
                                style: CustomTextStyle.bodyLarge.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.whiteTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Divider(
                              color: AppColors.whiteColor.withOpacity(0.1),
                            ),
                          ],
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
