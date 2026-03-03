import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventTicketCard extends StatelessWidget {
  final String eventImage;
  final String eventDate;
  final String eventTitle;
  final String qrCode;
  final VoidCallback onViewTicket;

  const EventTicketCard({
    super.key,
    required this.eventImage,
    required this.eventDate,
    required this.eventTitle,
    required this.qrCode,
    required this.onViewTicket,
  });

  @override
  Widget build(BuildContext context) {
    final radius = 24.r;
    final seamCircleRadius = 18.r;
    final topSectionHeight = 18.h + 64.w + 18.h;
    const dividerHeight = 1.0;
    final seamTop = topSectionHeight + (dividerHeight / 2);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.subcolor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radius),
                    topRight: Radius.circular(radius),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: eventImage,
                        width: 64.w,
                        height: 64.w,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              width: 64.w,
                              height: 64.w,
                              color: AppColors.subCardcolor,
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              width: 64.w,
                              height: 64.w,
                              color: AppColors.subCardcolor,
                            ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            eventTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: AppColors.whiteColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Container(
                      width: 64.w,
                      height: 64.w,
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child:
                          qrCode.isEmpty
                              ? CachedNetworkImage(
                                imageUrl: qrCode,
                                fit: BoxFit.contain,
                                errorWidget:
                                    (context, url, error) => const Icon(
                                      Icons.qr_code_2,
                                      color: Colors.black,
                                      size: 40,
                                    ),
                              )
                              : AspectRatio(
                                aspectRatio: 1,
                                child: QrImageView(
                                  data: qrCode,
                                  version: QrVersions.auto,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                height: dividerHeight,
                width: double.infinity,
                color: Colors.white12,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.subcolor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(radius),
                    bottomRight: Radius.circular(radius),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onViewTicket,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 22.h,
                          horizontal: 18.w,
                        ),
                        child: Center(
                          child: Text(
                            'View Ticket',
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: AppColors.bottomNavBarHighlightColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: -seamCircleRadius,
            top: seamTop - seamCircleRadius,
            child: Container(
              width: seamCircleRadius * 2,
              height: seamCircleRadius * 2,
              decoration: const BoxDecoration(
                color: AppColors.backgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -seamCircleRadius,
            top: seamTop - seamCircleRadius,
            child: Container(
              width: seamCircleRadius * 2,
              height: seamCircleRadius * 2,
              decoration: const BoxDecoration(
                color: AppColors.backgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TicketPerforationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF0F1419)
          ..style = PaintingStyle.fill;

    const circleRadius = 10.0;
    const circleSpacing = 20.0;

    for (double x = 0; x < size.width; x += circleSpacing) {
      canvas.drawCircle(Offset(x, size.height / 2), circleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
