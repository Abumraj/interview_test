import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/core/network/api_exceptions.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/features/bookings/domain/booking.dart';
import 'package:interview/features/bookings/presentation/bookings_controller.dart';
import 'package:interview/features/cart/presentation/cart_controller.dart';
import 'package:interview/features/history/presentation/history_controller.dart';
import 'package:interview/features/payments/presentation/payments_controller.dart';
import 'package:interview/features/products/domain/product.dart';
import 'package:interview/features/products/presentation/products_controller.dart';
import 'package:interview/screens/payment_webview_screen.dart';
import 'package:interview/screens/order_screen.dart';
import 'package:interview/screens/widgets/bottom_booking_summary.dart';
import 'package:interview/screens/widgets/app_dropdown_sheet.dart';
import 'package:interview/screens/widgets/custom_back_button.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/screens/widgets/rounded_input_field.dart';
import 'package:interview/screens/widgets/rounded_selector.dart';
import 'package:interview/screens/widgets/secondary_button.dart';
import 'package:interview/screens/widgets/time_selector_card.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:interview/utils/page_transitions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String? editingBagItemId;
  final String? editingPricingId;
  final int? editingDuration;
  final DateTime? editingStartTime;
  final Map<String, dynamic>? editingMeta;
  final String? editingCategory;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.editingBagItemId,
    this.editingPricingId,
    this.editingDuration,
    this.editingStartTime,
    this.editingMeta,
    this.editingCategory,
  });

  bool get isEditing =>
      editingBagItemId != null && editingBagItemId!.isNotEmpty;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _people = 10;

  String _jetSkiType = 'Instructor';
  String _transportType = 'Same Day';
  String _selectedRoute = '';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  DateTime? _toDate;
  DateTime? _fromDate;

  String _location = '';

  ProductPricing? _selectedPricing;
  ProductPricingOption? _selectedPricingOption;

  ProductTimeSlot? _selectedTimeSlot;

  ProductTimeSlot? _transportToSlot;
  ProductTimeSlot? _transportFroSlot;

  bool _isBooking = false;
  bool _isPaying = false;
  bool _addedToBag = false;
  bool _editingInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(productDetailsProvider(widget.productId));
    });
  }

  void _initEditingState(Product product) {
    if (_editingInitialized || !widget.isEditing) return;
    _editingInitialized = true;

    final meta = widget.editingMeta ?? const <String, dynamic>{};
    final cat =
        (widget.editingCategory ?? product.category ?? '').toUpperCase();

    if (widget.editingPricingId != null) {
      final match = product.pricing.where(
        (p) => p.id == widget.editingPricingId,
      );
      if (match.isNotEmpty) {
        _selectedPricing = match.first;
        final cap = _selectedPricing?.seatCapacity;
        if (cap != null && cap > 0) _people = cap;
        if (_selectedPricing!.options.isNotEmpty) {
          _selectedPricingOption = _selectedPricing!.options.first;
        }
      }
    }

    if (widget.editingStartTime != null) {
      final local = widget.editingStartTime!.toLocal();
      _selectedDate = DateTime(local.year, local.month, local.day);
      _selectedTime = TimeOfDay.fromDateTime(local);
    }

    if (cat == 'JET_SKI' ||
        cat == 'JETSKI' ||
        cat == 'JET SKI' ||
        cat == 'JET-SKI') {
      final type = meta['type']?.toString() ?? '';
      if (type.isNotEmpty) {
        _jetSkiType = type[0].toUpperCase() + type.substring(1);
      }
    } else if (cat == 'TRANSPORTATION' || cat == 'TRANSPORT') {
      final tripType = meta['tripType']?.toString() ?? '';
      _transportType = tripType == 'NEXT_DAY' ? 'Next Day' : 'Same Day';
      _selectedRoute = meta['routes']?.toString() ?? '';
      if (meta['to'] != null) {
        final toDt = DateTime.tryParse(meta['to'].toString());
        if (toDt != null) {
          final local = toDt.toLocal();
          _toDate = DateTime(local.year, local.month, local.day);
          _toTime = TimeOfDay.fromDateTime(local);
        }
      }
      if (meta['fro'] != null) {
        final froDt = DateTime.tryParse(meta['fro'].toString());
        if (froDt != null) {
          final local = froDt.toLocal();
          _fromDate = DateTime(local.year, local.month, local.day);
          _fromTime = TimeOfDay.fromDateTime(local);
        }
      }
    } else if (cat == 'BOAT_CRUISE' || cat == 'BOATCRUISE') {
      final people = (meta['people'] as num?)?.toInt();
      if (people != null && people > 0) _people = people;
    } else {
      final people = (meta['people'] as num?)?.toInt();
      if (people != null && people > 0) _people = people;
    }
  }

  Future<void> _updateCartItem({required Product product}) async {
    final pricing = _selectedPricing;
    if (pricing == null || pricing.id.isEmpty) {
      ToastHelper.showWarning('Please select a duration');
      return;
    }

    final startTime = _startTimeIsoForCategory(product.category ?? '');
    if (startTime == null || startTime.isEmpty) {
      ToastHelper.showWarning('Please select a time');
      return;
    }

    final category = (product.category ?? '').toUpperCase();
    Map<String, dynamic> meta = <String, dynamic>{};

    if (category == 'JET_SKI' ||
        category == 'JETSKI' ||
        category == 'JET SKI' ||
        category == 'JET-SKI') {
      meta = <String, dynamic>{'type': _jetSkiType.toLowerCase()};
    } else if (category == 'TRANSPORTATION' || category == 'TRANSPORT') {
      final tripType = _transportType == 'Next Day' ? 'NEXT_DAY' : 'SAME_DAY';
      final routes = product.meta?.routes ?? const <String, int>{};
      final routeMinutes = routes[_selectedRoute.trim()];
      final toDt =
          _transportToSlot?.startTime ??
          _combine(
            _transportType == 'Next Day' ? _toDate : _selectedDate,
            _toTime,
          );
      final fromDt =
          _transportFroSlot?.startTime ??
          _combine(
            _transportType == 'Next Day' ? _fromDate : _selectedDate,
            _fromTime,
          );
      if (_selectedRoute.trim().isEmpty) {
        ToastHelper.showWarning('Please select a route');
        return;
      }
      if (toDt == null || fromDt == null) {
        ToastHelper.showWarning('Please select To and Fro times');
        return;
      }
      meta = <String, dynamic>{
        'routes': _selectedRoute.trim(),
        'tripType': tripType,
        'to': toDt.toUtc().toIso8601String(),
        'fro': fromDt.toUtc().toIso8601String(),
      };
      final durationToSend = routeMinutes ?? pricing.duration;
      await ref
          .read(cartControllerProvider.notifier)
          .updateCartItem(
            bagItemId: widget.editingBagItemId!,
            data: <String, dynamic>{
              'pricingId': pricing.id,
              'startTime': startTime,
              'duration': durationToSend.toInt(),
              'meta': meta,
            },
          );
      return;
    } else {
      if (category == 'BOAT_CRUISE' || category == 'BOATCRUISE') {
        if (pricing.options.isNotEmpty && _selectedPricingOption == null) {
          ToastHelper.showWarning('Please select a duration');
          return;
        }
        final cap = _selectedPricing?.seatCapacity;
        meta = <String, dynamic>{'people': (cap ?? _people)};
      } else {
        meta =
            _hasSeatCapacity(product)
                ? <String, dynamic>{'people': _people}
                : <String, dynamic>{};
      }
    }

    final durationToSend =
        (category == 'BOAT_CRUISE' || category == 'BOATCRUISE') &&
                pricing.options.isNotEmpty
            ? ((_selectedPricingOption?.duration ??
                    pricing.options.first.duration) *
                60)
            : pricing.duration;

    await ref
        .read(cartControllerProvider.notifier)
        .updateCartItem(
          bagItemId: widget.editingBagItemId!,
          data: <String, dynamic>{
            'pricingId': pricing.id,
            'startTime': startTime,
            'duration': durationToSend.toInt(),
            'meta': meta,
          },
        );
  }

  List<ProductPricing> _sortedPricing(Product product) {
    final pricing = product.pricing.toList(growable: false);
    pricing.sort((a, b) => a.duration.compareTo(b.duration));
    return pricing;
  }

  Future<ProductTimeSlot?> _pickStartTimeFromDialog({
    required List<ProductTimeSlot> slots,
    int? boatSize,
    bool useIsAvailableOnly = false,
  }) async {
    if (!mounted) return null;
    return showDialog<ProductTimeSlot>(
      context: context,
      builder:
          (ctx) => TimeSlotSelectorDialog(
            slots: slots,
            boatSize: boatSize,
            useIsAvailableOnly: useIsAvailableOnly,
            onSubmit: (slot) => Navigator.of(ctx).pop(slot),
            onCancel: () => Navigator.of(ctx).pop(null),
          ),
    );
  }

  List<ProductTimeSlot> _availableTimeSlots(Product product) {
    final list = product.timeSlots
        .where((e) => e.startTime != null)
        .toList(growable: false);
    list.sort((a, b) => a.startTime!.compareTo(b.startTime!));
    return list;
  }

  ProductPricingOption? _transportOptionForType(ProductPricing pricing) {
    if (pricing.options.isEmpty) return null;
    final isNextDay = _transportType == 'Next Day';
    final desired = isNextDay ? 'NEXT_DAY' : 'SAME_DAY';
    return pricing.options.firstWhere(
      (o) => (o.id ?? '').toUpperCase() == desired,
      orElse: () => pricing.options.first,
    );
  }

  int _transportTotal(Product product) {
    final pricing = _selectedPricing;
    if (pricing == null) return product.minPrice ?? 0;
    final opt = _transportOptionForType(pricing);
    return opt?.totalPrice ?? pricing.price;
  }

  void _syncTransportationPricing(Product product) {
    final desiredLocation = _selectedRoute.trim();
    final match = product.pricing
        .where((p) => p.id.isNotEmpty)
        .where(
          (p) =>
              desiredLocation.isEmpty
                  ? true
                  : (p.location ?? '').trim().toLowerCase() ==
                      desiredLocation.toLowerCase(),
        )
        .where((p) => (p.seatCapacity ?? 0) == _people || _people <= 0)
        .toList(growable: false);
    if (match.isEmpty) return;

    final next = match.first;
    if (_selectedPricing?.id == next.id) return;
    _selectedPricing = next;
  }

  List<int> _transportBoatSizesForSelection({
    required Product product,
    required List<ProductTimeSlot> availableSlots,
  }) {
    final set = <int>{};
    final selectedDate = _selectedDate;

    if (_transportToSlot != null &&
        _transportToSlot!.availableBoatSizes.isNotEmpty) {
      set.addAll(_transportToSlot!.availableBoatSizes);
    } else if (selectedDate != null) {
      for (final s in availableSlots) {
        final st = s.startTime;
        if (st == null) continue;
        if (st.year == selectedDate.year &&
            st.month == selectedDate.month &&
            st.day == selectedDate.day) {
          set.addAll(s.availableBoatSizes);
        }
      }
    }

    if (set.isEmpty) {
      for (final p in product.pricing) {
        final cap = p.seatCapacity ?? 0;
        if (cap > 0) set.add(cap);
      }
    }

    final list = set.toList(growable: false)..sort();
    return list;
  }

  Future<DateTime?> _pickTransportDateFromSlots(
    List<ProductTimeSlot> availableSlots,
  ) async {
    final dates = <DateTime>[];
    for (final s in availableSlots) {
      final dt = s.startTime;
      if (dt == null) continue;
      final d = DateTime(dt.year, dt.month, dt.day);
      if (!dates.any(
        (e) => e.year == d.year && e.month == d.month && e.day == d.day,
      )) {
        dates.add(d);
      }
    }
    dates.sort();
    if (dates.isEmpty) return null;

    if (!mounted) return null;
    return showAppDropdownSheet<DateTime>(
      context: context,
      title: 'Select Date',
      items: dates,
      selected:
          _selectedDate == null
              ? null
              : DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
              ),
      labelBuilder: (d) => '${d.day} / ${d.month} / ${d.year}',
    );
  }

  Future<void> _showNoTimeSlotsModal() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('No time slots'),
            content: const Text(
              'No time slots are available for this product.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _durationLabel(int minutes) {
    if (minutes >= 60 && minutes % 60 == 0) {
      final h = minutes ~/ 60;
      return '${h}hr${h == 1 ? '' : 's'}';
    }
    return '${minutes}mins';
  }

  int _total(Product product) {
    final upper = (product.category ?? '').toUpperCase();
    if (upper == 'TRANSPORTATION' || upper == 'TRANSPORT') {
      return _transportTotal(product);
    }
    if (upper == 'BOAT_CRUISE' || upper == 'BOATCRUISE') {
      final p = _selectedPricing;
      if (p != null && p.options.isNotEmpty) {
        return _selectedPricingOption?.totalPrice ?? p.options.first.totalPrice;
      }
    }
    return _selectedPricing?.price ?? product.minPrice ?? 0;
  }

  DateTime? _combine(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String? _startTimeIsoForCategory(String category) {
    final now = DateTime.now();
    final upper = category.toUpperCase();

    if (upper == 'TRANSPORTATION' || upper == 'TRANSPORT') {
      final dt =
          _transportToSlot?.startTime ??
          _combine(_selectedDate ?? now, _toTime ?? _selectedTime);
      return dt?.toUtc().toIso8601String();
    }

    if (_selectedDate != null && _selectedTime != null) {
      return _combine(
        _selectedDate!,
        _selectedTime!,
      )?.toUtc().toIso8601String();
    }

    if (upper == 'JET_SKI' ||
        upper == 'JETSKI' ||
        upper == 'JET SKI' ||
        upper == 'JET-SKI') {
      final slot = _selectedTimeSlot;
      if (slot?.startTime != null) {
        return slot!.startTime!.toUtc().toIso8601String();
      }

      if (_selectedTime != null) {
        return _combine(
          _selectedDate ?? now,
          _selectedTime!,
        )?.toUtc().toIso8601String();
      }
    }

    return null;
  }

  Future<Booking?> _createBooking({required Product product}) async {
    final authUser = ref.read(authControllerProvider).value?.user;
    if (authUser == null || authUser.id.isEmpty) {
      ToastHelper.showWarning('Please login to continue');
      return null;
    }

    final pricing = _selectedPricing;
    if (pricing == null || pricing.id.isEmpty) {
      ToastHelper.showWarning('Please select a duration');
      return null;
    }

    final startTime = _startTimeIsoForCategory(product.category ?? '');
    if (startTime == null || startTime.isEmpty) {
      ToastHelper.showWarning('Please select a time');
      return null;
    }

    final category = (product.category ?? '').toUpperCase();
    Map<String, dynamic> meta = <String, dynamic>{};

    if (category == 'JET_SKI' ||
        category == 'JETSKI' ||
        category == 'JET SKI' ||
        category == 'JET-SKI') {
      meta = <String, dynamic>{'type': _jetSkiType.toLowerCase()};
    } else if (category == 'TRANSPORTATION' || category == 'TRANSPORT') {
      final tripType = _transportType == 'Next Day' ? 'NEXT_DAY' : 'SAME_DAY';

      final routes = product.meta?.routes ?? const <String, int>{};
      final routeMinutes = routes[_selectedRoute.trim()];

      final toDt =
          _transportToSlot?.startTime ??
          _combine(
            _transportType == 'Next Day' ? _toDate : _selectedDate,
            _toTime,
          );

      final fromDt =
          _transportFroSlot?.startTime ??
          _combine(
            _transportType == 'Next Day' ? _fromDate : _selectedDate,
            _fromTime,
          );

      if (_selectedRoute.trim().isEmpty) {
        ToastHelper.showWarning('Please select a route');
        return null;
      }
      if (toDt == null || fromDt == null) {
        ToastHelper.showWarning('Please select To and Fro times');
        return null;
      }

      meta = <String, dynamic>{
        'routes': _selectedRoute.trim(),
        'tripType': tripType,
        'to': toDt.toUtc().toIso8601String(),
        'fro': fromDt.toUtc().toIso8601String(),
      };

      final durationToSend = routeMinutes ?? pricing.duration;
      final transportOption = _transportOptionForType(pricing);
      final totalPriceToSend = transportOption?.totalPrice ?? pricing.price;
      return ref
          .read(bookingsControllerProvider.notifier)
          .book(
            userId: authUser.id,
            startTime: startTime,
            pricingId: pricing.id,
            totalPrice: totalPriceToSend,
            duration: durationToSend,
            meta: meta,
          );
    } else {
      final upper = category;
      if (upper == 'BOAT_CRUISE' || upper == 'BOATCRUISE') {
        if (pricing.options.isNotEmpty && _selectedPricingOption == null) {
          ToastHelper.showWarning('Please select a duration');
          return null;
        }

        final cap = _selectedPricing?.seatCapacity;
        meta = <String, dynamic>{'people': (cap ?? _people)};
      } else {
        meta =
            _hasSeatCapacity(product)
                ? <String, dynamic>{'people': _people}
                : <String, dynamic>{};
      }
    }

    final totalPriceToSend =
        (category == 'BOAT_CRUISE' || category == 'BOATCRUISE') &&
                pricing.options.isNotEmpty
            ? (_selectedPricingOption?.totalPrice ??
                pricing.options.first.totalPrice)
            : pricing.price;

    final durationToSend =
        (category == 'BOAT_CRUISE' || category == 'BOATCRUISE') &&
                pricing.options.isNotEmpty
            ? ((_selectedPricingOption?.duration ??
                    pricing.options.first.duration) *
                60)
            : pricing.duration;

    return ref
        .read(bookingsControllerProvider.notifier)
        .book(
          userId: authUser.id,
          startTime: startTime,
          pricingId: pricing.id,
          totalPrice: totalPriceToSend,
          duration: durationToSend,
          meta: meta,
        );
  }

  Future<void> _addToCart({required Product product}) async {
    final authUser = ref.read(authControllerProvider).value?.user;
    if (authUser == null || authUser.id.isEmpty) {
      ToastHelper.showWarning('Please login to continue');
      return;
    }

    final pricing = _selectedPricing;
    if (pricing == null || pricing.id.isEmpty) {
      ToastHelper.showWarning('Please select a duration');
      return;
    }

    final startTime = _startTimeIsoForCategory(product.category ?? '');
    if (startTime == null || startTime.isEmpty) {
      ToastHelper.showWarning('Please select a time');
      return;
    }

    final category = (product.category ?? '').toUpperCase();
    Map<String, dynamic> meta = <String, dynamic>{};

    if (category == 'JET_SKI' ||
        category == 'JETSKI' ||
        category == 'JET SKI' ||
        category == 'JET-SKI') {
      meta = <String, dynamic>{'type': _jetSkiType.toLowerCase()};
    } else if (category == 'TRANSPORTATION' || category == 'TRANSPORT') {
      final tripType = _transportType == 'Next Day' ? 'NEXT_DAY' : 'SAME_DAY';

      final routes = product.meta?.routes ?? const <String, int>{};
      final routeMinutes = routes[_selectedRoute.trim()];

      final toDt =
          _transportToSlot?.startTime ??
          _combine(
            _transportType == 'Next Day' ? _toDate : _selectedDate,
            _toTime,
          );

      final fromDt =
          _transportFroSlot?.startTime ??
          _combine(
            _transportType == 'Next Day' ? _fromDate : _selectedDate,
            _fromTime,
          );

      if (_selectedRoute.trim().isEmpty) {
        ToastHelper.showWarning('Please select a route');
        return;
      }
      if (toDt == null || fromDt == null) {
        ToastHelper.showWarning('Please select To and Fro times');
        return;
      }

      meta = <String, dynamic>{
        'routes': _selectedRoute.trim(),
        'tripType': tripType,
        'to': toDt.toUtc().toIso8601String(),
        'fro': fromDt.toUtc().toIso8601String(),
      };

      final durationToSend = routeMinutes ?? pricing.duration;
      await ref
          .read(cartControllerProvider.notifier)
          .addToCart(
            pricingId: pricing.id,
            startTime: startTime,
            duration: durationToSend.toInt(),
            meta: meta,
          );
      return;
    } else {
      final upper = category;
      if (upper == 'BOAT_CRUISE' || upper == 'BOATCRUISE') {
        if (pricing.options.isNotEmpty && _selectedPricingOption == null) {
          ToastHelper.showWarning('Please select a duration');
          return;
        }

        final cap = _selectedPricing?.seatCapacity;
        meta = <String, dynamic>{'people': (cap ?? _people)};
      } else {
        meta =
            _hasSeatCapacity(product)
                ? <String, dynamic>{'people': _people}
                : <String, dynamic>{};
      }
    }

    final durationToSend =
        (category == 'BOAT_CRUISE' || category == 'BOATCRUISE') &&
                pricing.options.isNotEmpty
            ? ((_selectedPricingOption?.duration ??
                    pricing.options.first.duration) *
                60)
            : pricing.duration;

    await ref
        .read(cartControllerProvider.notifier)
        .addToCart(
          pricingId: pricing.id,
          startTime: startTime,
          duration: durationToSend.toInt(),
          meta: meta,
        );
  }

  Widget _headerImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.fill,

      height: 340.h,
      width: double.infinity,
      placeholder: (context, url) => Container(color: AppColors.subcolor),
      errorWidget:
          (context, url, error) => Container(color: AppColors.subcolor),
    );
  }

  Widget _pillToggle({
    required String left,
    required String right,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.subcolor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: RoundedSelector(
              label: left,
              selected: value == left,
              backgroundColor: AppColors.backgroundColor,
              onTap: () => onChanged(left),
            ),
          ),
          SizedBox(width: 10),

          Container(color: AppColors.whiteColor, width: 3, height: 3),
          SizedBox(width: 2),
          Container(color: AppColors.whiteColor, width: 3, height: 3),
          SizedBox(width: 2),

          Container(color: AppColors.whiteColor, width: 3, height: 3),
          SizedBox(width: 2),

          Container(color: AppColors.whiteColor, width: 3, height: 3),
          SizedBox(width: 2),

          Container(color: AppColors.whiteColor, width: 3, height: 3),
          SizedBox(width: 10),

          Expanded(
            child: RoundedSelector(
              label: right,
              selected: value == right,
              backgroundColor: AppColors.backgroundColor,

              onTap: () => onChanged(right),
            ),
          ),
        ],
      ),
    );
  }

  Widget _durationSection(Product product) {
    final pricing = _sortedPricing(product);
    if (_selectedPricing == null && pricing.isNotEmpty) {
      _selectedPricing = pricing.first;
    }

    if (pricing.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duration?',
            style: CustomTextStyle.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'No pricing options available yet.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      );
    }

    final durations = pricing.map((p) => p.duration).toList(growable: false);
    final selectedDuration =
        _selectedPricing?.duration ??
        (durations.isNotEmpty ? durations.first : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration?',
          style: CustomTextStyle.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        height12,
        if (durations.length <= 5)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  pricing.map((p) {
                    final label = _durationLabel(p.duration);
                    final isSelected = p.duration == selectedDuration;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: RoundedSelector(
                        label: label,
                        selected: isSelected,
                        backgroundColor: AppColors.subcolor,
                        onTap: () {
                          setState(() {
                            _selectedPricing = p;
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
          )
        else
          RoundedInputField(
            hint:
                _selectedPricing == null
                    ? 'Select Duration'
                    : _durationLabel(_selectedPricing!.duration),
            suffix: IconButton(
              onPressed: () async {
                final selected = await showAppDropdownSheet<int>(
                  context: context,
                  title: 'Select Duration',
                  items: durations,
                  selected: selectedDuration,
                  labelBuilder: (m) => _durationLabel(m),
                );
                if (selected == null) return;
                final match = pricing.firstWhere(
                  (p) => p.duration == selected,
                  orElse: () => pricing.first,
                );
                setState(() {
                  _selectedPricing = match;
                  final cap = match.seatCapacity;
                  if (cap != null && cap > 0) {
                    _people = cap;
                  }
                  _selectedPricingOption =
                      match.options.isNotEmpty ? match.options.first : null;
                });
              },
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
            ),
            onTap: () async {
              final selected = await showAppDropdownSheet<int>(
                context: context,
                title: 'Select Duration',
                items: durations,
                selected: selectedDuration,
                labelBuilder: (m) => _durationLabel(m),
              );
              if (selected == null) return;
              final match = pricing.firstWhere(
                (p) => p.duration == selected,
                orElse: () => pricing.first,
              );
              setState(() {
                _selectedPricing = match;
                final cap = match.seatCapacity;
                if (cap != null && cap > 0) {
                  _people = cap;
                }
                _selectedPricingOption =
                    match.options.isNotEmpty ? match.options.first : null;
              });
            },
          ),
      ],
    );
  }

  Widget _boatCruiseCapacitySection(Product product) {
    final pricing = product.pricing.toList(growable: false);
    pricing.sort(
      (a, b) => (a.seatCapacity ?? 0).compareTo((b.seatCapacity ?? 0)),
    );

    if (_selectedPricing == null && pricing.isNotEmpty) {
      _selectedPricing = pricing.first;
      _people = _selectedPricing?.seatCapacity ?? _people;
      if (_selectedPricing?.options.isNotEmpty == true) {
        _selectedPricingOption = _selectedPricing!.options.first;
      }
    }

    if (pricing.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Seat Capacity?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 12),
          Text(
            'No pricing options available yet.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      );
    }

    final seaters = pricing
      .map((p) => p.seatCapacity ?? 0)
      .where((v) => v > 0)
      .toSet()
      .toList(growable: false)..sort();

    final selectedSeater =
        _selectedPricing?.seatCapacity ??
        (seaters.isNotEmpty ? seaters.first : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seat Capacity?',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (seaters.isNotEmpty && seaters.length <= 5)
          SegmentedProgressIndicator(
            currentValue: selectedSeater,
            values: seaters,
            activeColor: AppColors.bottomNavBarHighlightColor,
            inactiveColor: AppColors.backgroundColor,
            backgroundColor: AppColors.subcolor,
            onSegmentTap: (v) {
              final match = pricing.firstWhere(
                (p) => (p.seatCapacity ?? 0) == v,
                orElse: () => pricing.first,
              );
              setState(() {
                _selectedPricing = match;
                _people = v;
                _selectedPricingOption =
                    match.options.isNotEmpty ? match.options.first : null;
              });
            },
          )
        else
          RoundedInputField(
            hint:
                seaters.isEmpty
                    ? 'Select Seat Capacity'
                    : (selectedSeater <= 0
                        ? 'Select Seat Capacity'
                        : '$selectedSeater Seater'),
            suffix: IconButton(
              onPressed:
                  seaters.isEmpty
                      ? null
                      : () async {
                        final selected = await showAppDropdownSheet<int>(
                          context: context,
                          title: 'Select Seat Capacity',
                          items: seaters,
                          selected: selectedSeater <= 0 ? null : selectedSeater,
                          labelBuilder: (c) => '$c Seater',
                        );
                        if (selected == null) return;
                        final match = pricing.firstWhere(
                          (p) => (p.seatCapacity ?? 0) == selected,
                          orElse: () => pricing.first,
                        );
                        setState(() {
                          _selectedPricing = match;
                          _people = selected;
                          _selectedPricingOption =
                              match.options.isNotEmpty
                                  ? match.options.first
                                  : null;
                        });
                      },
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
            ),
            onTap:
                seaters.isEmpty
                    ? null
                    : () async {
                      final selected = await showAppDropdownSheet<int>(
                        context: context,
                        title: 'Select Seat Capacity',
                        items: seaters,
                        selected: selectedSeater <= 0 ? null : selectedSeater,
                        labelBuilder: (c) => '$c Seater',
                      );
                      if (selected == null) return;
                      final match = pricing.firstWhere(
                        (p) => (p.seatCapacity ?? 0) == selected,
                        orElse: () => pricing.first,
                      );
                      setState(() {
                        _selectedPricing = match;
                        _people = selected;
                        _selectedPricingOption =
                            match.options.isNotEmpty
                                ? match.options.first
                                : null;
                      });
                    },
          ),
      ],
    );
  }

  Widget _boatCruiseDurationOptionsSection(Product product) {
    final p = _selectedPricing;
    final options = p?.options ?? const <ProductPricingOption>[];
    if (p == null || options.isEmpty) {
      return _durationSection(product);
    }

    _selectedPricingOption ??= options.first;
    final selected = _selectedPricingOption;

    final durations = options.map((o) => o.duration).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration?',
          style: CustomTextStyle.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        height12,
        if (durations.length <= 5)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  options.map((o) {
                    final isSelected =
                        selected?.duration == o.duration &&
                        selected?.totalPrice == o.totalPrice;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: RoundedSelector(
                        label: _optionLabel(o),
                        selected: isSelected,
                        backgroundColor: AppColors.subcolor,
                        onTap: () {
                          setState(() {
                            _selectedPricingOption = o;
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
          )
        else
          RoundedInputField(
            hint: selected == null ? 'Select Duration' : _optionLabel(selected),
            suffix: IconButton(
              onPressed: () async {
                final selectedDuration = await showAppDropdownSheet<int>(
                  context: context,
                  title: 'Select Duration',
                  items: durations,
                  selected: selected?.duration,
                  labelBuilder: (d) {
                    final match = options.firstWhere(
                      (o) => o.duration == d,
                      orElse: () => options.first,
                    );
                    return _optionLabel(match);
                  },
                );
                if (selectedDuration == null) return;
                final match = options.firstWhere(
                  (o) => o.duration == selectedDuration,
                  orElse: () => options.first,
                );
                setState(() {
                  _selectedPricingOption = match;
                });
              },
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
            ),
            onTap: () async {
              final selectedDuration = await showAppDropdownSheet<int>(
                context: context,
                title: 'Select Duration',
                items: durations,
                selected: selected?.duration,
                labelBuilder: (d) {
                  final match = options.firstWhere(
                    (o) => o.duration == d,
                    orElse: () => options.first,
                  );
                  return _optionLabel(match);
                },
              );
              if (selectedDuration == null) return;
              final match = options.firstWhere(
                (o) => o.duration == selectedDuration,
                orElse: () => options.first,
              );
              setState(() {
                _selectedPricingOption = match;
              });
            },
          ),
      ],
    );
  }

  String _optionLabel(ProductPricingOption o) {
    final lbl = (o.displayLabel ?? '').trim();
    if (lbl.isNotEmpty) return lbl;
    final h = o.duration;
    return '${h}hr${h == 1 ? '' : 's'}';
  }

  Widget _jetSkiForm(Product product) {
    final availableSlots = _availableTimeSlots(product);

    final selectedSlot = _selectedTimeSlot;
    final selectedTimeLabel =
        selectedSlot?.startTime == null
            ? null
            : TimeOfDay.fromDateTime(
              selectedSlot!.startTime!.toLocal(),
            ).format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type?',
          style: CustomTextStyle.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        height10,
        _pillToggle(
          left: 'Instructor',
          right: 'Solo',
          value: _jetSkiType,
          onChanged: (v) {
            setState(() {
              _jetSkiType = v;
            });
          },
        ),
        height20,
        _durationSection(product),
        const SizedBox(height: 26),
        const Text('Time', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 10),
        RoundedInputField(
          hint:
              selectedTimeLabel ??
              (_selectedTime == null
                  ? 'Enter time'
                  : _selectedTime!.format(context)),
          suffix: const Icon(Icons.access_time, color: Colors.white70),
          onTap: () async {
            if (availableSlots.isEmpty) {
              await _showNoTimeSlotsModal();
              return;
            }

            final slot = await _pickStartTimeFromDialog(
              slots: availableSlots,
              useIsAvailableOnly: true,
            );
            if (slot == null) return;
            setState(() {
              _selectedTimeSlot = slot;
              if (slot.startTime != null) {
                final st = slot.startTime!.toLocal();
                _selectedDate = DateTime(st.year, st.month, st.day);
                _selectedTime = TimeOfDay.fromDateTime(st);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _transportationForm(Product product) {
    final isNextDay = _transportType == 'Next Day';
    final locationNames = product.pricing
      .map((p) => (p.location ?? '').trim())
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList(growable: false)..sort();
    if (_selectedRoute.isEmpty && locationNames.isNotEmpty) {
      _selectedRoute = locationNames.first;
    }

    if (_selectedPricing == null && product.pricing.isNotEmpty) {
      _selectedPricing = product.pricing.first;
    }

    final availableSlots = _availableTimeSlots(product);

    final availableBoatSizes = _transportBoatSizesForSelection(
      product: product,
      availableSlots: availableSlots,
    );

    if (_people <= 0 && availableBoatSizes.isNotEmpty) {
      _people = availableBoatSizes.first;
    }

    _syncTransportationPricing(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type?',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 10),
        _pillToggle(
          left: 'Same Day',
          right: 'Next Day',
          value: _transportType,
          onChanged: (v) {
            setState(() {
              _transportType = v;
            });
          },
        ),
        const SizedBox(height: 26),
        const Text(
          'Select location',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 12),
        RoundedInputField(
          hint:
              locationNames.isEmpty
                  ? 'Select Location'
                  : (_selectedRoute.isEmpty
                      ? 'Select Location'
                      : _selectedRoute),
          suffix: IconButton(
            onPressed:
                locationNames.isEmpty
                    ? null
                    : () async {
                      final selected = await showAppDropdownSheet<String>(
                        context: context,
                        title: 'Select Location',
                        items: locationNames,
                        selected:
                            _selectedRoute.isEmpty ? null : _selectedRoute,
                        labelBuilder: (name) => name,
                      );
                      if (selected == null) return;
                      setState(() {
                        _selectedRoute = selected;
                        _syncTransportationPricing(product);
                      });
                    },
            icon: const Icon(Icons.location_on_outlined, color: Colors.white70),
          ),
          onTap:
              locationNames.isEmpty
                  ? null
                  : () async {
                    final selected = await showAppDropdownSheet<String>(
                      context: context,
                      title: 'Select Location',
                      items: locationNames,
                      selected: _selectedRoute.isEmpty ? null : _selectedRoute,
                      labelBuilder: (name) => name,
                    );
                    if (selected == null) return;
                    setState(() {
                      _selectedRoute = selected;
                      _syncTransportationPricing(product);
                    });
                  },
        ),
        const SizedBox(height: 26),
        const Text(
          'Boat Size?',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (availableBoatSizes.isNotEmpty && availableBoatSizes.length <= 5)
          SegmentedProgressIndicator(
            currentValue: _people,
            values: availableBoatSizes,
            activeColor: AppColors.bottomNavBarHighlightColor,
            inactiveColor: Colors.white24,
            backgroundColor: AppColors.subcolor,
            onSegmentTap: (v) {
              setState(() {
                _people = v;
                _syncTransportationPricing(product);
              });
            },
          )
        else
          RoundedInputField(
            hint:
                availableBoatSizes.isEmpty
                    ? 'Select Boat Size'
                    : (_people <= 0 ? 'Select Boat Size' : '$_people Seater'),
            suffix: IconButton(
              onPressed:
                  availableBoatSizes.isEmpty
                      ? null
                      : () async {
                        final selected = await showAppDropdownSheet<int>(
                          context: context,
                          title: 'Select Boat Size',
                          items: availableBoatSizes,
                          selected: _people <= 0 ? null : _people,
                          labelBuilder: (c) => '$c Seater',
                        );
                        if (selected == null) return;
                        setState(() {
                          _people = selected;
                          _syncTransportationPricing(product);
                        });
                      },
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
            ),
            onTap:
                availableBoatSizes.isEmpty
                    ? null
                    : () async {
                      final selected = await showAppDropdownSheet<int>(
                        context: context,
                        title: 'Select Boat Size',
                        items: availableBoatSizes,
                        selected: _people <= 0 ? null : _people,
                        labelBuilder: (c) => '$c Seater',
                      );
                      if (selected == null) return;
                      setState(() {
                        _people = selected;
                        _syncTransportationPricing(product);
                      });
                    },
          ),
        const SizedBox(height: 26),
        if (!isNextDay) ...[
          const Text(
            'Start Date',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          RoundedInputField(
            hint:
                _selectedDate == null
                    ? 'Select start date'
                    : '${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}',
            suffix: const Icon(Icons.calendar_today, color: Colors.white70),
            onTap: () async {
              if (availableSlots.isEmpty) {
                await _showNoTimeSlotsModal();
                return;
              }
              final picked = await _pickTransportDateFromSlots(availableSlots);
              if (picked == null) return;
              setState(() {
                _selectedDate = picked;
                _transportToSlot = null;
                _transportFroSlot = null;
              });
            },
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    RoundedInputField(
                      hint:
                          _toTime == null
                              ? 'Enter time'
                              : _toTime!.format(context),

                      suffix: const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                      ),
                      onTap: () async {
                        if (_selectedDate == null) {
                          ToastHelper.showWarning('Please select start date');
                          return;
                        }
                        if (availableSlots.isEmpty) {
                          await _showNoTimeSlotsModal();
                          return;
                        }
                        final slot = await _pickStartTimeFromDialog(
                          slots: availableSlots,
                          boatSize: _people,
                        );
                        if (slot == null) return;
                        setState(() {
                          _transportToSlot = slot;
                        });
                        if (slot.startTime != null) {
                          _toTime = TimeOfDay.fromDateTime(
                            slot.startTime!.toLocal(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fro',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    RoundedInputField(
                      hint:
                          _fromTime == null
                              ? 'Enter time'
                              : _fromTime!.format(context),

                      suffix: const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                      ),
                      onTap: () async {
                        if (_selectedDate == null) {
                          ToastHelper.showWarning('Please select start date');
                          return;
                        }
                        if (availableSlots.isEmpty) {
                          await _showNoTimeSlotsModal();
                          return;
                        }
                        final slot = await _pickStartTimeFromDialog(
                          slots: availableSlots,
                          boatSize: _people,
                        );
                        if (slot == null) return;
                        setState(() {
                          _transportFroSlot = slot;
                        });
                        if (slot.startTime != null) {
                          _fromTime = TimeOfDay.fromDateTime(
                            slot.startTime!.toLocal(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Next Day: select To start time, then choose custom future date+time for Fro
          const Text('To', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          RoundedInputField(
            hint:
                _toDate == null || _toTime == null
                    ? '12:00 PM  |  28 / October'
                    : '${_toTime!.format(context)}  |  ${_toDate!.day} / ${_toDate!.month}',
            suffix: const Icon(Icons.access_time, color: Colors.white70),
            onTap: () async {
              if (availableSlots.isEmpty) {
                await _showNoTimeSlotsModal();
                return;
              }

              final slot = await _pickStartTimeFromDialog(
                slots: availableSlots,
                boatSize: _people,
              );

              if (slot == null || slot.startTime == null) return;
              final selected = slot.startTime!;

              setState(() {
                _transportToSlot = slot;
                _toDate = DateTime(selected.year, selected.month, selected.day);
                _toTime = TimeOfDay.fromDateTime(selected.toLocal());
                _selectedDate = _toDate;
              });
            },
          ),
          const SizedBox(height: 26),
          const Text(
            'Fro',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          RoundedInputField(
            hint:
                _fromDate == null || _fromTime == null
                    ? '12:00 PM  |  28 / October'
                    : '${_fromTime!.format(context)}  |  ${_fromDate!.day} / ${_fromDate!.month}',
            suffix: const Icon(Icons.access_time, color: Colors.white70),
            onTap: () async {
              final base = _toDate ?? DateTime.now();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _fromDate ?? base.add(const Duration(days: 1)),
                firstDate: base.add(const Duration(days: 1)),
                lastDate: DateTime(base.year + 2),
              );
              if (pickedDate == null) return;
              TimeOfDay? pickedTime;
              if (!mounted) return;
              pickedTime = await showTimePicker(
                context: context,
                initialTime: _fromTime ?? TimeOfDay.now(),
              );
              if (pickedTime == null) return;
              setState(() {
                _transportFroSlot = null;
                _fromDate = pickedDate;
                _fromTime = pickedTime;
              });
            },
          ),
        ],
      ],
    );
  }

  bool _hasSeatCapacity(Product product) {
    return product.pricing.any((p) => (p.seatCapacity ?? 0) > 0);
  }

  Widget _categoryForm(Product product) {
    final category = (product.category ?? '').toUpperCase();
    if (category == 'JET_SKI' ||
        category == 'JETSKI' ||
        category == 'JET SKI' ||
        category == 'JET-SKI') {
      return _jetSkiForm(product);
    }
    if (category == 'TRANSPORTATION' || category == 'TRANSPORT') {
      return _transportationForm(product);
    }

    if (category == 'BOAT_CRUISE' || category == 'BOATCRUISE') {
      return _boatCruiseForm(product);
    }

    return _genericProductForm(product);
  }

  Widget _genericProductForm(Product product) {
    final pricing = _sortedPricing(product);
    final selectedPricing = _selectedPricing;
    final hasPricingOptions =
        selectedPricing != null && selectedPricing.options.isNotEmpty;
    final availableSlots = _availableTimeSlots(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasSeatCapacity(product)) _boatCruiseCapacitySection(product),
        if (_hasSeatCapacity(product)) const SizedBox(height: 26),
        if (pricing.isNotEmpty) _durationSection(product),
        if (pricing.isNotEmpty) const SizedBox(height: 26),
        if (hasPricingOptions) _boatCruiseDurationOptionsSection(product),
        if (hasPricingOptions) const SizedBox(height: 26),
        const Text('Time', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        RoundedInputField(
          hint:
              _selectedDate == null || _selectedTime == null
                  ? '12:00 PM  |  28 / October'
                  : '${_selectedTime!.format(context)}  |  ${_selectedDate!.day} / ${_selectedDate!.month}',
          suffix: const Icon(Icons.access_time, color: Colors.white70),
          onTap: () async {
            if (availableSlots.isEmpty) {
              await _showNoTimeSlotsModal();
              return;
            }

            final slot = await _pickStartTimeFromDialog(
              slots: availableSlots,
              boatSize: _hasSeatCapacity(product) ? _people : null,
            );
            if (slot == null || slot.startTime == null) return;
            final selected = slot.startTime!.toLocal();
            setState(() {
              _selectedDate = DateTime(
                selected.year,
                selected.month,
                selected.day,
              );
              _selectedTime = TimeOfDay.fromDateTime(selected);
            });
          },
        ),
      ],
    );
  }

  Widget _boatCruiseForm(Product product) {
    final availableSlots = _availableTimeSlots(product);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _boatCruiseCapacitySection(product),
        const SizedBox(height: 26),
        _boatCruiseDurationOptionsSection(product),
        const SizedBox(height: 26),
        const Text('Time', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        RoundedInputField(
          hint:
              _selectedDate == null || _selectedTime == null
                  ? '12:00 PM  |  28 / October'
                  : '${_selectedTime!.format(context)}  |  ${_selectedDate!.day} / ${_selectedDate!.month}',
          suffix: const Icon(Icons.access_time, color: Colors.white70),
          onTap: () async {
            if (availableSlots.isEmpty) {
              await _showNoTimeSlotsModal();
              return;
            }

            final slot = await _pickStartTimeFromDialog(
              slots: availableSlots,
              boatSize: _people,
            );
            if (slot == null) return;
            final start = slot.startTime;
            if (start == null) return;
            final local = start.toLocal();

            setState(() {
              _selectedDate = DateTime(local.year, local.month, local.day);
              _selectedTime = TimeOfDay.fromDateTime(local);
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));

    return productAsync.when(
      loading:
          () => Scaffold(
            backgroundColor: const Color(0xFF053C5E),
            body: Center(
              child: SpinKitFadingCircle(size: 30, color: AppColors.whiteColor),
            ),
          ),
      error:
          (err, _) => Scaffold(
            backgroundColor: const Color(0xFF053C5E),
            body: Center(
              child: TextButton(
                onPressed: () {
                  ref.invalidate(productDetailsProvider(widget.productId));
                },
                child: const Text('Retry'),
              ),
            ),
          ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF053C5E),
            body: Center(
              child: TextButton(
                onPressed: () {
                  ref.invalidate(productDetailsProvider(widget.productId));
                },
                child: const Text('Retry'),
              ),
            ),
          );
        }

        _initEditingState(product);

        final title = product.name;
        final image = product.primaryImageUrl;
        final description =
            product.description ??
            product.meta?.description ??
            'Enjoy an amazing experience at Lagos Water Craft.';

        final total = _total(product);
        final durationLabel =
            _selectedPricing == null
                ? ''
                : _durationLabel(_selectedPricing!.duration);

        final category = (product.category ?? '').toUpperCase();
        final summaryDuration =
            category == 'TRANSPORTATION' || category == 'TRANSPORT'
                ? (_selectedRoute.isEmpty ? '—' : 'Route: $_selectedRoute')
                : (category == 'BOAT_CRUISE' || category == 'BOATCRUISE')
                ? (() {
                  final cap = _selectedPricing?.seatCapacity;
                  final p = _selectedPricing;
                  if (p != null && p.options.isNotEmpty) {
                    final opt = _selectedPricingOption ?? p.options.first;
                    final optLabel = _optionLabel(opt);
                    return cap == null ? optLabel : 'Seats: $cap • $optLabel';
                  }
                  return cap == null
                      ? (durationLabel.isEmpty ? '—' : durationLabel)
                      : 'Seats: $cap • ${durationLabel.isEmpty ? _durationLabel(_selectedPricing!.duration) : durationLabel}';
                })()
                : (durationLabel.isEmpty ? '—' : durationLabel);

        return Scaffold(
          backgroundColor: const Color(0xFF053C5E),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: AppColors.backgroundColor,
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BottomBookingSummary(duration: summaryDuration, total: total),
                  SizedBox(height: 12.h),
                  if (widget.isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: 'Update',
                        isLoading: _isBooking,
                        onPressed: () async {
                          if (_isBooking || _isPaying) return;
                          setState(() {
                            _isBooking = true;
                          });
                          try {
                            await _updateCartItem(product: product);
                            ref.invalidate(cartItemsProvider);
                            ToastHelper.showSuccess('Cart item updated');
                            if (mounted) Navigator.of(context).pop();
                          } catch (e) {
                            final msg =
                                e is ApiException ? e.message : e.toString();
                            ToastHelper.showError(msg);
                          } finally {
                            if (!mounted) return;
                            setState(() {
                              _isBooking = false;
                            });
                          }
                        },
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: 'Add to Bag',
                            icon: Icons.shopping_bag,
                            showSuccess: _addedToBag,
                            onPressed: () async {
                              if (_isBooking || _isPaying) return;
                              setState(() {
                                _isBooking = true;
                              });
                              try {
                                ref.invalidate(
                                  productDetailsProvider(widget.productId),
                                );
                                await _addToCart(product: product);
                                ref.invalidate(cartItemsProvider);
                                ref.read(cartCountProvider.notifier).state++;
                                if (mounted) {
                                  setState(() {
                                    _addedToBag = true;
                                  });
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (mounted) {
                                        setState(() {
                                          _addedToBag = false;
                                        });
                                      }
                                    },
                                  );
                                }
                                ToastHelper.showSuccess('Added to bag');
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
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Book Now',
                            isLoading: _isPaying,
                            onPressed: () async {
                              if (_isBooking || _isPaying) {
                                return;
                              }

                              setState(() {
                                _isPaying = true;
                              });

                              try {
                                final booking = await _createBooking(
                                  product: product,
                                );
                                final paymentId = booking?.paymentId ?? '';
                                if (paymentId.isEmpty) {
                                  return;
                                }

                                ref.invalidate(
                                  productDetailsProvider(widget.productId),
                                );

                                final callbackUrl = 'myapp://payment/callback';
                                final init = await ref
                                    .read(paymentsControllerProvider.notifier)
                                    .initialize(
                                      paymentId: paymentId,
                                      redirectUrl: callbackUrl,
                                      amount: _total(product),
                                      isNewPayment: true,
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
                                  ref
                                      .read(
                                        purchasesControllerProvider.notifier,
                                      )
                                      .retry();
                                  if (!mounted) return;
                                  Navigator.of(context).push(
                                    FadeScaleRoute(
                                      page: OrderScreen(paymentId: paymentId),
                                    ),
                                  );
                                  return;
                                } else {
                                  ToastHelper.showError(
                                    'Payment verification failed',
                                  );
                                  return;
                                }
                              } catch (e) {
                                final msg =
                                    e is ApiException
                                        ? e.message
                                        : e.toString();
                                ToastHelper.showError(msg);
                              } finally {
                                if (!mounted) return;
                                setState(() {
                                  _isPaying = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              await ref.refresh(
                productDetailsProvider(widget.productId).future,
              );
            },
            child: Stack(
              children: [
                _headerImage(image),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: CustomBackButton(
                      onPressed: () {
                        // Handle back navigation
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  maxChildSize: 0.7,
                  minChildSize: 0.5,
                  builder: (context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundColor,
                        // borderRadius: BorderRadius.vertical(
                        //   top: Radius.circular(28),
                        // ),
                      ),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // height10,
                          Text(
                            title,
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          height8,
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CustomTextStyle.bodySmall.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          height12,
                          _categoryForm(product),
                          // const SizedBox(height: 26),
                          // const Text(
                          //   'Description',
                          //   style: TextStyle(color: Colors.white, fontSize: 18),
                          // ),
                          // const SizedBox(height: 10),
                          // Text(
                          //   description,
                          //   style: const TextStyle(
                          //     color: Colors.white70,
                          //     fontSize: 15,
                          //   ),
                          // ),
                          const SizedBox(height: 26),
                          // SizedBox(height: 220.h),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// {"success":true,"message":"Product slot booking initiated successfully",
// "data":{"id":"cmk8alyxn0000hvodq602eh1h",
// "userId":"cmju7g33o0000htsloju9883r",
// "bookingType":"PRODUCT","status":"PENDING",
// "expiresAt":"2026-01-10T12:55:07.442Z",
// "duration":120,"totalPrice":38000,"meta":{"type":"instructor"},"pricingId":"cmk84q7ch000dbcx3d6dq1cmc","eventSlotId":null,"paymentId":"c7327bb5-7a5c-4a07-a9e7-a7173be6e8b8","createdAt":"2026-01-10T12:40:07.451Z","updatedAt":"2026-01-10T12:40:07.451Z"}
// "duration":120,"totalPrice":38000,"meta":{"type":"instructor"},"pricingId":"cmk84q7ch000dbcx3d6dq1cmc","eventSlotId":null,"paymentId":"c7327bb5-7a5c-4a07-a9e7-a7173be6e8b8","createdAt":"2026-01-10T12:40:07.451Z","updatedAt":"2026-01-10T12:40:07.451Z"}}