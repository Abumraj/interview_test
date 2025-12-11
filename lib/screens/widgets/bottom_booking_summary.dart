import 'package:flutter/material.dart';
import 'package:interview/const.dart';

class BottomBookingSummary extends StatelessWidget {
  final String duration;
  final int total;

  const BottomBookingSummary({
    super.key,
    required this.duration,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.subcolor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Duration:", style: TextStyle(color: Colors.white70)),
              Text(
                duration,
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white30),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total:", style: TextStyle(color: Colors.white70)),
              Text(
                "₦${total.toStringAsFixed(0)}.00",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
