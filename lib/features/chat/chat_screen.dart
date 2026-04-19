import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/child_selector_chips.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.initialSelectedChildId});

  final int? initialSelectedChildId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _children = [];
  int? _selectedChildId;
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _rewards = [];
  int _totalStars = 0;
  // ignore: unused_field
  int _starBalance = 0;
  bool _loading = true;
  bool _didInitialScrollToBottom = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;

    if (user.role == UserRole.parent) {
      try {
        final list = (await ApiClient.instance.listChildren())
            .cast<Map<String, dynamic>>();
        if (!mounted) return;
        setState(() => _children = list);
        if (list.isNotEmpty) {
          final selectedChildId = _resolveInitialChildId(list);
          ref.read(selectedChildIdProvider.notifier).state = selectedChildId;
          _selectedChildId = selectedChildId;
          await _loadAll();
        } else {
          ref.read(selectedChildIdProvider.notifier).state = null;
          setState(() => _loading = false);
        }
      } catch (e) {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      _selectedChildId = user.id;
      await _loadAll();
    }
    _startPolling();
  }

  int _resolveInitialChildId(List<Map<String, dynamic>> list) {
    final providerChildId = ref.read(selectedChildIdProvider);
    final preferredIds = [
      widget.initialSelectedChildId,
      providerChildId,
    ].whereType<int>();
    for (final id in preferredIds) {
      if (list.any((child) => child['id'] == id)) {
        return id;
      }
    }
    return list.first['id'] as int;
  }

  Future<void> _setSelectedChild(
    int id, {
    bool syncProvider = true,
  }) async {
    if (_selectedChildId == id) return;
    if (syncProvider) {
      ref.read(selectedChildIdProvider.notifier).state = id;
    }
    setState(() {
      _selectedChildId = id;
      _messages = [];
      _tasks = [];
      _rewards = [];
      _totalStars = 0;
      _starBalance = 0;
      _loading = true;
      _didInitialScrollToBottom = false;
    });
    await _loadAll();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _loadAll());
  }

  Future<void> _loadAll() async {
    if (_selectedChildId == null) return;
    try {
      final results = await Future.wait([
        ApiClient.instance.getMessages(_selectedChildId!),
        ApiClient.instance.getTasks(_selectedChildId!),
        ApiClient.instance.getStars(_selectedChildId!),
        ApiClient.instance.getRewards(_selectedChildId!),
      ]);
      if (!mounted) return;
      final wasAtBottom = _scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50;
      setState(() {
        _messages = (results[0] as List<dynamic>).cast<Map<String, dynamic>>();
        _tasks = (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
        final stars = results[2] as Map<String, dynamic>;
        _totalStars = (stars['total_earned'] as int?) ?? 0;
        _starBalance = (stars['balance'] as int?) ?? 0;
        _rewards = (results[3] as List<dynamic>).cast<Map<String, dynamic>>();
        _loading = false;
      });
      if (!_didInitialScrollToBottom) {
        _didInitialScrollToBottom = true;
        _scrollToBottom(animated: false);
      } else if (wasAtBottom || _messages.length <= 1) {
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final offset = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(offset);
        }
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedChildId == null) return;
    _controller.clear();
    try {
      await ApiClient.instance.sendMessage(_selectedChildId!, text);
      await _loadAll();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  Future<void> _completeTask(int taskId) async {
    if (_selectedChildId == null) return;
    try {
      await ApiClient.instance.completeTask(_selectedChildId!, taskId);
      await _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _approveTask(int taskId) async {
    if (_selectedChildId == null) return;
    try {
      await ApiClient.instance.approveTask(_selectedChildId!, taskId);
      await _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showAddTaskDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final starsCtrl = TextEditingController(text: '50');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'e.g. Clean your room',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Put away toys, make the bed...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: starsCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reward Stars',
                prefixIcon:
                    const Icon(Icons.star, color: AppColors.warning, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                final stars = int.tryParse(starsCtrl.text.trim()) ?? 0;
                Navigator.pop(ctx);
                try {
                  await ApiClient.instance.createTask(
                    _selectedChildId!,
                    title: title,
                    description: descCtrl.text.trim(),
                    rewardStars: stars,
                  );
                  await _loadAll();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Add Task',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRewardDialog() {
    final titleCtrl = TextEditingController();
    final starsCtrl = TextEditingController(text: '500');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Reward',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Reward Title',
                hintText: 'e.g. Cinema Night',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: starsCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Required Stars',
                prefixIcon:
                    const Icon(Icons.star, color: AppColors.warning, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                final stars = int.tryParse(starsCtrl.text.trim()) ?? 0;
                if (stars <= 0) return;
                Navigator.pop(ctx);
                try {
                  await ApiClient.instance.createReward(
                    _selectedChildId!,
                    title: title,
                    requiredStars: stars,
                  );
                  await _loadAll();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Add Reward',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(selectedChildIdProvider, (previous, next) {
      final user = ref.read(sessionProvider).user;
      if (user?.role != UserRole.parent ||
          !mounted ||
          next == null ||
          next == _selectedChildId) {
        return;
      }
      if (_children.any((child) => child['id'] == next)) {
        _setSelectedChild(next, syncProvider: false);
      }
    });
    final user = ref.watch(sessionProvider).user;
    final isParent = user?.role == UserRole.parent;

    // Find the next unclaimed reward for the progress banner
    final unclaimedRewards = _rewards
        .where((r) => r['claimed'] != true)
        .toList()
      ..sort((a, b) =>
          (a['required_stars'] as int).compareTo(b['required_stars'] as int));
    final nextReward =
        unclaimedRewards.isNotEmpty ? unclaimedRewards.first : null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            BrandHeader(
              leading: AvatarCircle(
                initials: (user?.displayName.isNotEmpty ?? false)
                    ? user!.displayName[0].toUpperCase()
                    : 'U',
                color: AppColors.primary,
                size: 36,
                image: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
              ),
              titlePrefix: null,
              title: 'Kid Security',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stars indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_totalStars',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Child selector for parent
            if (isParent)
              ChildSelectorChips(
                children: _children,
                selectedChildId: _selectedChildId,
                onSelected: _setSelectedChild,
              ),

            // Weekly Rewards Banner
            if (!_loading && _selectedChildId != null)
              _WeeklyRewardsBanner(
                totalStars: _totalStars,
                nextReward: nextReward,
              ),

            // Main content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedChildId == null
                      ? const Center(
                          child: Text('Add a child to start chatting',
                              style: TextStyle(color: AppColors.textMuted)),
                        )
                      : _buildChatList(user, isParent),
            ),

            // Composer
            _ChatComposer(
              controller: _controller,
              onSend: _send,
              isParent: isParent,
              onAddTask: _showAddTaskDialog,
              onAddReward: _showAddRewardDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(SessionUser? user, bool isParent) {
    // Build a combined list: messages + task cards interleaved by time
    final items = <_ChatItem>[];

    for (final msg in _messages) {
      items.add(_ChatItem(
        type: _ChatItemType.message,
        data: msg,
        time: DateTime.tryParse(msg['created_at'] as String? ?? '') ??
            DateTime.now(),
      ));
    }

    for (final task in _tasks) {
      items.add(_ChatItem(
        type: _ChatItemType.task,
        data: task,
        time: DateTime.tryParse(task['created_at'] as String? ?? '') ??
            DateTime.now(),
      ));
    }

    items.sort((a, b) => a.time.compareTo(b.time));

    if (items.isEmpty) {
      return const Center(
        child: Text('No messages yet. Say hello!',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }

    // Group by date
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        Widget? dateSeparator;

        // Show date separator
        if (i == 0 || !_isSameDay(items[i - 1].time, item.time)) {
          dateSeparator = _DateSeparator(date: item.time);
        }

        Widget child;
        if (item.type == _ChatItemType.message) {
          final msg = item.data;
          final isMine = msg['sender'] == user?.id;
          child = _Bubble(
            text: msg['text'] as String,
            time: _formatTime(msg['created_at'] as String),
            isMine: isMine,
            senderName: (msg['sender_name'] as String?) ?? '',
            read: msg['read'] as bool? ?? false,
          );
        } else {
          child = _TaskCard(
            task: item.data,
            isParent: isParent,
            onComplete: () => _completeTask(item.data['id'] as int),
            onApprove: () => _approveTask(item.data['id'] as int),
          );
        }

        if (dateSeparator != null) {
          return Column(
            children: [dateSeparator, child],
          );
        }
        return child;
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }
}

// === Data types ===

enum _ChatItemType { message, task }

class _ChatItem {
  _ChatItem({required this.type, required this.data, required this.time});
  final _ChatItemType type;
  final Map<String, dynamic> data;
  final DateTime time;
}

// === Weekly Rewards Banner ===

class _WeeklyRewardsBanner extends StatelessWidget {
  const _WeeklyRewardsBanner({
    required this.totalStars,
    required this.nextReward,
  });
  final int totalStars;
  final Map<String, dynamic>? nextReward;

  @override
  Widget build(BuildContext context) {
    final nextTitle =
        nextReward != null ? nextReward!['title'] as String : 'Set a reward';
    final nextRequired =
        nextReward != null ? nextReward!['required_stars'] as int : 0;
    final starsLeft = nextRequired > totalStars ? nextRequired - totalStars : 0;
    final progress =
        nextRequired > 0 ? (totalStars / nextRequired).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.rewardsGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'WEEKLY REWARDS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalStars',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'Stars earned',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 8),
          if (nextReward != null)
            Text(
              '$starsLeft more stars until $nextTitle reward!',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

// === Date Separator ===

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final label = isToday ? 'TODAY' : DateFormat('MMM d, yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// === Message Bubble ===

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.time,
    required this.isMine,
    required this.senderName,
    required this.read,
  });
  final String text;
  final String time;
  final bool isMine;
  final String senderName;
  final bool read;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            AvatarCircle(
              initials:
                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
              color: AppColors.accent,
              size: 28,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMine && senderName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMine ? AppColors.primary : const Color(0xFFEEF1F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMine ? 16 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMine ? Colors.white : AppColors.textPrimaryLight,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  read && isMine ? '$time \u2713' : time,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === Task Card ===

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.isParent,
    required this.onComplete,
    required this.onApprove,
  });
  final Map<String, dynamic> task;
  final bool isParent;
  final VoidCallback onComplete;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final title = task['title'] as String? ?? '';
    final description = task['description'] as String? ?? '';
    final stars = task['reward_stars'] as int? ?? 0;
    final status = task['status'] as String? ?? 'pending';

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'completed':
        statusColor = AppColors.warning;
        statusLabel = 'COMPLETED';
        break;
      case 'approved':
        statusColor = AppColors.success;
        statusLabel = 'APPROVED';
        break;
      default:
        statusColor = AppColors.warning;
        statusLabel = 'PENDING';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.task_alt,
                        size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Reward stars
            Padding(
              padding: const EdgeInsets.fromLTRB(62, 2, 16, 0),
              child: Row(
                children: [
                  const Text('Reward: ',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const Icon(Icons.star, size: 14, color: AppColors.warning),
                  const SizedBox(width: 2),
                  Text(
                    '$stars Stars',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

            // Description
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Action button
            if (status == 'pending' && !isParent)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Mark as Complete',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            // Parent: approve completed task
            if (status == 'completed' && isParent)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.thumb_up_outlined, size: 18),
                    label: const Text('Approve & Award Stars',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            // Approved check
            if (status == 'approved')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Completed! +$stars stars earned',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),

            // Pending info for parent
            if (status == 'pending' && isParent)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty,
                        size: 14, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'Waiting for child to complete...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
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

// === Composer ===

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.onSend,
    required this.isParent,
    required this.onAddTask,
    required this.onAddReward,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isParent;
  final VoidCallback onAddTask;
  final VoidCallback onAddReward;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.dividerLight)),
      ),
      child: Row(
        children: [
          if (isParent)
            PopupMenuButton<String>(
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.textSecondaryLight, size: 26),
              onSelected: (val) {
                if (val == 'task') onAddTask();
                if (val == 'reward') onAddReward();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'task',
                  child: Row(
                    children: [
                      Icon(Icons.task_alt, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Add Task'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reward',
                  child: Row(
                    children: [
                      Icon(Icons.card_giftcard,
                          color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Text('Add Reward'),
                    ],
                  ),
                ),
              ],
            ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Send a message or task...',
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
