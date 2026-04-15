import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import 'whatsapp_detail_screen.dart';

class MessengerSafetyScreen extends StatelessWidget {
  const MessengerSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 48),
                    child: Center(
                      child: Text(
                        'Kid Security',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 16),
                    child: Column(
                      children: [
                        _BigScoreRing(value: 0.92, label: '92%', sub: 'SECURE'),
                        const SizedBox(height: 14),
                        const Text(
                          'Messenger Safety\nScore',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your child's digital interactions are currently within safe parameters across all platforms.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Text('Live Intercepts',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      Spacer(),
                      StatusBadge(text: 'REAL-TIME', color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Intercept(
                    name: 'Alex (School Friend)',
                    time: '2m ago',
                    preview: '"Hey, are you joining the group call…"',
                    tag: 'Safe Content',
                    tagColor: AppColors.success,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const WhatsAppDetailScreen())),
                  ),
                  const SizedBox(height: 10),
                  _Intercept(
                    name: 'Unknown User',
                    time: '14m ago',
                    preview: '"Hey, I saw your post! Where do you…"',
                    tag: 'PII Request   Flagged',
                    tagColor: AppColors.danger,
                  ),
                  const SizedBox(height: 10),
                  _Intercept(
                    name: 'Dima Kuznetsov',
                    time: '1h ago',
                    preview: '"Check out this new game link l…"',
                    tag: 'External Link',
                    tagColor: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.rewardsGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sentiment Analysis',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        _SentimentBar(
                            label: 'Positive',
                            value: 0.78,
                            percent: '78%',
                            color: Colors.greenAccent),
                        const SizedBox(height: 12),
                        _SentimentBar(
                            label: 'Anxious/Stressed',
                            value: 0.12,
                            percent: '12%',
                            color: Colors.orangeAccent),
                        const SizedBox(height: 14),
                        const Text(
                          '"Conversations are mostly academic and casual. No signs of cyberbullying detected."',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.block,
                          label: 'BLOCKED RISKS',
                          value: '12',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.access_time,
                          label: 'TOTAL SCREEN TIME',
                          value: '3h 45m',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigScoreRing extends StatelessWidget {
  const _BigScoreRing(
      {required this.value, required this.label, required this.sub});
  final double value;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 10,
              backgroundColor: AppColors.dividerLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 34, fontWeight: FontWeight.w800)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Intercept extends StatelessWidget {
  const _Intercept({
    required this.name,
    required this.time,
    required this.preview,
    required this.tag,
    required this.tagColor,
    this.onTap,
  });
  final String name;
  final String time;
  final String preview;
  final String tag;
  final Color tagColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AvatarCircle(
                initials: 'A', color: AppColors.primary, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                      Text(time,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(preview,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 6),
                  StatusBadge(text: tag, color: tagColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  const _SentimentBar(
      {required this.label,
      required this.value,
      required this.percent,
      required this.color});
  final String label;
  final double value;
  final String percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            Text(percent,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondaryLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
