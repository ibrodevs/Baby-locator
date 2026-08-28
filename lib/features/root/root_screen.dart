import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';

import '../../core/theme/app_colors.dart';
import '../activity/activity_screen.dart';
import '../chat/chat_screen.dart';
import '../map/map_screen.dart';
import '../stats/stats_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;
  final _activeIndexNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _activeIndexNotifier.dispose();
    super.dispose();
  }

  void _onTabTapped(int i) {
    if (i != _index) {
      setState(() => _index = i);
      _activeIndexNotifier.value = i;
    }
  }

  Widget _buildTab(int i) {
    return switch (i) {
      0 => const MapScreen(),
      1 => const ActivityScreen(),
      2 => ValueListenableBuilder<int>(
          valueListenable: _activeIndexNotifier,
          builder: (_, active, __) => ChatScreen(isActive: active == 2),
        ),
      3 => const StatsScreen(showMenu: true),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _index,
        children: List.generate(4, _buildTab),
      ),
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onChanged: _onTabTapped,
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final items = <(IconData, String)>[
      (Icons.location_on_outlined, t.navMap),
      (Icons.notifications_none_rounded, t.navActivity),
      (Icons.chat_bubble_outline_rounded, t.navChat),
      (Icons.grid_view_rounded, ExtraL10n.of(context).menuLabel),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final (icon, label) = items[i];
              final isSelected = index == i;
              return _BottomNavItem(
                icon: icon,
                label: label,
                isSelected: isSelected,
                onTap: () => onChanged(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
