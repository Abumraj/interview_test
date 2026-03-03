import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/features/bookings/presentation/bookings_controller.dart';
import 'package:interview/features/history/presentation/history_controller.dart';
import 'package:interview/screens/order_detail_screen.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/money_formatter.dart';
import 'package:interview/utils/page_transitions.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key, this.paymentId, this.bookingId})
    : assert(
        (paymentId != null && paymentId != '') ||
            (bookingId != null && bookingId != ''),
      );

  final String? paymentId;
  final String? bookingId;

  String _durationLabel(int? minutes) {
    if (minutes == null) return '';
    if (minutes >= 60 && minutes % 60 == 0) {
      return '${minutes ~/ 60} hours';
    }
    return '$minutes mins';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectivePaymentId = paymentId;
    final effectiveBookingId = bookingId;

    final isHistoryMode =
        effectiveBookingId != null && effectiveBookingId.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(showProgress: false, title: 'Order'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h),
          child:
              isHistoryMode
                  ? _historyBody(context, ref, bookingId: effectiveBookingId)
                  : _paymentBody(
                    context,
                    ref,
                    paymentId: effectivePaymentId ?? '',
                  ),
        ),
      ),
    );
  }

  Widget _historyBody(
    BuildContext context,
    WidgetRef ref, {
    required String bookingId,
  }) {
    final detailsAsync = ref.watch(purchaseDetailsProvider(bookingId));

    return detailsAsync.when(
      loading:
          () => Center(
            child: SpinKitFadingCircle(size: 30, color: AppColors.whiteColor),
          ),
      error:
          (_, __) => Center(
            child: TextButton(
              onPressed: () {
                ref.invalidate(purchaseDetailsProvider(bookingId));
              },
              child: const Text('Retry'),
            ),
          ),
      data: (details) {
        if (details == null) {
          return const Center(child: Text('No order details found'));
        }

        final amountLabel = MoneyFormatter.ngn(details.amount ?? 0);
        final durationLabel = _durationLabel(details.duration);
        final capacityLabel =
            details.capacity == null ? '' : '${details.capacity} people';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            height10,
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: 1,
                separatorBuilder: (_, __) => height16,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.subcolor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width - 40.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              details.leisureType,
                              style: CustomTextStyle.bodyLarge.copyWith(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            height24,
                            if (capacityLabel.isNotEmpty)
                              Text(
                                capacityLabel,
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            if (capacityLabel.isNotEmpty) height24,
                            if (durationLabel.isNotEmpty)
                              Text(
                                durationLabel,
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            height10,
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  SlideRightRoute(
                                    page: OrderDetailScreen(
                                      bookingId: bookingId,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'View Details',
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: AppColors.whiteGreenColor,
                                ),
                              ),
                            ),
                            Text(
                              amountLabel,
                              style: CustomTextStyle.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            height16,
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.subcolor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: CustomTextStyle.bodyLarge.copyWith(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    amountLabel,
                    style: CustomTextStyle.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            height16,
          ],
        );
      },
    );
  }

  Widget _paymentBody(
    BuildContext context,
    WidgetRef ref, {
    required String paymentId,
  }) {
    final itemsAsync = ref.watch(bookedItemsProvider(paymentId));

    return itemsAsync.when(
      loading:
          () => Center(
            child: SpinKitFadingCircle(size: 30, color: AppColors.whiteColor),
          ),
      error:
          (_, __) => Center(
            child: TextButton(
              onPressed: () {
                ref.invalidate(bookedItemsProvider(paymentId));
              },
              child: const Text('Retry'),
            ),
          ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No order details found'));
        }

        final totalAmount = items.fold<int>(
          0,
          (sum, item) => sum + (item.amount ?? 0),
        );
        final amountLabel = MoneyFormatter.ngn(totalAmount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            height10,
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (_, __) => height16,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final durationLabel = _durationLabel(item.duration);
                  final capacityLabel =
                      item.quantity == null ? '' : '${item.quantity} people';
                  final bookingId = item.id.isNotEmpty ? item.id : paymentId;

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.subcolor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width - 40.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: CustomTextStyle.bodyLarge.copyWith(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            height24,
                            if (capacityLabel.isNotEmpty)
                              Text(
                                capacityLabel,
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            if (capacityLabel.isNotEmpty) height24,
                            if (durationLabel.isNotEmpty)
                              Text(
                                durationLabel,
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            height10,
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  SlideRightRoute(
                                    page: OrderDetailScreen(
                                      bookingId: bookingId,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'View Details',
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: AppColors.whiteGreenColor,
                                ),
                              ),
                            ),
                            Text(
                              MoneyFormatter.ngn(item.amount ?? 0),
                              style: CustomTextStyle.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            height16,
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.subcolor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: CustomTextStyle.bodyLarge.copyWith(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amountLabel,
                        style: CustomTextStyle.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            height16,
          ],
        );
      },
    );
  }
}
