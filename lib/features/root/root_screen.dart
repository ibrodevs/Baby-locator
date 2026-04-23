import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _index,
        children: [
          const MapScreen(),
          const ActivityScreen(),
          ChatScreen(isActive: _index == 2),
          const StatsScreen(showMenu: true),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
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
      (Icons.grid_view_rounded, 'Меню'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.dividerLight)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 6,
        left: 12,
        right: 12,
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? AppColors.primary : Colors.transparent,
                      ),
                      child: Icon(
                        items[i].$1,
                        size: 22,
                        color: active
                            ? Colors.white
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
