import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/features/notifications/presentation/notifications_controller.dart';
import 'package:interview/screens/Profile_screen.dart';
import 'package:interview/screens/cart_screen.dart';
import 'package:interview/screens/notification_screen.dart';
import 'package:interview/features/bookings/presentation/bookings_controller.dart';
import 'package:interview/utils/page_transitions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key, this.showCart = false});

  final bool showCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final unreadCount = ref.watch(unreadCountProvider).value ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(SlideRightRoute(page: const ProfileScreen()));
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: CachedNetworkImageProvider(
                    'https://www.w3schools.com/howto/img_avatar.png',
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(SlideRightRoute(page: const NotificationScreen()));
                    },
                    child:
                        showCart
                            ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/notification.svg',
                                  width: 36.w,
                                  height: 36.h,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF8C42),
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 14,
                                        minHeight: 14,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                            : Container(
                              width: 32.w,
                              height: 32.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Center(
                                    child: SvgPicture.asset(
                                      'assets/images/notification.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFF8C42),
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 14,
                                          minHeight: 14,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$unreadCount',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                  ),
                  if (showCart) ...[
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(SlideUpRoute(page: const OrderBagScreen()));
                      },
                      child: CartBadge(
                        count: cartCount,
                        size: 38,
                        iconSize: 18,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Divider(color: AppColors.whiteColor.withOpacity(0.1)),
        ],
      ),
    );
  }
}
