import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interview/const.dart';
import 'package:interview/core/navigation/route_observer.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/features/profile/presentation/profile_controller.dart';
import 'package:interview/screens/edit_password_screen.dart';
import 'package:interview/screens/edit_profile_screen.dart';
import 'package:interview/screens/widgets/custom_appbar.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/money_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:interview/utils/page_transitions.dart';
import 'package:interview/screens/login_screen.dart';
import 'package:interview/utils/toast_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with RouteAware {
  bool _subscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (!_subscribed && route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    if (_subscribed) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  void _refreshProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(profileControllerProvider.notifier).refresh();
    });
  }

  @override
  void didPush() {
    _refreshProfile();
  }

  @override
  void didPopNext() {
    _refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);
    final authUser = ref.watch(authControllerProvider).value?.user;
    final user = profileAsync.value ?? authUser;

    final fullName =
        [user?.firstName, user?.lastName].whereType<String>().join(' ').trim();
    final displayName = fullName.isEmpty ? '—' : fullName;
    final email = (user?.email ?? '').trim();
    final phone = (user?.phoneNumber ?? '').trim();
    final isVerified = user?.isVerified == true;
    final bonusPoint = MoneyFormatter.ngn(user?.points);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomProgressAppBar(showProgress: false, title: 'Profile'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    height24,

                    if (profileAsync.isLoading)
                      Padding(
                        padding: EdgeInsets.only(right: 20.h),
                        child: SpinKitFadingCircle(
                          size: 22,
                          color: AppColors.lightBlue,
                        ),
                      ),
                    if (profileAsync.hasError)
                      Padding(
                        padding: EdgeInsets.only(right: 20.h, top: 8.h),
                        child: Text(
                          profileAsync.error.toString(),
                          style: CustomTextStyle.caption1.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.subcolor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width - 40.w,
                      height: 120.h,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30.r,
                            backgroundColor: AppColors.backgroundColor,
                            backgroundImage: CachedNetworkImageProvider(
                              'https://www.w3schools.com/howto/img_avatar.png',
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                displayName,
                                style: CustomTextStyle.headlineSmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              height8,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteGreyColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isVerified ? 'Verified' : 'Unverified',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.backgroundColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                SlideRightRoute(
                                  page: const EditProfileScreen(),
                                ),
                              );

                              if (!mounted) return;
                              ref
                                  .read(profileControllerProvider.notifier)
                                  .refresh();
                            },
                            child: Text(
                              'Edit',
                              style: CustomTextStyle.button.copyWith(
                                color: AppColors.lightBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    height24,

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.subcolor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width - 40.w,
                      height: 160.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/images/gift.svg",

                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Bonus Point ',
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          height10,
                          Text(
                            bonusPoint,
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 24.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    height30,
                    Text(
                      "Email Address",
                      style: CustomTextStyle.bodySmall.copyWith(
                        color: AppColors.whiteTextColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    height4,
                    Text(
                      email.isEmpty ? '—' : email,
                      style: CustomTextStyle.headlineSmall.copyWith(
                        color: AppColors.whiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    Divider(color: AppColors.whiteColor.withOpacity(0.2)),

                    height16,
                    Text(
                      "Phone",
                      style: CustomTextStyle.bodySmall.copyWith(
                        color: AppColors.whiteTextColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    height4,
                    Text(
                      phone.isEmpty ? '—' : phone,
                      style: CustomTextStyle.headlineSmall.copyWith(
                        color: AppColors.whiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    Divider(color: AppColors.whiteColor.withOpacity(0.2)),

                    Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 0,
                        minVerticalPadding: 0,
                        title: Text(
                          "Password Settings",
                          style: CustomTextStyle.bodySmall.copyWith(
                            color: AppColors.whiteTextColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        subtitle: Text(
                          "Reset Password",
                          style: CustomTextStyle.headlineSmall.copyWith(
                            color: AppColors.whiteColor,
                            fontSize: 16.sp,
                          ),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              SlideRightRoute(page: const EditPasswordScreen()),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/images/arrow-right.svg',
                            width: 16.sp,
                            height: 16.sp,
                            colorFilter: const ColorFilter.mode(
                              AppColors.whiteColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),

                    height35,
                    Text(
                      "Contact Us",
                      style: CustomTextStyle.bodyLarge.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                    height4,
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        fixedSize: Size(180.w, 30.h),

                        backgroundColor: AppColors.subcolor,
                      ),
                      onPressed: () async {
                        final uri = Uri(
                          scheme: 'mailto',
                          path: 'hello@lwc.com.ng',
                        );
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(width: 10.w),
                          Icon(Icons.email, color: AppColors.whiteColor),
                          Text(
                            "hello@lwc.com.ng",
                            style: CustomTextStyle.caption1.copyWith(
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    height4,
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        fixedSize: Size(160.w, 30.h),

                        backgroundColor: AppColors.subcolor,
                      ),
                      onPressed: () async {
                        final number = '+234812345678';
                        final uri = Uri(scheme: 'tel', path: number);
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(width: 10.w),
                          Icon(Icons.phone, color: AppColors.whiteColor),
                          Text(
                            "+2348 1 234 5678",
                            style: CustomTextStyle.caption1.copyWith(
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.h, 12, 20.h, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _showLogoutDialog(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    var isLoading = false;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> handleLogout() async {
                if (isLoading) return;
                setDialogState(() {
                  isLoading = true;
                });
                try {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop(true);
                } catch (e) {
                  if (!ctx.mounted) return;
                  setDialogState(() {
                    isLoading = false;
                  });
                  ToastHelper.showError('Logout failed: $e');
                }
              }

              return PopScope(
                canPop: !isLoading,
                child: AlertDialog(
                  backgroundColor: AppColors.subcolor,
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : handleLogout,
                      child:
                          isLoading
                              ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.redAccent,
                                  ),
                                ),
                              )
                              : const Text(
                                'Log Out',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
    );

    if (confirmed != true || !mounted) return;

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      FadeScaleRoute(page: const LoginScreen()),
      (route) => false,
    );
    ToastHelper.showSuccess('Logged out');
  }
}
