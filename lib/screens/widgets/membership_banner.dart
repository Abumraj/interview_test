import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interview/const.dart';

class MembershipBanner extends StatelessWidget {
  const MembershipBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.subcolor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/crown.svg',
            width: 30,
            height: 30,
            colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Text(
            "Silver Membership Plan",
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
