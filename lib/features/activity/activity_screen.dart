import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          BrandHeader(
            leading: const AvatarCircle(
                initials: 'A', color: AppColors.primary, size: 36),
            trailing: GearButton(onTap: () {}),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                const Text(
                  'Activity',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: const [
                      _ActivityRow(
                        icon: Icons.check_circle,
                        iconColor: AppColors.success,
                        title: 'Arrived at School',
                        subtitle: 'Elementary Elementary',
                        time: '08:15 AM',
                      ),
                      Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: AppColors.dividerLight),
                      _ActivityRow(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.success,
                        title: 'Left Home',
                        subtitle: 'Safe departure detected',
                        time: '07:50 AM',
                      ),
                      Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: AppColors.dividerLight),
                      _ActivityRow(
                        icon: Icons.bolt_rounded,
                        iconColor: AppColors.success,
                        title: 'Phone Charging',
                        subtitle: 'Battery restored to 85%',
                        time: '07:32 AM',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Text(
                      'Safe Zones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Zone')),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add, color: AppColors.primary, size: 18),
                          SizedBox(width: 4),
                          Text('Add Zone',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _SafeZoneCard(
                  title: 'Home',
                  subtitle: '200ft radius · Always active',
                  active: true,
                ),
                const SizedBox(height: 12),
                const _SafeZoneCard(
                  title: 'School',
                  subtitle: '150ft radius · Mon–Fri 8–3',
                  active: true,
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: Row(
                    children: [
                      _ScoreRing(value: 0.8, label: '80%'),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Daily Safety Score',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text(
                              'Alex has been behaving perfectly today.',
                              style: TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondaryLight, fontSize: 13)),
              ],
            ),
          ),
          Text(time,
              style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SafeZoneCard extends StatelessWidget {
  const _SafeZoneCard(
      {required this.title, required this.subtitle, required this.active});
  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Container(
                  height: 110,
                  color: const Color(0xFFD5E8C8),
                  child: CustomPaint(painter: _ZoneMapPainter()),
                ),
                if (active)
                  const Positioned(
                    left: 12,
                    top: 12,
                    child: StatusBadge(
                        text: 'ACTIVE', color: AppColors.success),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit $title')),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Edit Zone',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 6;
    for (double y = 18; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 4), road);
    }
    final circle = Paint()..color = AppColors.primary.withOpacity(0.22);
    final border = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 38, circle);
    canvas.drawCircle(c, 38, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.value, required this.label});
  final double value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              backgroundColor: AppColors.dividerLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.success)),
        ],
      ),
    );
  }
}
