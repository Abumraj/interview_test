import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/features/history/presentation/history_controller.dart';
import 'package:interview/screens/order_ticket_detail_screen.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/screens/widgets/detail_row.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/screens/widgets/section_header.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/money_formatter.dart';
import 'package:interview/utils/page_transitions.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(purchaseDetailsProvider(bookingId));

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(showProgress: false, title: 'Details'),
      bottomNavigationBar: detailsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (details) {
          if (details == null) return const SizedBox.shrink();
          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.h,
                12.h,
                20.h,
                12.h + bottomInset,
              ),
              child: CustomButton(
                onTap: () {
                  Navigator.of(context).push(
                    SlideRightRoute(
                      page: OrderTicketDetailScreen(
                        bookingId: bookingId,
                        details: details,
                      ),
                    ),
                  );
                },
                height: 55.h,
                buttonText: 'view Receipt',
                buttonColor: AppColors.backgroundColor,
                textColor: AppColors.whiteColor,
                borderRadius: 30.r,
                borderColor: AppColors.whiteColor,
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: detailsAsync.when(
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
                      ref.invalidate(purchaseDetailsProvider(bookingId));
                    },
                    child: const Text('Retry'),
                  ),
                ),
            data: (details) {
              if (details == null) {
                return const Center(child: Text('No details found'));
              }

              final durationLabel =
                  details.duration == null
                      ? ''
                      : (details.duration! >= 60 && details.duration! % 60 == 0
                          ? '${details.duration! ~/ 60} hours'
                          : '${details.duration} mins');
              final capacityLabel =
                  details.capacity == null ? '' : '${details.capacity} people';
              final amountLabel = MoneyFormatter.ngn(details.amount);

              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 120.h),
                child: Column(
                  children: [
                    const SectionHeader(title: 'Summary'),
                    height20,
                    DetailRow(
                      label: 'Leisure type',
                      value: details.leisureType,
                    ),
                    height16,
                    DetailRow(label: 'Capacity', value: capacityLabel),
                    height16,
                    DetailRow(label: 'Duration', value: durationLabel),
                    height16,
                    DetailRow(label: 'Amount', value: amountLabel),
                    height16,
                    Divider(color: AppColors.whiteColor.withOpacity(0.2)),
                    height16,
                    DetailRow(
                      label: 'Total Amount (VAT inclusive)',
                      value: amountLabel,
                      fontSize: 15.sp,
                      fontWeight: 600,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
