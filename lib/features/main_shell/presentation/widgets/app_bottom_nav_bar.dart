import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../controllers/main_shell_controller.dart';

/// Home - [Kamera] - Profile alt menüsü. Ortadaki yeşil buton yukarı taşar.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onScanPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onScanPressed;

  static const double _barHeight = 64;
  static const double _scanSize = 62;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: _barHeight + 28 + inset,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _barHeight + inset,
            child: Container(
              padding: EdgeInsets.only(bottom: inset),
              decoration: const BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      selected: currentIndex == MainShellController.homeTab,
                      onTap: () =>
                          onTabSelected(MainShellController.homeTab),
                    ),
                  ),
                  const SizedBox(width: _scanSize + 24),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      selected: currentIndex == MainShellController.profileTab,
                      onTap: () =>
                          onTabSelected(MainShellController.profileTab),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Semantics(
                button: true,
                label: 'Scan barcode',
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onScanPressed,
                    child: const SizedBox(
                      width: _scanSize - 8,
                      height: _scanSize - 8,
                      child: Icon(
                        Icons.photo_camera_outlined,
                        size: 28,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, size: 30, color: color),
            const SizedBox(height: 3),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
