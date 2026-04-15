import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool tiktok = true;
  bool roblox = true;
  bool instagram = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          BrandHeader(
            leading: const AvatarCircle(
                initials: 'P', color: AppColors.primary, size: 36),
            titlePrefix: 'Parent Profile',
            title: 'Kid Security',
            trailing: GearButton(onTap: () {}),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Row(
                  children: [
                    const Text('INSIGHTS',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1.2)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.calendar_today,
                              size: 12, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('Today',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Activity Hub',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Daily Goal',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text('2h 15m of 3h used',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight)),
                            SizedBox(height: 6),
                            Text('75 %',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                )),
                          ],
                        ),
                      ),
                      _BigBlueRing(value: 0.75),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text('Device Status',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          Spacer(),
                          StatusBadge(
                              text: 'ACTIVE', color: AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('iPhone 15 · Alex',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('84%',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(width: 6),
                          Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Icon(Icons.battery_full,
                                color: AppColors.success, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: const LinearProgressIndicator(
                          value: 0.84,
                          minHeight: 8,
                          backgroundColor: AppColors.dividerLight,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Weekly Usage',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          const Spacer(),
                          IconButton(
                              icon: const Icon(Icons.chevron_left, size: 18),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(Icons.chevron_right, size: 18),
                              onPressed: () {}),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 130,
                        child: _WeeklyBars(
                          values: const [0.45, 0.3, 0.55, 0.9, 0.1, 0.1, 0.1],
                          labels: const [
                            'MON',
                            'TUE',
                            'WED',
                            'THU',
                            'FRI',
                            'SAT',
                            'SUN'
                          ],
                          highlight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Manage App Limits',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _AppLimitRow(
                  icon: Icons.music_note,
                  iconBg: Colors.black,
                  name: 'TikTok',
                  usage: '1h 12m today',
                  value: tiktok,
                  onChanged: (v) => setState(() => tiktok = v),
                ),
                const SizedBox(height: 8),
                _AppLimitRow(
                  icon: Icons.videogame_asset,
                  iconBg: Colors.red,
                  name: 'Roblox',
                  usage: '45m today',
                  value: roblox,
                  onChanged: (v) => setState(() => roblox = v),
                ),
                const SizedBox(height: 8),
                _AppLimitRow(
                  icon: Icons.camera_alt,
                  iconBg: Colors.pinkAccent,
                  name: 'Instagram',
                  usage: '18m today',
                  value: instagram,
                  onChanged: (v) => setState(() => instagram = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigBlueRing extends StatelessWidget {
  const _BigBlueRing({required this.value});
  final double value;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              backgroundColor: AppColors.dividerLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const Icon(Icons.timer_outlined,
              color: AppColors.primary, size: 26),
        ],
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars(
      {required this.values, required this.labels, required this.highlight});
  final List<double> values;
  final List<String> labels;
  final int highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (i) {
        final v = values[i];
        final active = i == highlight;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.dividerLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? AppColors.primary
                          : AppColors.textMuted,
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AppLimitRow extends StatelessWidget {
  const _AppLimitRow({
    required this.icon,
    required this.iconBg,
    required this.name,
    required this.usage,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color iconBg;
  final String name;
  final String usage;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(usage,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.chipGrey,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text('Limit',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 6),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: AppColors.success,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
