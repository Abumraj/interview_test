import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/screens/dashboard.dart';
import 'package:interview/utils/custom_styles.dart';
import 'package:interview/utils/heights.dart';
import 'package:interview/utils/page_transitions.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isVisible = false;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVisible = true;
      });
      _startTime();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isVisible
              ? AppColors.backgroundColor
              : AppColors.bottomNavBarHighlightColor,
      body: Stack(
        children: [
          // SvgPicture.asset("images/eclat_logo.svg"),
          Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Bounce(
                  duration: const Duration(milliseconds: 2200),

                  child: Image.asset(
                    "assets/images/logo2.png",
                    width: 144,
                    height: 144,
                  ),
                ),
                height20,

                // _isVisible
                //     ?
                SlideInLeft(
                  duration: const Duration(milliseconds: 2200),
                  child: Text(
                    "Laygos Water Crafts",
                    style: CustomTextStyle.headlineLarge.copyWith(
                      color: AppColors.whiteColor,
                      fontSize: 24.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // : const SizedBox.shrink(),
              ],
            ),
          ),
          // Align(
          //   alignment: Alignment.center,
          //   child: SvgPicture.asset("images/eclat_logo.svg"),
          // ),
        ],
      ),
    );
  }

  _startTime() async {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(FadeScaleRoute(page: const Dashboard()));
    });
  }
}
