import 'package:flutter/material.dart';

/// Tadaima colour palette.
///
/// These values come straight from the Figma design system. Always use these
/// constants instead of hard-coded colours so the whole app stays consistent.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryTint = Color(0xFFFDECEC);

  // Accent - orange. Only for the "Tadaima - I'm home safe" action.
  static const Color accent = Color(0xFFC2410C);
  static const Color accentTint = Color(0xFFFFEDE0);

  // SOS - the gradient and white ring are ONLY used on the SOS button/screen.
  static const Color sosRed = Color(0xFFB71C1C);
  static const Color sosGradientStart = Color(0xFFD32F2F);
  static const Color sosGradientEnd = Color(0xFF9F1D26);
  static const Color onSos = Color(0xFFFFFFFF);

  // Status
  static const Color danger = Color(0xFFB71C1C);
  static const Color dangerBg = Color(0xFFFDECEC);
  static const Color success = Color(0xFF1B6E2F);
  static const Color successBg = Color(0xFFE3F3E6);
  static const Color warning = Color(0xFF7A4A00);
  static const Color warningBg = Color(0xFFFFF1D6);

  // Surfaces
  static const Color bg = Color(0xFFFFF9F7);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1F1A1A);
  static const Color textSecondary = Color(0xFF5C4F4F);

  // Lines and borders
  static const Color borderInput = Color(0xFF857474);
  static const Color divider = Color(0xFFEADDDA);

  // Disabled
  static const Color disabledBg = Color(0xFFEFE7E5);
  static const Color disabledText = Color(0xFF7A6B6B);

  // On-primary / on-accent
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onAccent = Color(0xFFFFFFFF);
}
