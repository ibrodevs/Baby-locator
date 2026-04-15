import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import 'messenger_safety_screen.dart';
import 'whatsapp_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    _Msg(from: 'Leo', text: 'Hi Mom! I just finished my homework. Can I play games now?', time: '14:22', fromChild: true),
    _Msg(
      from: 'You',
      text: "That's great! Before that, could you please finish your chores for today?",
      time: '14:23',
      fromChild: false,
    ),
    _Msg(from: 'Leo', text: 'On it!', time: '14:35', fromChild: true, read: true),
  ];

  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(from: 'You', text: t, time: 'now', fromChild: false));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          BrandHeader(
            leading: const AvatarCircle(
                initials: 'A', color: AppColors.primary, size: 36),
            titlePrefix: null,
            title: 'Kid Security',
            trailing: Row(
              children: [
                _StarsChip(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const MessengerSafetyScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                GearButton(onTap: () {}),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              children: [
                _RewardsBanner(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const WhatsAppDetailScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ..._messages.map((m) => _Bubble(msg: m)),
                const SizedBox(height: 12),
                _TaskCard(
                  title: 'Clean your room',
                  reward: 'Reward: 50 Stars',
                  description:
                      'Put away toys, make the bed, and organize your desk.',
                  onComplete: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task marked complete')),
                  ),
                ),
                const SizedBox(height: 8),
                _Bubble(
                  msg: _Msg(
                    from: 'You',
                    text: "Let me know when it's done and I'll approve the stars!",
                    time: '14:30',
                    fromChild: false,
                  ),
                ),
              ],
            ),
          ),
          _Composer(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _StarsChip extends StatelessWidget {
  const _StarsChip({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: const [
            Icon(Icons.circle, size: 8, color: AppColors.success),
            SizedBox(width: 6),
            Text('1,240',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight)),
          ],
        ),
      ),
    );
  }
}

class _RewardsBanner extends StatelessWidget {
  const _RewardsBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.rewardsGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WEEKLY REWARDS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 6),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('1,240',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    )),
                SizedBox(width: 8),
                Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text('Stars earned',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: 0.65,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            const Text('80 more stars until Cinema Night reward!',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  _Msg({
    required this.from,
    required this.text,
    required this.time,
    required this.fromChild,
    this.read = false,
  });
  final String from;
  final String text;
  final String time;
  final bool fromChild;
  final bool read;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _Msg msg;
  @override
  Widget build(BuildContext context) {
    final mine = !msg.fromChild;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!mine) ...[
            const AvatarCircle(
                initials: 'L', color: AppColors.accent, size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: mine ? AppColors.primary : const Color(0xFFEEF1F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(mine ? 16 : 4),
                      bottomRight: Radius.circular(mine ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: mine ? Colors.white : AppColors.textPrimaryLight,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.read ? '${msg.time} ✓' : msg.time,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.reward,
    required this.description,
    required this.onComplete,
  });
  final String title;
  final String reward;
  final String description;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_rounded,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(reward,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              const StatusBadge(
                  text: 'PENDING', color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 10),
          Text(description,
              style: const TextStyle(
                  color: AppColors.textSecondaryLight, fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Mark as Complete',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.dividerLight)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.textSecondaryLight),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Send a message or task…',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.textMuted),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
