import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A 40x40 rounded square icon tile with a centered 24px icon.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.color,
    this.background,
  });

  final IconData icon;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final tileColor = background ?? AppColors.primaryTint;
    final iconColor = color ?? AppColors.primary;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Icon(icon, size: 24, color: iconColor),
    );
  }
}
