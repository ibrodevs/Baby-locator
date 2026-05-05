import 'package:flutter/material.dart';

/// Family security palette — matches Figma screens.
class AppColors {
  AppColors._();

  // Primary (vibrant CTA blue)
  static const Color primary = Color(0xFF1C62F0);
  static const Color primaryDark = Color(0xFF0B2A8A);
  static const Color primarySoft = Color(0xFFEAF0FE);

  // Brand navy (used for "Family security" logo text)
  static const Color navy = Color(0xFF0B2A8A);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color accent = Color(0xFFFF6B9D);

  // Neutrals — light
  static const Color backgroundLight = Color(0xFFF3F4F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color chipGrey = Color(0xFFF1F2F6);

  // Neutrals — dark (kept for compatibility)
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color surfaceDark = Color(0xFF1A1D29);
  static const Color textPrimaryDark = Color(0xFFF6F7FB);
  static const Color textSecondaryDark = Color(0xFF9AA0B4);
  static const Color dividerDark = Color(0xFF2A2E3D);

  // Gradient for rewards banner
  static const LinearGradient rewardsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C62F0), Color(0xFF0B2A8A)],
  );
}
