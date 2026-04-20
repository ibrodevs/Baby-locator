import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kid_security/l10n/app_localizations.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/services/chat_visibility_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/child_selector_chips.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    this.initialSelectedChildId,
    this.isActive = true,
  });

  final int? initialSelectedChildId;
  final bool isActive;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _children = [];
  int? _selectedChildId;
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _pendingMessages = [];
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _rewards = [];
  int _totalStars = 0;
  // ignore: unused_field
  int _starBalance = 0;
  bool _loading = true;
  bool _didInitialScrollToBottom = false;
  Timer? _poll;
  bool _conversationLoading = false;
  bool _markReadInFlight = false;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  int _localMessageCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appLifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
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
    _updatePollingState();
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
      _pendingMessages = [];
      _tasks = [];
      _rewards = [];
      _totalStars = 0;
      _starBalance = 0;
      _loading = true;
      _didInitialScrollToBottom = false;
    });
    _syncActiveChatVisibility();
    await _loadAll();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _loadConversation(),
    );
  }

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  void _updatePollingState() {
    if (_canInteractWithChat) {
      _startPolling();
      unawaited(_loadConversation());
      unawaited(_markConversationAsRead());
    } else {
      _stopPolling();
    }
    _syncActiveChatVisibility();
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
      setState(() {
        _messages = (results[0] as List<dynamic>).cast<Map<String, dynamic>>();
        _tasks = (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
        final stars = results[2] as Map<String, dynamic>;
        _totalStars = (stars['total_earned'] as int?) ?? 0;
        _starBalance = (stars['balance'] as int?) ?? 0;
        _rewards = (results[3] as List<dynamic>).cast<Map<String, dynamic>>();
        _loading = false;
      });
      _syncScrollAfterConversationUpdate();
      unawaited(_markConversationAsRead());
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadConversation() async {
    if (_selectedChildId == null || _conversationLoading) return;
    _conversationLoading = true;
    try {
      final results = await Future.wait([
        ApiClient.instance.getMessages(_selectedChildId!),
        ApiClient.instance.getTasks(_selectedChildId!),
      ]);
      if (!mounted) return;
      final wasAtBottom = _isNearBottom;
      final messages = List<Map<String, dynamic>>.from(results[0]);
      final tasks = List<Map<String, dynamic>>.from(results[1]);
      final hadChanges =
          !_sameIds(_messages, messages) || !_sameIds(_tasks, tasks);
      if (!hadChanges && !_loading) {
        return;
      }
      setState(() {
        _messages = messages;
        _tasks = tasks;
        _loading = false;
      });
      _syncScrollAfterConversationUpdate(wasAtBottom: wasAtBottom);
      unawaited(_markConversationAsRead());
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    } finally {
      _conversationLoading = false;
    }
  }

  bool get _canInteractWithChat =>
      widget.isActive && _appLifecycleState == AppLifecycleState.resumed;

  void _syncActiveChatVisibility() {
    final activeChildId = _canInteractWithChat ? _selectedChildId : null;
    ChatVisibilityService.instance.setActiveChildFor(this, activeChildId);
  }

  Future<void> _markConversationAsRead() async {
    if (!_canInteractWithChat ||
        _selectedChildId == null ||
        _markReadInFlight ||
        !mounted) {
      return;
    }

    final userId = ref.read(sessionProvider).user?.id;
    if (userId == null) return;

    final unreadIncomingIds = _messages
        .where((msg) =>
            (msg['sender'] as int?) != userId &&
            (msg['is_read'] as bool? ?? false) == false)
        .map((msg) => msg['id'] as int?)
        .whereType<int>()
        .toList();

    if (unreadIncomingIds.isEmpty) return;

    _markReadInFlight = true;
    try {
      await ApiClient.instance.markMessagesRead(
        _selectedChildId!,
        messageIds: unreadIncomingIds,
      );
      if (!mounted) return;
      setState(() {
        final now = DateTime.now().toUtc().toIso8601String();
        _messages = _messages.map((msg) {
          final id = msg['id'] as int?;
          if (id == null || !unreadIncomingIds.contains(id)) {
            return msg;
          }
          return {
            ...msg,
            'status': 'read',
            'is_read': true,
            'read_at': msg['read_at'] ?? now,
          };
        }).toList();
      });
    } catch (_) {
      // Best-effort: next refresh will retry.
    } finally {
      _markReadInFlight = false;
    }
  }

  bool get _isNearBottom =>
      _scrollController.hasClients &&
      _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;

  void _syncScrollAfterConversationUpdate({bool? wasAtBottom}) {
    final shouldStickToBottom = wasAtBottom ?? _isNearBottom;
    if (!_didInitialScrollToBottom) {
      _didInitialScrollToBottom = true;
      _scrollToBottom(animated: false);
    } else if (shouldStickToBottom || _messages.length <= 1) {
      _scrollToBottom();
    }
  }

  bool _sameIds(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i]['id'] != b[i]['id']) return false;
      if (a[i]['status'] != b[i]['status']) return false;
      if (a[i]['updated_at'] != b[i]['updated_at']) return false;
    }
    return true;
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
    await _submitOutgoingMessage(text: text);
  }

  Future<void> _pickAndSendFile() async {
    if (_selectedChildId == null) return;
    final picker = ImagePicker();
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Photo from gallery'),
              onTap: () => Navigator.pop(ctx, 'gallery_photo'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Photo from camera'),
              onTap: () => Navigator.pop(ctx, 'camera_photo'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_rounded,
                  color: AppColors.primary),
              title: const Text('Video from gallery'),
              onTap: () => Navigator.pop(ctx, 'gallery_video'),
            ),
            ListTile(
              leading:
                  const Icon(Icons.videocam_rounded, color: AppColors.primary),
              title: const Text('Video from camera'),
              onTap: () => Navigator.pop(ctx, 'camera_video'),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    XFile? picked;
    if (source == 'camera_photo') {
      picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
    } else if (source == 'gallery_photo') {
      picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
    } else if (source == 'camera_video') {
      picked = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
    } else {
      picked = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
    }
    if (picked == null || !mounted) return;

    final text = _controller.text.trim();
    _controller.clear();
    await _submitOutgoingMessage(
      text: text,
      file: File(picked.path),
      fileName: picked.name,
    );
  }

  Future<void> _submitOutgoingMessage({
    required String text,
    File? file,
    String? fileName,
  }) async {
    if (_selectedChildId == null) return;
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    if (text.trim().isEmpty && file == null) return;

    final pendingId =
        'local_${DateTime.now().microsecondsSinceEpoch}_${_localMessageCounter++}';
    final pending = _buildPendingMessage(
      pendingId: pendingId,
      user: user,
      text: text.trim(),
      file: file,
      fileName: fileName,
    );

    setState(() {
      _pendingMessages = [..._pendingMessages, pending];
    });
    _scrollToBottom();

    try {
      final sent = file == null
          ? await ApiClient.instance.sendMessage(_selectedChildId!, text.trim())
          : await ApiClient.instance.sendMessageWithFile(
              _selectedChildId!,
              text: text.trim(),
              file: file,
              onProgress: (progress) =>
                  _updatePendingProgress(pendingId, progress),
            );
      if (!mounted) return;
      setState(() {
        _pendingMessages = _pendingMessages
            .where((msg) => msg['local_id'] != pendingId)
            .toList();
        _messages = _upsertServerMessage(
          _messages,
          Map<String, dynamic>.from(sent),
        );
      });
      _scrollToBottom();
      unawaited(_loadConversation());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pendingMessages = _pendingMessages
            .where((msg) => msg['local_id'] != pendingId)
            .toList();
      });
      showAppSnackBar(
        context,
        file == null ? 'Failed to send: $e' : 'Failed to upload: $e',
        type: AppFeedbackType.error,
      );
    }
  }

  Map<String, dynamic> _buildPendingMessage({
    required String pendingId,
    required SessionUser user,
    required String text,
    File? file,
    String? fileName,
  }) {
    return {
      'local_id': pendingId,
      'id': pendingId,
      'sender': user.id,
      'text': text,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'sender_name': user.displayName,
      'sender_avatar_url': user.avatarUrl,
      'is_read': false,
      'file_url': null,
      'file_name': fileName ?? _fallbackFileName(file),
      'local_file_path': file?.path,
      'is_local_pending': true,
      'upload_progress': file == null ? null : 0.02,
    };
  }

  String _fallbackFileName(File? file) {
    if (file == null) return '';
    final segments = file.path.split(Platform.pathSeparator);
    return segments.isEmpty ? file.path : segments.last;
  }

  void _updatePendingProgress(String pendingId, double progress) {
    if (!mounted) return;
    final normalized = progress.clamp(0.0, 1.0);
    final index = _pendingMessages
        .indexWhere((message) => message['local_id'] == pendingId);
    if (index < 0) return;
    final current =
        (_pendingMessages[index]['upload_progress'] as num?)?.toDouble() ?? 0;
    if ((normalized - current).abs() < 0.04 && normalized < 0.98) {
      return;
    }

    setState(() {
      final updated = List<Map<String, dynamic>>.from(_pendingMessages);
      updated[index] = {
        ...updated[index],
        'upload_progress': normalized,
      };
      _pendingMessages = updated;
    });
  }

  List<Map<String, dynamic>> _upsertServerMessage(
    List<Map<String, dynamic>> existing,
    Map<String, dynamic> incoming,
  ) {
    final incomingId = incoming['id'];
    final filtered = existing.where((msg) => msg['id'] != incomingId).toList();
    filtered.add(incoming);
    filtered.sort((a, b) {
      final left = DateTime.tryParse(a['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final right = DateTime.tryParse(b['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return left.compareTo(right);
    });
    return filtered;
  }

  Future<void> _completeTask(int taskId) async {
    if (_selectedChildId == null) return;
    try {
      await ApiClient.instance.completeTask(_selectedChildId!, taskId);
      await _loadAll();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Error: $e',
          type: AppFeedbackType.error,
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
        showAppSnackBar(
          context,
          'Error: $e',
          type: AppFeedbackType.error,
        );
      }
    }
  }

  Future<void> _handleAddTask() async {
    final hasReward = _rewards.any((reward) => reward['claimed'] != true);
    if (hasReward) {
      _showAddTaskDialog();
      return;
    }

    final ru = _isRussian;
    final shouldCreateReward = await showAppConfirmDialog(
      context: context,
      title: ru ? 'Сначала создайте награду' : 'Create a reward first',
      message: ru
          ? 'Перед созданием задания нужно добавить хотя бы одну награду для ребёнка.'
          : 'Before creating a task, add at least one reward for this child.',
      confirmLabel: ru ? 'Создать награду' : 'Create reward',
      cancelLabel: S.of(context).cancel,
      type: AppFeedbackType.warning,
    );

    if (shouldCreateReward == true && mounted) {
      _showAddRewardDialog();
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
                  await _loadConversation();
                } catch (e) {
                  if (mounted) {
                    showAppSnackBar(
                      context,
                      'Error: $e',
                      type: AppFeedbackType.error,
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
                    showAppSnackBar(
                      context,
                      'Error: $e',
                      type: AppFeedbackType.error,
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
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    ChatVisibilityService.instance.clear(this);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _updatePollingState();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    _updatePollingState();
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
                      : RefreshIndicator(
                          onRefresh: _loadAll,
                          child: _buildChatList(user, isParent),
                        ),
            ),

            // Composer
            _ChatComposer(
              controller: _controller,
              onSend: _send,
              onAttach: _pickAndSendFile,
              isParent: isParent,
              onAddTask: _handleAddTask,
              onAddReward: _showAddRewardDialog,
              sendingCount: _pendingMessages.length,
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

    for (final msg in _pendingMessages) {
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
        children: const [
          Center(
            child: Text(
              'No messages yet. Say hello!',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      );
    }

    // Group by date
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
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
            text: (msg['text'] as String?) ?? '',
            time: _formatTime(msg['created_at'] as String),
            isMine: isMine,
            senderName: (msg['sender_name'] as String?) ?? '',
            senderAvatarUrl: msg['sender_avatar_url'] as String?,
            read: msg['is_read'] as bool? ?? false,
            fileUrl: msg['file_url'] as String?,
            fileName: msg['file_name'] as String?,
            localFilePath: msg['local_file_path'] as String?,
            pending: msg['is_local_pending'] as bool? ?? false,
            uploadProgress: (msg['upload_progress'] as num?)?.toDouble(),
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

  bool get _isRussian => Localizations.localeOf(context).languageCode == 'ru';
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
                  color: Colors.white.withValues(alpha: 0.2),
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
              backgroundColor: Colors.white.withValues(alpha: 0.2),
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
    required this.senderAvatarUrl,
    required this.read,
    this.fileUrl,
    this.fileName,
    this.localFilePath,
    this.pending = false,
    this.uploadProgress,
  });
  final String text;
  final String time;
  final bool isMine;
  final String senderName;
  final String? senderAvatarUrl;
  final bool read;
  final String? fileUrl;
  final String? fileName;
  final String? localFilePath;
  final bool pending;
  final double? uploadProgress;

  @override
  Widget build(BuildContext context) {
    const myBubbleColor = Color(0xFFF2ECE1);
    const otherBubbleColor = Colors.white;
    final bubbleColor = isMine ? myBubbleColor : otherBubbleColor;
    final hasImage = _isImageFile(fileName);
    final hasVideo = _isVideoFile(fileName);

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
              image: senderAvatarUrl != null
                  ? NetworkImage(senderAvatarUrl!)
                  : null,
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
                  constraints: const BoxConstraints(maxWidth: 260),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMine ? 16 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isMine
                          ? const Color(0xFFE0D5BF)
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((fileUrl != null || localFilePath != null) &&
                          hasImage)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: localFilePath != null
                                ? Image.file(
                                    File(localFilePath!),
                                    width: 220,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                    errorBuilder: (_, __, ___) =>
                                        _fileAttachment(
                                      fileName ?? 'file',
                                      isMine,
                                      isVideo: false,
                                      pending: pending,
                                      progress: uploadProgress,
                                    ),
                                  )
                                : Image.network(
                                    fileUrl!,
                                    width: 220,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                    gaplessPlayback: true,
                                    errorBuilder: (_, __, ___) =>
                                        _fileAttachment(
                                      fileName ?? 'file',
                                      isMine,
                                      isVideo: false,
                                      pending: pending,
                                      progress: uploadProgress,
                                    ),
                                  ),
                          ),
                        )
                      else if (fileUrl != null || localFilePath != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _fileAttachment(
                            fileName ?? 'file',
                            isMine,
                            isVideo: hasVideo,
                            pending: pending,
                            progress: uploadProgress,
                          ),
                        ),
                      if (text.isNotEmpty)
                        Text(
                          text,
                          style: const TextStyle(
                            color: AppColors.textPrimaryLight,
                            fontSize: 14,
                          ),
                        ),
                      if (pending) ...[
                        if (text.isNotEmpty ||
                            fileUrl != null ||
                            localFilePath != null)
                          const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: uploadProgress == null ||
                                        uploadProgress! <= 0 ||
                                        uploadProgress! >= 1
                                    ? null
                                    : uploadProgress,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              uploadProgress != null
                                  ? 'Uploading ${(uploadProgress! * 100).round()}%'
                                  : 'Sending...',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        pending
                            ? Icons.schedule_rounded
                            : Icons.done_all_rounded,
                        size: 14,
                        color: pending
                            ? AppColors.textSecondaryLight
                            : read
                                ? AppColors.success
                                : AppColors.textMuted,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 8),
            AvatarCircle(
              initials:
                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
              color: AppColors.primary,
              size: 28,
              image: senderAvatarUrl != null
                  ? NetworkImage(senderAvatarUrl!)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  static bool _isImageFile(String? name) {
    if (name == null) return false;
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }

  static bool _isVideoFile(String? name) {
    if (name == null) return false;
    final lower = name.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm');
  }

  static Widget _fileAttachment(
    String name,
    bool isMine, {
    required bool isVideo,
    required bool pending,
    double? progress,
  }) {
    final iconColor = isVideo ? AppColors.danger : AppColors.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMine ? const Color(0xFFE8DFD1) : AppColors.chipGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVideo
                ? Icons.play_circle_fill_rounded
                : Icons.insert_drive_file_rounded,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  isVideo
                      ? pending
                          ? 'Video is uploading'
                          : 'Video attached'
                      : pending
                          ? 'File is uploading'
                          : 'File attached',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                if (pending && progress != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress <= 0 || progress >= 1 ? null : progress,
                      minHeight: 4,
                      backgroundColor: AppColors.dividerLight,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  ),
                ],
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
              color: Colors.black.withValues(alpha: 0.05),
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
                      color: statusColor.withValues(alpha: 0.12),
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
    required this.onAttach,
    required this.isParent,
    required this.onAddTask,
    required this.onAddReward,
    required this.sendingCount,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final bool isParent;
  final VoidCallback onAddTask;
  final VoidCallback onAddReward;
  final int sendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.dividerLight)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: sendingCount == 0
                ? const SizedBox.shrink()
                : Padding(
                    key: ValueKey<int>(sendingCount),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sendingCount == 1
                              ? 'Sending item...'
                              : 'Sending $sendingCount items...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Row(
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
                          Icon(Icons.task_alt,
                              color: AppColors.primary, size: 20),
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
              IconButton(
                icon: const Icon(Icons.attach_file_rounded,
                    color: AppColors.textSecondaryLight, size: 24),
                onPressed: onAttach,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Send a message, photo or video...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              Material(
                color: AppColors.textPrimaryLight,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
