import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interview/const.dart';
import 'package:interview/features/profile/presentation/profile_controller.dart';
import 'package:interview/features/bookings/presentation/bookings_controller.dart';
import 'package:interview/features/cart/presentation/cart_controller.dart';
import 'package:interview/features/history/presentation/history_controller.dart';
import 'package:interview/features/payments/presentation/payments_controller.dart';
import 'package:intl/intl.dart';
import 'package:interview/screens/product_detail_screen.dart';
import 'package:interview/screens/payment_webview_screen.dart';
import 'package:interview/screens/order_screen.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/money_formatter.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/utils/page_transitions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderBagScreen extends ConsumerStatefulWidget {
  const OrderBagScreen({super.key});

  @override
  ConsumerState<OrderBagScreen> createState() => _OrderBagScreenState();
}

class _OrderBagScreenState extends ConsumerState<OrderBagScreen> {
  bool bonusPointEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(cartItemsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(cartItemsProvider);
    final paymentsAsync = ref.watch(paymentsControllerProvider);
    final cartAsync = ref.watch(cartControllerProvider);
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(
        // stepText: "Step 1 of 4",
        showProgress: false,
        title: '',
        // textColor: AppTheme.scaffoldDark,
        // Colors automatically use AppTheme
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Title with badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  height20,
                  const Text(
                    'Order Bag',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  itemsAsync.when(
                    loading: () => const CartBadge(count: 0),
                    error: (_, __) => const CartBadge(count: 0),
                    data: (items) {
                      final count = items.fold<int>(
                        0,
                        (sum, item) => sum + (item.quantity ?? 1),
                      );
                      final current = ref.read(cartCountProvider);
                      if (current != count) {
                        Future.microtask(() {
                          ref.read(cartCountProvider.notifier).state = count;
                        });
                      }
                      return CartBadge(count: count);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order items list
            Expanded(
              child: itemsAsync.when(
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
                          ref.invalidate(cartItemsProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ),
                data: (items) {
                  if (items.isEmpty) {
                    final current = ref.read(cartCountProvider);
                    if (current != 0) {
                      Future.microtask(() {
                        ref.read(cartCountProvider.notifier).state = 0;
                      });
                    }
                    return const Center(child: Text('Your bag is empty'));
                  }

                  final count = items.fold<int>(
                    0,
                    (sum, item) => sum + (item.quantity ?? 1),
                  );
                  final current = ref.read(cartCountProvider);
                  if (current != count) {
                    Future.microtask(() {
                      ref.read(cartCountProvider.notifier).state = count;
                    });
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(cartItemsProvider);
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 220.h),
                      itemCount: items.length,
                      separatorBuilder:
                          (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Divider(
                              color: Color(0xFF1A4A63),
                              height: 56,
                              thickness: 1,
                            ),
                          ),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final qty = item.quantity ?? 1;
                        final amount = item.amount ?? ((item.price ?? 0) * qty);
                        final available = item.isAvailable ?? true;

                        String durationLabel(int? minutes) {
                          if (minutes == null || minutes <= 0) return '—';
                          if (minutes >= 60 && minutes % 60 == 0) {
                            final h = minutes ~/ 60;
                            return '${h}hrs';
                          }
                          return '${minutes} mins';
                        }

                        String timeSlotLabel(DateTime? dt) {
                          if (dt == null) return '';
                          final local = dt.toLocal();
                          return DateFormat('hh:mm a  |  dd MMM').format(local);
                        }

                        final option1 =
                            (item.variantType ?? '').trim().isNotEmpty
                                ? item.variantType!.toString()
                                : (qty > 1 ? '$qty People' : 'Solo');
                        final option2 = durationLabel(item.duration);

                        final img = (item.imageUrl ?? '').trim();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OrderItemCard(
                                imageUrl: img,
                                title: item.name,
                                option1: option1,
                                option2: option2,
                                option1List: <String>[option1],
                                option2List: <String>[option2],
                                price: MoneyFormatter.ngn(amount),
                                onEdit: () {
                                  final productId = item.productId ?? '';
                                  if (productId.isEmpty) return;
                                  Navigator.of(context)
                                      .push(
                                        SlideUpRoute(
                                          page: ProductDetailScreen(
                                            productId: productId,
                                            editingBagItemId: item.id,
                                            editingPricingId: item.pricingId,
                                            editingDuration: item.duration,
                                            editingStartTime: item.date,
                                            editingMeta: item.meta,
                                            editingCategory: item.category,
                                          ),
                                        ),
                                      )
                                      .then((_) {
                                        ref.invalidate(cartItemsProvider);
                                      });
                                },
                                onRemove: () async {
                                  if (cartAsync.isLoading) return;
                                  if (item.id.isEmpty) return;
                                  try {
                                    await ref
                                        .read(cartControllerProvider.notifier)
                                        .removeItem(bagItemId: item.id);
                                    ToastHelper.showSuccess('Removed from bag');
                                  } catch (e) {
                                    ToastHelper.showError(e.toString());
                                  }
                                },
                              ),
                              if (item.date != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.white54,
                                        size: 14.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        timeSlotLabel(item.date),
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (!available)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppColors.error,
                                        size: 14.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'This timeslot is no longer available',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
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
      bottomNavigationBar: itemsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (items) {
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }

          final hasUnavailable = items.any((e) => e.isAvailable == false);

          final subTotal = items.fold<int>(0, (sum, item) {
            final qty = item.quantity ?? 1;
            final fallback = (item.price ?? 0) * qty;
            return sum + (item.amount ?? fallback);
          });

          final user = ref.watch(profileControllerProvider).value;
          final bonusPoints = user?.points ?? 0;

          final deduction = bonusPointEnabled ? bonusPoints : 0;
          final total = (subTotal - deduction).clamp(0, subTotal);

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 24 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.subcolor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        PricingRow(
                          label: 'Sub total:',
                          amount: MoneyFormatter.ngn(subTotal),
                          isSubtotal: true,
                        ),
                        const SizedBox(height: 16),
                        BonusPointRow(
                          enabled: bonusPointEnabled,
                          amount: MoneyFormatter.ngn(bonusPoints),
                          onToggle: (value) {
                            setState(() {
                              bonusPointEnabled = value;
                            });
                          },
                        ),
                        const Divider(
                          color: Color(0xFF1A4A63),
                          height: 32,
                          thickness: 1,
                        ),
                        PricingRow(
                          label: 'Total (VAT inclusive):',
                          amount: MoneyFormatter.ngn(total),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    onTap: () async {
                      if (hasUnavailable) {
                        ToastHelper.showWarning(
                          'Some items in your bag are no longer available. Please edit or remove them to continue.',
                        );
                        return;
                      }
                      if (paymentsAsync.isLoading || cartAsync.isLoading) {
                        return;
                      }

                      try {
                        final checkedOut =
                            await ref
                                .read(cartControllerProvider.notifier)
                                .checkout();
                        final paymentId = checkedOut.paymentId;
                        final amount = checkedOut.totalAmount;
                        if (paymentId.isEmpty || amount <= 0) {
                          ToastHelper.showError('Checkout failed');
                          return;
                        }

                        final callbackUrl = 'myapp://payment/callback';
                        final init = await ref
                            .read(paymentsControllerProvider.notifier)
                            .initialize(
                              paymentId: paymentId,
                              redirectUrl: callbackUrl,
                              amount: amount,
                              isBonusPointUsed: bonusPointEnabled,
                            );

                        if (!mounted) return;
                        if (init.completed == false) {
                          final result = await Navigator.of(context).push<bool>(
                            SlideUpRoute(
                              page: PaymentWebViewScreen(
                                initialUrl: init.checkoutUrl,
                                callbackUrlPrefix: callbackUrl,
                                txRef: init.txRef,
                              ),
                            ),
                          );

                          if (result == true) {
                            ref
                                .read(purchasesControllerProvider.notifier)
                                .retry();
                            ref.read(cartCountProvider.notifier).state = 0;
                            ref.invalidate(cartItemsProvider);
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              FadeScaleRoute(
                                page: OrderScreen(paymentId: paymentId),
                              ),
                              (route) => route.isFirst,
                            );
                            return;
                          }
                        } else if (init.completed == true) {
                          ToastHelper.showSuccess(
                            'Payment completed successfully',
                          );

                          Navigator.of(context).pushAndRemoveUntil(
                            FadeScaleRoute(
                              page: OrderScreen(paymentId: paymentId),
                            ),
                            (route) => route.isFirst,
                          );
                        }

                        ToastHelper.showWarning('Payment not completed');
                      } catch (e) {
                        ToastHelper.showError(e.toString());
                      }
                    },
                    height: 55.h,
                    buttonText: "Proceed to Payment",
                    buttonColor:
                        hasUnavailable
                            ? Colors.grey
                            : AppColors.bottomNavBarHighlightColor,
                    textColor: AppColors.whiteColor,
                    borderRadius: 30.r,
                    isLoading: paymentsAsync.isLoading || cartAsync.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Reusable Components

class CustomBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0A3D5C)),
        onPressed: onPressed,
      ),
    );
  }
}

class CartBadge extends StatelessWidget {
  final int count;
  final double size;
  final double iconSize;

  const CartBadge({
    super.key,
    required this.count,
    this.size = 30,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/bag-happy.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFF8C42),
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String option1;
  final String option2;
  final List<String> option1List;
  final List<String> option2List;
  final String price;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final ValueChanged<String>? onOption1Changed;
  final ValueChanged<String>? onOption2Changed;

  const OrderItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.option1,
    required this.option2,
    required this.option1List,
    required this.option2List,
    required this.price,
    required this.onEdit,
    required this.onRemove,
    this.onOption1Changed,
    this.onOption2Changed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 120.w,
            height: 120.w,
            color: AppColors.subcolor,
            child:
                imageUrl.trim().isEmpty
                    ? Icon(Icons.image, size: 28.sp, color: Colors.white24)
                    : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Icon(
                            Icons.image,
                            size: 28.sp,
                            color: Colors.white24,
                          ),
                      errorWidget:
                          (_, __, ___) => Icon(
                            Icons.image,
                            size: 28.sp,
                            color: Colors.white24,
                          ),
                    ),
          ),
        ),
        SizedBox(width: 12.w),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CustomTextStyle.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              height8,
              Row(
                children: [
                  OptionChip(
                    selectedValue: option1,
                    options: option1List,
                    onChanged: onOption1Changed,
                  ),
                  SizedBox(width: 8.w),
                  OptionChip(
                    selectedValue: option2,
                    options: option2List,
                    onChanged: onOption2Changed,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                price,
                style: CustomTextStyle.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Edit',
                      style: CustomTextStyle.bodySmall.copyWith(
                        color: AppColors.whiteGreenColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Text('  |  ', style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: onRemove,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Remove',
                      style: CustomTextStyle.bodySmall.copyWith(
                        color: AppColors.error,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OptionChip extends StatefulWidget {
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String>? onChanged;

  const OptionChip({
    super.key,
    required this.selectedValue,
    required this.options,
    this.onChanged,
  });

  @override
  State<OptionChip> createState() => _OptionChipState();
}

class _OptionChipState extends State<OptionChip> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(OptionChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _selectedValue = widget.selectedValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.subCardcolor,
        borderRadius: BorderRadius.circular(8),
      ),
      height: 30.h,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedValue,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 18,
          ),
          iconSize: 18,
          elevation: 16,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          dropdownColor: const Color(0xFF1A4A63),
          borderRadius: BorderRadius.circular(8),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedValue = newValue;
              });
              widget.onChanged?.call(newValue);
            }
          },
          items:
              widget.options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

class PricingRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isSubtotal;
  final bool isTotal;

  const PricingRow({
    super.key,
    required this.label,
    required this.amount,
    this.isSubtotal = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isTotal ? 12 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class BonusPointRow extends StatelessWidget {
  final bool enabled;
  final String amount;
  final ValueChanged<bool> onToggle;

  const BonusPointRow({
    super.key,
    required this.enabled,
    required this.amount,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: enabled,
              onChanged: (value) => onToggle(value ?? false),
              activeColor: const Color(0xFF00C853),
              checkColor: Colors.white,
              side: const BorderSide(color: Colors.white54, width: 1),
            ),
            const Text(
              'Bonus Point',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
