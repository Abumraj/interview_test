// Reusable Custom Back Button Component
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0A3D5C)),
        onPressed: onPressed,
      ),
    );
  }
}

// class CustomBackButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final bool? showText;

//   const CustomBackButton({super.key, required this.onPressed, this.showText});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios_new,
//               color: Colors.black,
//               size: 14,
//             ),
//           ),

//           if (showText == true) const SizedBox(width: 12),
//           if (showText == true)
//             const Text(
//               'Back',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
