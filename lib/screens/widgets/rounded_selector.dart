import 'package:flutter/material.dart';
import 'package:interview/const.dart';

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
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SegmentedProgressIndicator extends StatelessWidget {
  final int currentValue;
  final int maxValue;
  final int segments;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final ValueChanged<int>? onSegmentTap;

  const SegmentedProgressIndicator({
    Key? key,
    required this.currentValue,
    this.maxValue = 30,
    this.segments = 5,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.white24,
    this.backgroundColor = const Color(0xFF1A3A52),
    this.onSegmentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final segmentValue = maxValue / segments;
    final activeSegments = (currentValue / segmentValue).ceil();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(segments, (index) {
          final value = (index + 1) * segmentValue.toInt();
          final isActive = currentValue == value;

          return Row(
            children: [
              // Circle indicator with tap
              GestureDetector(
                onTap: () => onSegmentTap?.call(value),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? activeColor : inactiveColor,
                    border: Border.all(
                      color: isActive ? activeColor : Colors.white,
                      width: 2,
                    ),
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
              // Dotted line connector (except for last item)
              if (index < segments - 1)
                CustomPaint(
                  size: Size(35, 2),
                  painter: DottedLinePainter(
                    color: Colors.white,
                    // isActive && index + 1 < activeSegments
                    //     ? activeColor
                    //     : inactiveColor,
                  ),
                ),
            ],
          );
        }),
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
