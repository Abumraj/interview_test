import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/features/products/domain/product.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/toast_helper.dart';

class TimeSlotSelectorDialog extends StatefulWidget {
  final List<ProductTimeSlot> slots;
  final int? boatSize;
  final bool useIsAvailableOnly;
  final ValueChanged<ProductTimeSlot> onSubmit;
  final VoidCallback onCancel;

  const TimeSlotSelectorDialog({
    super.key,
    required this.slots,
    this.boatSize,
    this.useIsAvailableOnly = false,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<TimeSlotSelectorDialog> createState() => _TimeSlotSelectorDialogState();
}

class _TimeSlotSelectorDialogState extends State<TimeSlotSelectorDialog> {
  DateTime? _selectedDate;
  ProductTimeSlot? _selectedSlot;

  List<ProductTimeSlot> get _sortedSlots {
    final list = widget.slots
        .where((s) => s.startTime != null)
        .toList(growable: false);
    list.sort((a, b) => a.startTime!.compareTo(b.startTime!));
    return list;
  }

  bool _isSlotEnabled(ProductTimeSlot slot) {
    if (slot.startTime == null) return false;
    if (widget.useIsAvailableOnly) {
      return slot.isAvailable && slot.remaining > 0;
    }

    final base = slot.isAvailable && slot.remaining > 0;
    if (!base) return false;

    final boatSize = widget.boatSize;
    if (boatSize == null || boatSize <= 0) return true;

    final units = slot.availableUnitsByBoatSize[boatSize];
    if (units != null) {
      return units >= 1;
    }
    return slot.availableBoatSizes.contains(boatSize);
  }

  List<DateTime> get _uniqueDates {
    final dates = <DateTime>[];
    for (final slot in _sortedSlots) {
      final dt = slot.startTime;
      if (dt == null) continue;
      final d = DateTime(dt.year, dt.month, dt.day);
      if (!dates.any(
        (e) => e.year == d.year && e.month == d.month && e.day == d.day,
      )) {
        dates.add(d);
      }
    }
    dates.sort();
    return dates;
  }

  List<ProductTimeSlot> _slotsForDate(DateTime date) {
    final list = _sortedSlots
        .where((s) {
          final st = s.startTime;
          if (st == null) return false;
          return st.year == date.year &&
              st.month == date.month &&
              st.day == date.day;
        })
        .toList(growable: false);

    list.sort((a, b) => a.startTime!.compareTo(b.startTime!));
    return list;
  }

  String _weekday(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    int hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }

  @override
  void initState() {
    super.initState();
    final dates = _uniqueDates;
    if (dates.isNotEmpty) {
      _selectedDate = dates.first;
      final slots = _slotsForDate(dates.first);
      final firstEnabled = slots
          .where(_isSlotEnabled)
          .cast<ProductTimeSlot?>()
          .firstWhere(
            (e) => e != null,
            orElse: () => slots.isEmpty ? null : slots.first,
          );
      _selectedSlot = firstEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _uniqueDates;
    final selectedDate = _selectedDate;
    final slots =
        selectedDate == null
            ? const <ProductTimeSlot>[]
            : _slotsForDate(selectedDate);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 384.w,
        height: 423.h,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFB3D9FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF1E9FFF),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select time',
                      style: CustomTextStyle.bodyMedium.copyWith(
                        color: AppColors.subcolor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Select the earliest available time',
                      style: CustomTextStyle.bodyMedium.copyWith(
                        color: AppColors.subcolor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            height12,
            SizedBox(
              height: 75.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected =
                      selectedDate != null &&
                      date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: DateSelector(
                      day: date.day.toString().padLeft(2, '0'),
                      weekday: _weekday(date),
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                          final slots = _slotsForDate(date);
                          final firstEnabled = slots
                              .where(_isSlotEnabled)
                              .cast<ProductTimeSlot?>()
                              .firstWhere(
                                (e) => e != null,
                                orElse:
                                    () => slots.isEmpty ? null : slots.first,
                              );
                          _selectedSlot = firstEnabled;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            height12,
            SizedBox(
              height: 66.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  final time = slot.startTime;
                  final enabled = _isSlotEnabled(slot);
                  final isSelected = _selectedSlot?.startTime == slot.startTime;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: TimeSelector(
                      time: time == null ? '—' : _formatTime(time),
                      isSelected: isSelected,
                      isEnabled: enabled,
                      onTap: () {
                        if (!enabled) {
                          ToastHelper.showWarning(
                            'Currently not available at the moment',
                          );
                          return;
                        }
                        setState(() {
                          _selectedSlot = slot;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            height24,
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: CustomButton(
                onTap:
                    _selectedSlot != null && _isSlotEnabled(_selectedSlot!)
                        ? () => widget.onSubmit(_selectedSlot!)
                        : () {},
                buttonText: 'Submit',
                height: 56.h,
                textfontSize: 24.sp,
                borderRadius: 30.r,
                buttonColor: AppColors.bottomNavBarHighlightColor,
              ),
            ),

            // SizedBox(
            //   width: double.infinity,
            //   height: 56,
            //   child: ElevatedButton(
            //     onPressed:
            //         _selectedStartTime != null
            //             ? () => widget.onSubmit(_selectedStartTime!)
            //             : null,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: const Color(0xFF1E9FFF),
            //       disabledBackgroundColor: Colors.grey[300],
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(28),
            //       ),
            //       elevation: 0,
            //     ),
            //     child: const Text(
            //       'Submit',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 18,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 13),
            TextButton(
              onPressed: widget.onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.bottomNavBarHighlightColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSelectorDialog extends StatefulWidget {
  final Function(String date, String time) onSubmit;
  final VoidCallback onCancel;

  const TimeSelectorDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<TimeSelectorDialog> createState() => _TimeSelectorDialogState();
}

class _TimeSelectorDialogState extends State<TimeSelectorDialog> {
  String? selectedDate;
  String? selectedTime;

  final List<DateOption> dates = [
    DateOption(day: '20', weekday: 'Sun'),
    DateOption(day: '21', weekday: 'Mon'),
    DateOption(day: '22', weekday: 'Tue'),
    DateOption(day: '23', weekday: 'Wed'),
    DateOption(day: '24', weekday: 'Thu'),
    DateOption(day: '25', weekday: 'Fri'),
  ];

  final List<String> times = [
    '10:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3D9FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF1E9FFF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select time',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Select the earliest available time',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Date Selection
            SizedBox(
              height: 102,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = selectedDate == date.day;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DateSelector(
                      day: date.day,
                      weekday: date.weekday,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedDate = date.day;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Time Selection
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: times.length,
                itemBuilder: (context, index) {
                  final time = times[index];
                  final isSelected = selectedTime == time;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TimeSelector(
                      time: time,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedTime = time;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    selectedDate != null && selectedTime != null
                        ? () => widget.onSubmit(selectedDate!, selectedTime!)
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E9FFF),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: widget.onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF1E9FFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== DATE SELECTOR COMPONENT ==========

class DateSelector extends StatelessWidget {
  final String day;
  final String weekday;
  final bool isSelected;
  final VoidCallback onTap;

  const DateSelector({
    super.key,
    required this.day,
    required this.weekday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(
            color:
                isSelected
                    ? AppColors.bottomNavBarHighlightColor
                    : AppColors.whiteGreyColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              day,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
            height4,
            Text(
              weekday,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyle.bodySmall.copyWith(
                color: isSelected ? Colors.black54 : Colors.black38,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== TIME SELECTOR COMPONENT ==========

class TimeSelector extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const TimeSelector({
    super.key,
    required this.time,
    required this.isSelected,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = !isEnabled ? const Color(0xFFEAEAEA) : AppColors.whiteColor;
    final borderColor =
        !isEnabled
            ? const Color(0xFFD5D5D5)
            : (isSelected
                ? AppColors.bottomNavBarHighlightColor
                : AppColors.whiteColor);
    final textColor =
        !isEnabled
            ? const Color(0xFF9E9E9E)
            : (isSelected ? Colors.black : AppColors.subcolor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90.w,

        // padding: EdgeInsets.only(
        //   top: 24.sp,
        //   bottom: 24.sp,
        //   right: 10.sp,
        //   left: 10.sp,
        // ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            time,
            style: CustomTextStyle.bodyLarge.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),

            //  TextStyle(
            //   fontSize: 18,
            //   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            //   color: isSelected ? Colors.black : Colors.black54,
            // ),
          ),
        ),
      ),
    );
  }
}

// ========== DATA MODELS ==========

class DateOption {
  final String day;
  final String weekday;

  DateOption({required this.day, required this.weekday});
}
