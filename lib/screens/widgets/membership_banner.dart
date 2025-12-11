import 'package:flutter/material.dart';
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
        children: const [
          Icon(Icons.workspace_premium, color: Colors.amber, size: 30),
          SizedBox(width: 12),
          Text(
            "Silver Membership Plan",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
