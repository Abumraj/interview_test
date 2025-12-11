import 'package:flutter/material.dart';
import 'package:interview/const.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      backgroundColor: AppColors.bottomNavBarHighlightColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      onTap: widget.onTap,
      items: [
        _buildNavItem(Icons.grid_view_rounded, "Home", 0),
        _buildNavItem(Icons.workspace_premium, "Membership", 1),
        _buildNavItem(Icons.event, "Events", 2),
        _buildNavItem(Icons.history, "History", 3),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = widget.currentIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration:
            isSelected
                ? BoxDecoration(
                  color: AppColors.bottomNavBarHighlightColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.bottomNavBarHighlightColor.withOpacity(
                      0.3,
                    ),
                    width: 1,
                  ),
                )
                : null,
        child: Icon(icon, size: 26),
      ),
      label: label,
    );
  }
}
