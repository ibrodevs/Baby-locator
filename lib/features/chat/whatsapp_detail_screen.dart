import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';

class WhatsAppDetailScreen extends StatelessWidget {
  const WhatsAppDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Text(
                    'Kid Security',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('WhatsApp: Leo & Alex',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Monitoring active · Last synced 2m ago',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Column(
                      children: [
                        _Ring(value: 0.92, label: '92', sub: 'SAFETY SCORE'),
                        const SizedBox(height: 14),
                        const Text('Conversation Analysis',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text(
                          'AI detected a constructive discussion about academic responsibilities. Interaction remains high-trust and low-risk.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: const [
                            StatusBadge(
                                text: 'POSITIVE INTENT',
                                color: AppColors.success),
                            StatusBadge(
                                text: 'HOMEWORK',
                                color: AppColors.textSecondaryLight),
                            StatusBadge(
                                text: 'GAMING',
                                color: AppColors.textSecondaryLight),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text('TODAY, 4:15 PM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        )),
                  ),
                  const SizedBox(height: 10),
                  const _ChatMsg(
                      from: 'Alex',
                      text:
                          'Hey Leo, did you finish the history assignment for tomorrow? It’s huge.',
                      mine: false),
                  const _ChatMsg(
                      from: 'Leo',
                      text:
                          'Almost. Just need to finish the part about the industrial revolution. Want to jump on Discord after?',
                      mine: true),
                  const _ChatMsg(
                      from: 'Alex',
                      text:
                          "Sure, but let's do homework first so we don't get in trouble. My mom is checking my grades today.",
                      mine: false,
                      keyword: 'homework'),
                  Padding(
                    padding: const EdgeInsets.only(left: 44, bottom: 8),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle,
                            color: AppColors.success, size: 14),
                        SizedBox(width: 4),
                        Text('KEYWORD LOGGED: HOMEWORK',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6)),
                      ],
                    ),
                  ),
                  const _ChatMsg(
                      from: 'Leo',
                      text: "Smart move. I'll message you when I'm done.",
                      mine: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.value, required this.label, required this.sub});
  final double value;
  final String label;
  final String sub;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
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
                      fontSize: 30, fontWeight: FontWeight.w800)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatMsg extends StatelessWidget {
  const _ChatMsg({
    required this.from,
    required this.text,
    required this.mine,
    this.keyword,
  });
  final String from;
  final String text;
  final bool mine;
  final String? keyword;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!mine) ...[
            const AvatarCircle(
                initials: 'A', color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: mine
                    ? null
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: mine ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 14,
                  ),
                  children: _buildSpans(text, keyword, mine),
                ),
              ),
            ),
          ),
          if (mine) ...[
            const SizedBox(width: 8),
            const AvatarCircle(
                initials: 'L', color: AppColors.accent, size: 28),
          ],
        ],
      ),
    );
  }

  List<TextSpan> _buildSpans(String text, String? keyword, bool mine) {
    if (keyword == null) return [TextSpan(text: text)];
    final idx = text.toLowerCase().indexOf(keyword.toLowerCase());
    if (idx < 0) return [TextSpan(text: text)];
    return [
      TextSpan(text: text.substring(0, idx)),
      TextSpan(
        text: text.substring(idx, idx + keyword.length),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: mine ? Colors.white : AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      TextSpan(text: text.substring(idx + keyword.length)),
    ];
  }
}
