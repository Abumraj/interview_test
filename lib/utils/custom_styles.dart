import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';

class CustomTextStyle {
  static const List<String> _fallbackFonts = <String>[
    'Roboto',
    'SF Pro Display',
    'SF Pro Text',
    'Arial',
  ];

  static TextStyle headlineLarge = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headlineMedium = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headlineSmall = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleLarge = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleMedium = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleSmall = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyLarge = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.whiteColor,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle labelLarge = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelMedium = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteColor,
  );

  static TextStyle labelSmall = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle caption1 = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle caption2 = TextStyle(
    fontFamily: 'NotoSansJP',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
  );
  static TextStyle button = TextStyle(
    fontFamily: 'Helvetica',
    fontFamilyFallback: _fallbackFonts,
    fontSize: 14.sp,
    height: 1.5, // Line height 0.5px means 150% of font size
    fontWeight: FontWeight.bold,
  );
}

class CustomButtonStyle {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.lightBlue,
    foregroundColor: AppColors.whiteColor,
    textStyle: CustomTextStyle.labelLarge.copyWith(color: AppColors.whiteColor),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 2,
  );

  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.navBackgroundColor,
    foregroundColor: AppColors.whiteColor,
    textStyle: CustomTextStyle.labelLarge.copyWith(color: AppColors.whiteColor),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: AppColors.lightBlue, width: 1),
    ),
    elevation: 0,
  );

  static ButtonStyle outline = OutlinedButton.styleFrom(
    foregroundColor: AppColors.lightBlue,
    textStyle: CustomTextStyle.labelLarge.copyWith(color: AppColors.lightBlue),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    side: BorderSide(color: AppColors.lightBlue, width: 1),
  );

  static ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.lightBlue,
    textStyle: CustomTextStyle.labelLarge.copyWith(color: AppColors.lightBlue),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );

  static ButtonStyle disabled = ElevatedButton.styleFrom(
    backgroundColor: AppColors.inactiveButtonColor,
    foregroundColor: AppColors.whiteColor.withOpacity(0.5),
    textStyle: CustomTextStyle.labelLarge.copyWith(
      color: AppColors.whiteColor.withOpacity(0.5),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );
}
