import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/utils/custom_styles.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double? fontSize;
  final double? fontWeight;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: CustomTextStyle.bodySmall.copyWith(
            fontSize: 11.sp,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: CustomTextStyle.bodyLarge.copyWith(
            fontSize: fontSize ?? 14.sp,
            color: AppColors.whiteColor,
            fontWeight: fontWeight == null ? FontWeight.w500 : FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
