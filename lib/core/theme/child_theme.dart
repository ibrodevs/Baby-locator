import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class ChildPalette extends ThemeExtension<ChildPalette> {
  const ChildPalette({
    required this.primary,
    required this.primarySoft,
    required this.primaryDark,
    required this.titleColor,
    required this.heroGradient,
  });

  final Color primary;
  final Color primarySoft;
  final Color primaryDark;
  final Color titleColor;
  final LinearGradient heroGradient;

  static const ChildPalette boy = ChildPalette(
    primary: AppColors.primary,
    primarySoft: AppColors.primarySoft,
    primaryDark: AppColors.primaryDark,
    titleColor: AppColors.navy,
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4D8DFF), Color(0xFF72B6FF)],
    ),
  );

  static const ChildPalette girl = ChildPalette(
    primary: Color(0xFFE85AA6),
    primarySoft: Color(0xFFFFE5F1),
    primaryDark: Color(0xFFB83280),
    titleColor: Color(0xFF9D174D),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF472B6), Color(0xFFF9A8D4)],
    ),
  );

  static ChildPalette fromGender(String? gender) =>
      gender == 'girl' ? girl : boy;

  static ChildPalette of(BuildContext context) =>
      Theme.of(context).extension<ChildPalette>() ?? boy;

  @override
  ChildPalette copyWith({
    Color? primary,
    Color? primarySoft,
    Color? primaryDark,
    Color? titleColor,
    LinearGradient? heroGradient,
  }) {
    return ChildPalette(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryDark: primaryDark ?? this.primaryDark,
      titleColor: titleColor ?? this.titleColor,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  ChildPalette lerp(ThemeExtension<ChildPalette>? other, double t) {
    if (other is! ChildPalette) return this;
    return ChildPalette(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t) ?? primarySoft,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t) ?? primaryDark,
      titleColor: Color.lerp(titleColor, other.titleColor, t) ?? titleColor,
      heroGradient: t < 0.5 ? heroGradient : other.heroGradient,
    );
  }
}
