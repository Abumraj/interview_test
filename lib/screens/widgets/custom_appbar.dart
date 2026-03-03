import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/screens/widgets/custom_back_button.dart';
import 'package:interview/utils/custom_styles.dart';

class CustomProgressAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final Widget? leading;
  final String? title;
  final String? stepText;
  final bool showProgress;
  final double progress; // 0.0 - 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final Color? progressBackgroundColor;
  final Color? textColor;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomProgressAppBar({
    super.key,
    this.onBack,
    this.leading,
    this.title,
    this.stepText,
    this.showProgress = true,
    this.progress = 0.0,
    this.backgroundColor,
    this.progressColor,
    this.progressBackgroundColor,
    this.textColor,
    this.height,
    this.padding,
  });

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: backgroundColor ?? AppColors.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height ?? kToolbarHeight,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              leading ??
                  CustomBackButton(
                    // showText: false,
                    onPressed: () {
                      // Handle back navigation
                      Navigator.pop(context);
                    },
                  ),
              Expanded(
                child: Center(
                  child:
                      title != null
                          ? Text(
                            title!,
                            style: CustomTextStyle.bodySmall.copyWith(
                              color: textColor ?? AppColors.whiteColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : SizedBox.shrink(),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (stepText != null)
                    Text(
                      stepText!,
                      style: CustomTextStyle.bodySmall.copyWith(
                        color: textColor ?? AppTheme.scaffoldDark,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  SizedBox(width: stepText != null ? 12.w : 0),
                  if (showProgress) ...[
                    SizedBox(
                      width: 30.w,
                      height: 30.h,
                      child: SpinKitFadingCircle(
                        size: 30,
                        color: progressColor ?? AppTheme.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
