import 'package:flutter/material.dart';

/// Tadaima colour palette.
///
/// These values come straight from the Figma design system. Always use these
/// constants instead of hard-coded colours so the whole app stays consistent.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0B6E6E);
  static const Color primaryDark = Color(0xFF084F4F);
  static const Color primaryTint = Color(0xFFE1F1F1);

  // SOS - red is ONLY used for SOS-related elements.
  static const Color sosRed = Color(0xFFC62828);
  static const Color onSos = Color(0xFFFFFFFF);

  // Status
  static const Color danger = Color(0xFFB3261E);
  static const Color dangerBg = Color(0xFFFDE8E6);
  static const Color success = Color(0xFF1B6E2F);
  static const Color successBg = Color(0xFFE3F3E6);
  static const Color warning = Color(0xFF8A5300);
  static const Color warningBg = Color(0xFFFFF1D6);

  // Surfaces
  static const Color bg = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1B2A2F);
  static const Color textSecondary = Color(0xFF4A5A5F);

  // Lines and borders
  static const Color borderInput = Color(0xFF78888C);
  static const Color divider = Color(0xFFD6DCDD);

  // Disabled
  static const Color disabledBg = Color(0xFFE9EDEE);
  static const Color disabledText = Color(0xFF6B7B80);

  // On-primary
  static const Color onPrimary = Color(0xFFFFFFFF);
}
