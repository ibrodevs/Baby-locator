import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';

import '../theme/app_colors.dart';

/// Top header: avatar (optional) + "Kid Security" logo + settings gear + extras.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.leading,
    this.trailing,
    this.title,
    this.titlePrefix,
  });

  final Widget? leading;
  final Widget? trailing;
  final String? title;
  final String? titlePrefix;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? S.of(context).appName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  letterSpacing: -0.3,
                ),
                children: [
                  if (titlePrefix != null) ...[
                    TextSpan(
                      text: '$titlePrefix ',
                      style: const TextStyle(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  TextSpan(text: resolvedTitle),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class GearButton extends StatelessWidget {
  const GearButton({super.key, this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap ?? () {},
      radius: 24,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: const Icon(Icons.settings_outlined,
            size: 24, color: AppColors.textPrimaryLight),
      ),
    );
  }
}

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    this.size = 32,
    this.initials = 'A',
    this.color = AppColors.primary,
    this.image,
  });
  final double size;
  final String initials;
  final Color color;
  final ImageProvider? image;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        image: image != null
            ? DecorationImage(image: image!, fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: image == null
          ? Text(
              initials,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.42,
              ),
            )
          : null,
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.color = Colors.white,
    this.radius = 18,
  });
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color color;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.background,
  });
  final String text;
  final Color color;
  final Color? background;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
