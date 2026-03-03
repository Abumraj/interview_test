import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/core/cache/cache_keys.dart';
import 'package:interview/core/cache/cache_manager.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/features/bookings/presentation/bookings_controller.dart';
import 'package:interview/features/events/presentation/events_controller.dart';
import 'package:interview/features/history/presentation/history_controller.dart';
import 'package:interview/features/payments/presentation/payments_controller.dart';
import 'package:interview/features/tickets/presentation/tickets_controller.dart';
import 'package:interview/screens/event_ticket_list.dart';
import 'package:interview/screens/order_screen.dart';
import 'package:interview/screens/payment_webview_screen.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/screens/widgets/customized_text.dart';
import 'package:interview/screens/widgets/event_card_total.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/utils/page_transitions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  int _quantity = 1;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(
        // stepText: "Step 1 of 4",
        showProgress: false,
        title: '',
        // textColor: AppTheme.scaffoldDark,
        // Colors automatically use AppTheme
      ),

      bottomNavigationBar: eventAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (event) {
          final price = (event?.price ?? 0).toDouble();
          final slotId =
              (event?.slots.isNotEmpty == true) ? event!.slots[0].slotId : '';
          final bookable = event?.isBookable ?? true;

          return SafeArea(
            top: false,
            child: Container(
              color: AppColors.backgroundColor,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!bookable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event?.statusReason != null &&
                                  event!.statusReason!.isNotEmpty
                              ? event.statusReason!
                              : 'This event is not available for booking at the moment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  QuantityTotalCard(
                    initialQuantity: _quantity,
                    minQuantity: 1,
                    unitPrice: price,
                    backgroundColor: AppColors.subcolor,
                    onQuantityChanged: (q) {
                      setState(() {
                        _quantity = q;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  CustomButton(
                    onTap:
                        !bookable
                            ? () {
                              ToastHelper.showWarning(
                                'This event is not available for booking at the moment.',
                              );
                            }
                            : () async {
                              if (_isBooking) return;

                              final authUser =
                                  ref.read(authControllerProvider).value?.user;
                              if (authUser == null || authUser.id.isEmpty) {
                                ToastHelper.showWarning(
                                  'Please login to continue',
                                );
                                return;
                              }

                              setState(() {
                                _isBooking = true;
                              });

                              try {
                                final totalPrice = price * _quantity;

                                final cachedPaymentJson = await ref
                                    .read(cacheManagerProvider)
                                    .readJson(CacheKeys.activePaymentId);
                                final cachedPaymentId =
                                    cachedPaymentJson?['paymentId']
                                        ?.toString() ??
                                    '';

                                final booking = await ref
                                    .read(bookingsControllerProvider.notifier)
                                    .bookEvent(
                                      userId: authUser.id,
                                      slotId: slotId,
                                      paymentId:
                                          cachedPaymentId.isEmpty
                                              ? null
                                              : cachedPaymentId,
                                      totalPrice: totalPrice,
                                      meta: <String, dynamic>{
                                        // 'eventId': widget.eventId,
                                        'quantity': _quantity,
                                        'price': price,
                                      },
                                    );

                                final paymentId = booking?.paymentId ?? '';
                                if (paymentId.isEmpty) {
                                  throw StateError(
                                    'Booking was created but no payment id was returned',
                                  );
                                }

                                await ref.read(cacheManagerProvider).writeJson(
                                  CacheKeys.activePaymentId,
                                  <String, dynamic>{'paymentId': paymentId},
                                );

                                ref.read(cartCountProvider.notifier).state +=
                                    _quantity;
                                ref.invalidate(bookedItemsProvider(paymentId));

                                final callbackUrl = 'myapp://payment/callback';

                                final init = await ref
                                    .read(paymentsControllerProvider.notifier)
                                    .initialize(
                                      paymentId: paymentId,
                                      redirectUrl: callbackUrl,
                                      amount: totalPrice.toInt(),
                                    );

                                if (!mounted) return;
                                final result = await Navigator.of(
                                  context,
                                ).push<bool>(
                                  SlideUpRoute(
                                    page: PaymentWebViewScreen(
                                      initialUrl: init.checkoutUrl,
                                      callbackUrlPrefix: callbackUrl,
                                      txRef: init.txRef,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  ref.invalidate(myTicketsControllerProvider);
                                  ref
                                      .read(
                                        purchasesControllerProvider.notifier,
                                      )
                                      .retry();
                                  await ref
                                      .read(cacheManagerProvider)
                                      .remove(CacheKeys.activePaymentId);
                                  ref.read(cartCountProvider.notifier).state =
                                      0;
                                  ref.invalidate(
                                    bookedItemsProvider(paymentId),
                                  );
                                  if (!mounted) return;
                                  Navigator.of(context).pushAndRemoveUntil(
                                    FadeScaleRoute(page: EventTicketList()),
                                    (route) => route.isFirst,
                                  );
                                  return;
                                }

                                ToastHelper.showWarning(
                                  'Payment not completed',
                                );
                              } catch (e) {
                                final msg =
                                    e is ApiException
                                        ? e.message
                                        : e.toString();
                                ToastHelper.showError(msg);
                              } finally {
                                if (!mounted) return;
                                setState(() {
                                  _isBooking = false;
                                });
                              }
                            },
                    height: 55.h,
                    buttonText: "Pay now",
                    buttonColor:
                        bookable
                            ? AppColors.bottomNavBarHighlightColor
                            : Colors.grey,
                    textColor: AppColors.whiteColor,
                    borderRadius: 30.r,
                    isLoading: _isBooking,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: eventAsync.when(
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
                    ref.invalidate(eventDetailsProvider(widget.eventId));
                  },
                  child: const Text('Retry'),
                ),
              ),
          data: (event) {
            final title = event?.title ?? 'Event';
            final description = event?.description ?? '';
            final imageUrl = event?.eventImg ?? '';
            final time = event?.time ?? '';
            final address = event?.address ?? '';
            String formatLongDate(DateTime dt) {
              const months = <String>[
                'January',
                'February',
                'March',
                'April',
                'May',
                'June',
                'July',
                'August',
                'September',
                'October',
                'November',
                'December',
              ];
              final local = dt.toLocal();
              final monthName = months[local.month - 1];
              final day = local.day.toString().padLeft(2, '0');
              return '$monthName $day, ${local.year}.';
            }

            final startDate = event?.startDate;
            final recurrenceRule = (event?.recurrenceRule ?? '').trim();
            final date =
                recurrenceRule.isNotEmpty
                    ? recurrenceRule
                    : (startDate == null ? '' : formatLongDate(startDate));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(eventDetailsProvider(widget.eventId));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                          bottom: Radius.circular(8),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              imageUrl.isEmpty
                                  ? 'https://picsum.photos/500/300?${widget.eventId}'
                                  : imageUrl,
                          height: 400.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                height: 400.h,
                                width: double.infinity,
                                color: AppColors.subcolor,
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                height: 400.h,
                                width: double.infinity,
                                color: AppColors.subcolor,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.white24,
                                ),
                              ),
                        ),
                      ),
                      height20,
                      Row(
                        children: [
                          Text(
                            "Venue: ",
                            style: CustomTextStyle.bodyLarge.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              address,
                              style: CustomTextStyle.bodyLarge.copyWith(
                                color: AppColors.whiteColor,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      height20,
                      Row(
                        children: [
                          Text(
                            "Date: ",
                            style: CustomTextStyle.bodyLarge.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            date,
                            style: CustomTextStyle.bodyLarge.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      height20,
                      Row(
                        children: [
                          Text(
                            "Time: ",
                            style: CustomTextStyle.bodyLarge.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            time,
                            style: CustomTextStyle.bodyLarge.copyWith(
                              color: AppColors.whiteColor,
                              // fontSize: 16.sp,
                              // fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      height10,
                      DescriptionTextWidget(
                        text: description,
                        title: "",
                        txt_count: 100,
                      ),
                      SizedBox(height: 140.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
