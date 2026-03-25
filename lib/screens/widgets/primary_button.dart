import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/utils/custom_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed =
        (!enabled || isLoading) ? null : onPressed;
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bottomNavBarHighlightColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: effectiveOnPressed,
        child:
            isLoading
                ? SpinKitFadingCircle(size: 26, color: AppColors.whiteColor)
                : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }
}

EdgeInsets customPadding = EdgeInsets.symmetric(horizontal: 20.w);

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color? buttonColor;
  final double? borderRadius;
  final Color? textColor;
  final String buttonText;
  final Widget? leading;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? textfontSize;
  final bool? isLoading;
  final Key? globalkey;

  const CustomButton({
    required this.onTap,
    this.borderRadius,
    this.buttonColor,
    this.textColor,
    this.borderColor,
    required this.buttonText,
    this.leading,
    this.height,
    this.width,
    this.textfontSize,
    this.isLoading = false,
    this.globalkey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = isLoading == true ? null : onTap;
    return Container(
      key: globalkey,
      width: width ?? double.infinity,
      height: height ?? 50.h,
      decoration: BoxDecoration(
        color: buttonColor ?? AppTheme.primary,
        border: Border.all(color: borderColor ?? Colors.transparent),
        borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveOnTap,
          child: Center(
            child:
                isLoading == true
                    ? SpinKitFadingCircle(size: 30, color: AppColors.whiteColor)
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leading != null) ...[
                          leading!,
                          SizedBox(width: 10.w),
                        ],
                        Text(
                          buttonText,
                          style: CustomTextStyle.button.copyWith(
                            color: textColor ?? AppColors.whiteColor,
                            fontSize: textfontSize ?? 16.sp,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
