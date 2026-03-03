import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: AppColors.whiteColor.withOpacity(0.1)),
        BottomNavigationBar(
          currentIndex: widget.currentIndex,
          backgroundColor: AppColors.backgroundColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          onTap: widget.onTap,
          items: [
            _buildNavItem(
              inactiveAssetPath: 'assets/images/home-hashtag-inline.svg',
              activeAssetPath: 'assets/images/home-hashtag.svg',
              label: "Home",
              index: 0,
            ),
            _buildNavItem(
              inactiveAssetPath: 'assets/images/medal-star.svg',
              activeAssetPath: 'assets/images/medal-star-bold.svg',
              label: "Membership",
              index: 1,
            ),
            _buildNavItem(
              inactiveAssetPath: 'assets/images/calendar-tick.svg',
              activeAssetPath: 'assets/images/calendar-tick-bold.svg',
              label: "Events",
              index: 2,
            ),
            _buildNavItem(
              inactiveAssetPath: 'assets/images/clock.svg',
              activeAssetPath: 'assets/images/wallet-2.svg',
              label: "History",
              index: 3,
            ),
          ],
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required String inactiveAssetPath,
    required String activeAssetPath,
    required String label,
    required int index,
  }) {
    final isSelected = widget.currentIndex == index;
    final iconColor = isSelected ? Colors.white : Colors.white54;
    final assetPath = isSelected ? activeAssetPath : inactiveAssetPath;

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
        child: SvgPicture.asset(
          assetPath,
          width: 26,
          height: 26,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
      label: label,
    );
  }
}
