import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:interview/const.dart';
import 'package:interview/utils/custom_styles.dart';

class DiamondMembershipCard extends StatelessWidget {
  const DiamondMembershipCard({
    super.key,
    required this.points,
    this.title = 'You are a Diamond user',
    this.subtitle = 'Access to a world of exclusive benefits',
  });

  final int points;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final formattedPoints = NumberFormat('#,##0.00').format(points.toDouble());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.membershipGradientEnd,
            AppColors.membershipGradientStart,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 9.0),
                child: SvgPicture.asset(
                  'assets/images/diamond.svg',
                  width: 34.sp,
                  height: 34.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CustomTextStyle.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.membershipGradientStart,
                  AppColors.membershipGradientEnd,
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/gift-bold.svg',
                    width: 28.sp,
                    height: 30.sp,
                    // colorFilter: const ColorFilter.mode(
                    //   AppColors.backgroundColor,
                    //   BlendMode.srcIn,
                    // ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    formattedPoints,
                    style: CustomTextStyle.headlineSmall.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Point',
                    style: CustomTextStyle.titleSmall.copyWith(
                      color: Colors.black.withOpacity(0.35),
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
