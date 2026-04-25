import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kid_security/l10n/app_localizations.dart';

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/child_theme.dart';
import '../chat/chat_screen.dart';
import 'child_home_screen.dart';
import 'child_settings_screen.dart';

class ChildRootScreen extends ConsumerStatefulWidget {
  const ChildRootScreen({super.key});
  @override
  ConsumerState<ChildRootScreen> createState() => _ChildRootScreenState();
}

class _ChildRootScreenState extends ConsumerState<ChildRootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final palette = ChildPalette.fromGender(
      ref.watch(sessionProvider).user?.gender,
    );
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: palette.primary),
        extensions: <ThemeExtension<dynamic>>[palette],
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            const ChildHomeScreen(),
            ChatScreen(isActive: _index == 1),
            const ChildSettingsScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.dividerLight)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: t.navHome,
                    selected: _index == 0,
                    onTap: () => setState(() => _index = 0),
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_rounded,
                    label: t.navChat,
                    selected: _index == 1,
                    onTap: () => setState(() => _index = 1),
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: t.childNavSettings,
                    selected: _index == 2,
                    onTap: () => setState(() => _index = 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? ChildPalette.of(context).primary : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
