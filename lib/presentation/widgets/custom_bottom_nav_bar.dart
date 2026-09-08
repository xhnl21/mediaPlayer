import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

import 'package:media_player/presentation/utils/responsive_extensions.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final barHeight = context.h(0.072).clamp(54.0, 68.0);

    return SafeArea(
      top: false,
      child: Container(
        height: barHeight,
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          // Justified exception: 0.5 hairline divider
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.star_border_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
              barHeight: barHeight,
            ),
            _NavBarItem(
              icon: Icons.search_rounded,
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
              barHeight: barHeight,
            ),
            _NavBarItem(
              icon: Icons.music_note_rounded,
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
              barHeight: barHeight,
            ),
            _NavBarItem(
              icon: Icons.tune_rounded,
              isSelected: selectedIndex == 3,
              onTap: () => onItemSelected(3),
              barHeight: barHeight,
            ),
            _NavBarItem(
              icon: Icons.settings_outlined,
              isSelected: selectedIndex == 4,
              onTap: () => onItemSelected(4),
              barHeight: barHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.barHeight,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final itemSize = (barHeight * 0.70).clamp(36.0, 48.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(itemSize / 2),
      child: Container(
        width: itemSize,
        height: itemSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.textLight.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: context.iconSize(24),
          color: isSelected ? AppColors.textLight : AppColors.iconInactive,
        ),
      ),
    );
  }
}
