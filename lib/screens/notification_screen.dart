import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interview/const.dart';
import 'package:interview/features/notifications/presentation/notifications_controller.dart';
import 'package:interview/helpers/date_extension.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:simple_grouped_listview/simple_grouped_listview.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: CustomProgressAppBar(showProgress: false, title: 'Notifications'),
      body: notificationsAsync.when(
        loading:
            () => Center(
              child: SpinKitFadingCircle(size: 30, color: AppColors.whiteColor),
            ),
        error:
            (_, __) => Center(
              child: TextButton(
                onPressed: () {
                  ref.read(notificationsListProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(notificationsListProvider.notifier).refresh();
              ref.read(unreadCountProvider.notifier).refresh();
            },
            child: GroupedListView.list(
              items: notifications,
              headerBuilder: (context, DateTime date) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: AppColors.whiteColor.withOpacity(0.1)),
                      height20,
                      Text(
                        formatDateTimeForGrouping(date),
                        style: CustomTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.whiteGreyColor2,
                          fontSize: 16.sp,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
              itemGrouper:
                  (item) => DateTime(
                    item.createdAt!.year,
                    item.createdAt!.month,
                    item.createdAt!.day,
                  ),
              listItemBuilder: (
                context,
                itemCountInGroup,
                itemIndexInGroup,
                item,
                itemIndexInOriginalList,
              ) {
                return GestureDetector(
                  onTap: () {
                    if (!item.isRead) {
                      ref
                          .read(notificationsListProvider.notifier)
                          .markAsRead(item.id);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    item.isRead
                                        ? AppColors.bottomNavBarHighlightColor
                                            .withOpacity(0.5)
                                        : AppColors.bottomNavBarHighlightColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title ?? 'No Title',
                                    style: CustomTextStyle.bodySmall.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.message ?? 'No Message',
                                    style: CustomTextStyle.bodySmall.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13.sp,
                                      color: AppColors.whiteGreyColor2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _timeAgo(item.createdAt!),
                              style: CustomTextStyle.bodySmall.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        height24,
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}hr${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
