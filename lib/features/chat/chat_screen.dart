import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import 'messenger_safety_screen.dart';

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
  bool _loading = true;
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
          final preferredId = widget.initialSelectedChildId;
          final hasPreferredChild =
              preferredId != null && list.any((c) => c['id'] == preferredId);
          _selectedChildId =
              hasPreferredChild ? preferredId : list.first['id'] as int;
          await _loadMessages();
        } else {
          setState(() => _loading = false);
        }
      } catch (e) {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      // Child: chat with parent (child_id = own id)
      _selectedChildId = user.id;
      await _loadMessages();
    }
    _startPolling();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _loadMessages());
  }

  Future<void> _loadMessages() async {
    if (_selectedChildId == null) return;
    try {
      final msgs = (await ApiClient.instance.getMessages(_selectedChildId!))
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      final wasAtBottom = _scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50;
      setState(() {
        _messages = msgs;
        _loading = false;
      });
      if (wasAtBottom || _messages.length <= 1) {
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final t = S.of(context);
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedChildId == null) return;
    _controller.clear();
    try {
      await ApiClient.instance.sendMessage(_selectedChildId!, text);
      await _loadMessages();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.failedToSend(e.toString()))),
        );
      }
    }
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
    final t = S.of(context);
    final user = ref.watch(sessionProvider).user;
    final isParent = user?.role == UserRole.parent;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
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
                children: [
                  if (isParent)
                    IconButton(
                      icon: const Icon(Icons.shield_outlined,
                          color: AppColors.textPrimaryLight),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const MessengerSafetyScreen()),
                      ),
                    ),
                  GearButton(onTap: () {}),
                ],
              ),
            ),
            // Child selector for parent
            if (isParent && _children.length > 1)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _children.length,
                  itemBuilder: (_, i) {
                    final c = _children[i];
                    final id = c['id'] as int;
                    final name =
                        ((c['display_name'] as String?)?.isNotEmpty ?? false)
                            ? c['display_name'] as String
                            : c['username'] as String;
                    final selected = id == _selectedChildId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(name),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedChildId = id;
                            _messages = [];
                            _loading = true;
                          });
                          _loadMessages();
                        },
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedChildId == null
                      ? Center(
                          child: Text(t.addChildToChat,
                              style: const TextStyle(
                                  color: AppColors.textMuted)))
                      : _messages.isEmpty
                          ? Center(
                              child: Text(t.noMessagesYet,
                                  style: const TextStyle(
                                      color: AppColors.textMuted)))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                              itemCount: _messages.length,
                              itemBuilder: (_, i) {
                                final msg = _messages[i];
                                final isMine = msg['sender'] == user?.id;
                                return _Bubble(
                                  text: msg['text'] as String,
                                  time:
                                      _formatTime(msg['created_at'] as String),
                                  isMine: isMine,
                                  senderName:
                                      (msg['sender_name'] as String?) ?? '',
                                  read: msg['read'] as bool? ?? false,
                                );
                              },
                            ),
            ),
            _Composer(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
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

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.dividerLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: t.sendMessage,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: AppColors.textMuted),
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
