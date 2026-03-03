import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview/const.dart';
import 'package:interview/utils/custom_styles.dart';

class RoundedSelector extends StatelessWidget {
  final String label;
  final bool selected;
  final Color backgroundColor;
  final VoidCallback onTap;

  const RoundedSelector({
    super.key,
    required this.label,
    this.backgroundColor = const Color(0xFF1A3A52),
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.bottomNavBarHighlightColor : backgroundColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            label,
            style: CustomTextStyle.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class SegmentedProgressIndicator extends StatelessWidget {
  final int currentValue;
  final List<int>? values;
  final int maxValue;
  final int segments;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final ValueChanged<int>? onSegmentTap;

  const SegmentedProgressIndicator({
    Key? key,
    required this.currentValue,
    this.values,
    this.maxValue = 30,
    this.segments = 5,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.white24,
    this.backgroundColor = const Color(0xFF1A3A52),
    this.onSegmentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final computedSegments = values?.length ?? segments;
    final segmentValue = maxValue / computedSegments;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const circleSize = 40.0;
          final connectorCount = (computedSegments - 1).clamp(0, 1000);

          final available =
              constraints.maxWidth - (computedSegments * circleSize);
          final connectorWidth =
              connectorCount == 0 ? 0.0 : (available / connectorCount);

          final clampedConnectorWidth =
              connectorWidth < 0 ? 0.0 : connectorWidth;

          return SizedBox(
            height: circleSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(computedSegments, (index) {
                final value =
                    values != null
                        ? values![index]
                        : ((index + 1) * segmentValue).toInt();
                final isActive = currentValue == value;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => onSegmentTap?.call(value),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? activeColor : inactiveColor,
                          // border: Border.all(
                          //   color: isActive ? activeColor : Colors.white,
                          //   width: 2,
                          // ),
                        ),
                        child: Center(
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (index < computedSegments - 1)
                      SizedBox(
                        width: clampedConnectorWidth,
                        height: 2,
                        child: CustomPaint(
                          painter: DottedLinePainter(color: Colors.white),
                        ),
                      ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    const dashWidth = 4;
    const dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
