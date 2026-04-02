import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/models/leisure.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:interview/utils/custom_styles.dart';

class LeisureCard extends StatelessWidget {
  final Leisure leisure;

  const LeisureCard({super.key, required this.leisure});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 210.h,
      decoration: BoxDecoration(
        color: AppColors.subCardcolor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8.r),
                  bottom: Radius.circular(8.r),
                ),
                child: CachedNetworkImage(
                  imageUrl: leisure.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        width: double.infinity,
                        color: AppColors.backgroundColor,
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        width: double.infinity,
                        color: AppColors.backgroundColor,
                      ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leisure.title,
                  style: CustomTextStyle.headlineSmall.copyWith(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  leisure.price,
                  style: CustomTextStyle.bodyMedium.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
