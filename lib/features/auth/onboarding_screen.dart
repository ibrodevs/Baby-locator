import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kid_security/l10n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_language_sheet.dart';
import 'parent_auth_screen.dart';
import 'child_auth_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: AppLanguageButton(compact: true),
              ),
              const Spacer(flex: 2),

              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.navy],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 50),
              ),

              const SizedBox(height: 28),

              Text(
                t.appName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                t.onboardingTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimaryLight,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                t.onboardingSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 16,
                ),
              ),

              const Spacer(flex: 3),

              // Parent button
              _RoleButton(
                icon: Icons.person_rounded,
                label: t.iAmParent,
                color: AppColors.primary,
                textColor: Colors.white,
                iconBgColor: Colors.white.withValues(alpha: 0.2),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ParentAuthScreen()),
                ),
              ),

              const SizedBox(height: 16),

              // Child button
              _RoleButton(
                icon: Icons.child_care_rounded,
                label: t.iAmChild,
                color: AppColors.primarySoft,
                textColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.15),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChildAuthScreen()),
                ),
              ),

              const Spacer(),
            ],
          ),
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
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
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
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: textColor.withValues(alpha: 0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
