import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kid_security/l10n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_language_sheet.dart';
import 'child_auth_screen.dart';
import 'parent_auth_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _introController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          Positioned.fill(child: _AnimatedBackdrop(animation: _ambientController)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.52),
                    AppColors.backgroundLight.withValues(alpha: 0.88),
                    AppColors.backgroundLight,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 760;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedEntrance(
                          parent: _introController,
                          interval: const Interval(0.0, 0.25),
                          offset: const Offset(0, -0.16),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: AppLanguageButton(compact: true),
                          ),
                        ),
                        SizedBox(height: compact ? 18 : 34),
                        _AnimatedEntrance(
                          parent: _introController,
                          interval: const Interval(0.12, 0.48),
                          offset: const Offset(0, 0.16),
                          scaleFrom: 0.92,
                          child: _AnimatedHeroBadge(
                            animation: _ambientController,
                          ),
                        ),
                        SizedBox(height: compact ? 18 : 28),
                        _AnimatedEntrance(
                          parent: _introController,
                          interval: const Interval(0.24, 0.52),
                          offset: const Offset(0, 0.12),
                          child: Text(
                            t.appName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedEntrance(
                          parent: _introController,
                          interval: const Interval(0.32, 0.6),
                          offset: const Offset(0, 0.14),
                          child: Text(
                            t.onboardingTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimaryLight,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _AnimatedEntrance(
                          parent: _introController,
                          interval: const Interval(0.38, 0.68),
                          offset: const Offset(0, 0.14),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: Text(
                              t.onboardingSubtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 16 : 20),
                        _AnimatedEntrance(
                          parent: _introController,
                          interval: const Interval(0.44, 0.76),
                          offset: const Offset(0, 0.18),
                          child: const _FeatureRibbon(),
                        ),
                        SizedBox(height: compact ? 28 : 42),
                        _AnimatedEntrance(
                          parent: _introController,
                          interval: const Interval(0.56, 0.86),
                          offset: const Offset(0, 0.2),
                          child: _RoleButton(
                            icon: Icons.person_rounded,
                            label: t.iAmParent,
                            color: AppColors.primary,
                            textColor: Colors.white,
                            iconBgColor: Colors.white.withValues(alpha: 0.18),
                            shadowColor: AppColors.primary.withValues(alpha: 0.34),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ParentAuthScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _AnimatedEntrance(
                          parent: _introController,
                          interval: const Interval(0.66, 1.0),
                          offset: const Offset(0, 0.2),
                          child: _RoleButton(
                            icon: Icons.child_care_rounded,
                            label: t.iAmChild,
                            color: AppColors.primarySoft,
                            textColor: AppColors.primary,
                            iconBgColor: Colors.white,
                            borderColor: AppColors.primary.withValues(alpha: 0.14),
                            shadowColor: Colors.black.withValues(alpha: 0.05),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChildAuthScreen(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 8 : 14),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackdrop extends StatelessWidget {
  const _AnimatedBackdrop({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value * math.pi * 2;
          return Stack(
            children: [
              _Orb(
                size: 260,
                top: -40 + math.sin(t) * 18,
                left: -70 + math.cos(t * 0.8) * 20,
                colors: [
                  AppColors.primary.withValues(alpha: 0.20),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
              _Orb(
                size: 220,
                top: 110 + math.cos(t * 1.1) * 20,
                right: -80 + math.sin(t * 0.9) * 28,
                colors: [
                  AppColors.accent.withValues(alpha: 0.14),
                  AppColors.accent.withValues(alpha: 0.01),
                ],
              ),
              _Orb(
                size: 320,
                bottom: -120 + math.sin(t * 0.75) * 20,
                left: -90 + math.cos(t * 0.7) * 16,
                colors: [
                  AppColors.navy.withValues(alpha: 0.10),
                  AppColors.primary.withValues(alpha: 0.01),
                ],
              ),
              _Orb(
                size: 180,
                bottom: 80 + math.cos(t * 1.2) * 16,
                right: 8 + math.sin(t * 1.4) * 18,
                colors: [
                  Colors.white.withValues(alpha: 0.82),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.colors,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final double size;
  final List<Color> colors;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _AnimatedHeroBadge extends StatelessWidget {
  const _AnimatedHeroBadge({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 200,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value * math.pi * 2;
          final floatY = math.sin(t) * 8;
          final pulse = 1 + math.sin(t * 1.3) * 0.035;
          final tilt = math.sin(t * 0.8) * 0.035;
          final glow = 0.22 + (math.sin(t * 1.2) + 1) * 0.08;

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, floatY * 0.5),
                child: Transform.scale(
                  scale: 1.02 + math.sin(t * 1.1) * 0.03,
                  child: Container(
                    width: 178,
                    height: 178,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: glow),
                          AppColors.primary.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _FloatingBadge(
                top: 30 + math.cos(t * 0.9) * 6,
                left: 16 + math.sin(t * 1.1) * 8,
                icon: Icons.place_rounded,
                color: AppColors.primary,
                background: Colors.white.withValues(alpha: 0.95),
              ),
              _FloatingBadge(
                top: 42 + math.sin(t * 1.3) * 7,
                right: 22 + math.cos(t) * 6,
                icon: Icons.favorite_rounded,
                color: AppColors.accent,
                background: Colors.white.withValues(alpha: 0.94),
              ),
              _FloatingBadge(
                bottom: 14 + math.cos(t * 1.2) * 6,
                right: 42 + math.sin(t * 0.85) * 8,
                icon: Icons.notifications_active_rounded,
                color: AppColors.warning,
                background: Colors.white.withValues(alpha: 0.95),
              ),
              Transform.translate(
                offset: Offset(0, floatY),
                child: Transform.scale(
                  scale: pulse,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 132,
                        height: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.55),
                            width: 16,
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: tilt,
                        child: Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.navy,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.34),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({
    required this.icon,
    required this.color,
    required this.background,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _FeatureRibbon extends StatelessWidget {
  const _FeatureRibbon();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: const [
        _FeatureChip(
          icon: Icons.place_rounded,
          color: AppColors.primary,
        ),
        _FeatureChip(
          icon: Icons.chat_bubble_rounded,
          color: AppColors.accent,
        ),
        _FeatureChip(
          icon: Icons.health_and_safety_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }
}

class _AnimatedEntrance extends StatelessWidget {
  const _AnimatedEntrance({
    required this.parent,
    required this.interval,
    required this.child,
    this.offset = const Offset(0, 0.14),
    this.scaleFrom = 0.98,
  });

  final Animation<double> parent;
  final Interval interval;
  final Widget child;
  final Offset offset;
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: parent,
      curve: interval,
      reverseCurve: interval,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: parent,
            curve: Interval(
              interval.begin,
              interval.end,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: scaleFrom,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: parent,
              curve: Interval(
                interval.begin,
                interval.end,
                curve: Curves.easeOutBack,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.iconBgColor,
    required this.shadowColor,
    required this.onTap,
    this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color iconBgColor;
  final Color shadowColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: textColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: textColor.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
