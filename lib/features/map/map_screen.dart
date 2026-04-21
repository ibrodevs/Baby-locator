import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/child_selector_chips.dart';
import '../activity/activity_screen.dart';
import '../chat/chat_screen.dart';
import '../parent/children_list_screen.dart';
import '../settings/settings_screen.dart';
import 'adaptive_map.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Timer? _poll;
  String? _err;
  bool _sendingLoud = false;
  bool _loudActive = false;
  int? _loudChildId;
  int? _startingAroundChildId;
  bool _followSelectedChild = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    try {
      await _fetchAll();
      _startPolling();
    } catch (e) {
      if (mounted) setState(() => _err = e.toString());
    }
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _fetchAll());
  }

  Future<void> _fetchAll() async {
    try {
      final data = await ApiClient.instance.allChildrenLocations();
      if (!mounted) return;
      ref.read(parentChildrenProvider.notifier).syncFromLocationEntries(data);
      ref.read(allChildrenLocationsProvider.notifier).setFromApi(data);
      final children = ref.read(allChildrenLocationsProvider);
      final selectedChildId = ref.read(selectedChildIdProvider);
      final hasSelectedChild = selectedChildId != null &&
          children.any((child) => child.childId == selectedChildId);
      if (children.isEmpty) {
        ref.read(selectedChildIdProvider.notifier).state = null;
      } else if (!hasSelectedChild) {
        ref.read(selectedChildIdProvider.notifier).state =
            children.first.childId;
      }
      setState(() => _err = null);
    } catch (e) {
      if (mounted) setState(() => _err = e.toString());
    }
  }

  void _selectChild(int? childId, {bool enableFollow = true}) {
    ref.read(selectedChildIdProvider.notifier).state = childId;
    if (!mounted) return;
    setState(() => _followSelectedChild = enableFollow);
  }

  void _disableFollowMode() {
    if (!_followSelectedChild || !mounted) return;
    setState(() => _followSelectedChild = false);
  }

  void _recenterOnSelectedChild() {
    final selectedChildId = ref.read(selectedChildIdProvider);
    if (selectedChildId == null) return;
    _selectChild(selectedChildId);
  }

  Future<void> _triggerLoud(ChildLocation child) async {
    if (_sendingLoud) return;
    final childId = child.childId;
    if (childId == null) return;
    setState(() => _sendingLoud = true);
    try {
      await ApiClient.instance.triggerLoud(childId);
      if (!mounted) return;
      setState(() {
        _loudActive = true;
        _loudChildId = childId;
      });
      showAppSnackBar(
        context,
        S.of(context).loudSignalSent(child.name),
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        S.of(context).failedGeneric(e.toString()),
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _sendingLoud = false);
    }
  }

  Future<void> _stopLoud() async {
    final childId = _loudChildId;
    if (childId == null) return;
    try {
      await ApiClient.instance.stopLoud(childId);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _loudActive = false;
        _loudChildId = null;
      });
    }
  }

  Future<void> _openAround(ChildLocation child) async {
    final childId = child.childId;
    if (childId == null || _startingAroundChildId == childId) return;
    final t = S.of(context);
    setState(() => _startingAroundChildId = childId);
    String? sessionToken;
    try {
      final command = await ApiClient.instance.startAround(childId);
      final liveSessionToken =
          ((command['payload'] as Map?)?['session_token'] as String?) ?? '';
      if (liveSessionToken.isEmpty) {
        throw Exception(t.couldNotCreateLiveSession);
      }
      sessionToken = liveSessionToken;
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AroundListenSheet(
          childId: childId,
          childName: child.name,
          sessionToken: liveSessionToken,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        t.failedGeneric(e.toString()),
        type: AppFeedbackType.error,
      );
    } finally {
      if (sessionToken != null && sessionToken.isNotEmpty) {
        try {
          await ApiClient.instance.stopAround(
            childId,
            sessionToken: sessionToken,
          );
        } catch (_) {}
      }
      if (mounted) setState(() => _startingAroundChildId = null);
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final session = ref.watch(sessionProvider);
    final children = ref.watch(allChildrenLocationsProvider);
    final selectedChildId = ref.watch(selectedChildIdProvider);
    final selectorChildren = children
        .where((child) => child.childId != null)
        .map(
          (child) => <String, dynamic>{
            'id': child.childId,
            'display_name': child.name,
          },
        )
        .toList();
    final hasChildren = children.isNotEmpty;
    final selectedIndex =
        children.indexWhere((child) => child.childId == selectedChildId);
    final selected = selectedIndex >= 0
        ? children[selectedIndex]
        : (hasChildren ? children.first : null);
    final mapChild = selected;

    return SafeArea(
      child: Column(
        children: [
          BrandHeader(
            leading: AvatarCircle(
              initials: (session.user?.displayName.isNotEmpty ?? false)
                  ? session.user!.displayName[0].toUpperCase()
                  : 'P',
              color: AppColors.primary,
              size: 36,
              image: session.user?.avatarUrl != null
                  ? NetworkImage(session.user!.avatarUrl!)
                  : null,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.people_alt_outlined,
                      color: AppColors.textPrimaryLight),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ChildrenListScreen()));
                    _fetchAll();
                  },
                ),
                GearButton(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          ChildSelectorChips(
            children: selectorChildren,
            selectedChildId: selectedChildId,
            onSelected: (id) => _selectChild(id),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => RefreshIndicator(
                onRefresh: _fetchAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: hasChildren && mapChild != null
                                ? AdaptiveMap(
                                    latitude: mapChild.lat,
                                    longitude: mapChild.lng,
                                    children: children,
                                    selectedIndex: selectedIndex >= 0
                                        ? selectedIndex
                                        : null,
                                    followTarget: _followSelectedChild,
                                    onChildTapped: (idx) {
                                      _selectChild(children[idx].childId);
                                    },
                                    onUserCameraMoveStarted: _disableFollowMode,
                                  )
                                : _EmptyMapPlaceholder(
                                    hasChildren: hasChildren,
                                    error: _err,
                                    onManage: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ChildrenListScreen(),
                                        ),
                                      );
                                      _fetchAll();
                                    },
                                  ),
                          ),
                          if (hasChildren)
                            Positioned(
                              left: 16,
                              top: 20,
                              child: _MapIconButton(
                                icon: _followSelectedChild
                                    ? Icons.gps_fixed_rounded
                                    : Icons.gps_not_fixed_rounded,
                                color: _followSelectedChild
                                    ? AppColors.primary
                                    : AppColors.textSecondaryLight,
                                onTap: selected == null
                                    ? null
                                    : _recenterOnSelectedChild,
                              ),
                            ),
                          if (hasChildren)
                            Positioned(
                              right: 16,
                              top: 20,
                              child: Column(
                                children: [
                                  _MapActionButton(
                                    icon: _loudActive
                                        ? Icons.stop_rounded
                                        : Icons.volume_up_rounded,
                                    label: _loudActive ? t.stopAction : t.loud,
                                    color: _loudActive
                                        ? AppColors.danger
                                        : AppColors.primary,
                                    onTap: selected == null ||
                                            selected.childId == null ||
                                            _sendingLoud
                                        ? null
                                        : _loudActive
                                            ? _stopLoud
                                            : () => _triggerLoud(selected),
                                  ),
                                  const SizedBox(height: 12),
                                  _MapActionButton(
                                    icon: Icons.radar_rounded,
                                    label: t.around,
                                    color: AppColors.success,
                                    onTap: selected == null ||
                                            selected.childId == null
                                        ? null
                                        : () => _openAround(selected),
                                  ),
                                ],
                              ),
                            ),
                          if (hasChildren)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: selected != null
                                  ? _ChildInfoCard(
                                      loc: selected,
                                      onMessage: () =>
                                          _openChat(context, selected),
                                      onHistory: () =>
                                          _openActivity(context, selected),
                                    )
                                  : _ChildCarousel(
                                      children: children,
                                      onSelect: (idx) =>
                                          _selectChild(children[idx].childId),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, ChildLocation loc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(initialSelectedChildId: loc.childId),
      ),
    );
  }

  void _openActivity(BuildContext context, ChildLocation loc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityScreen(initialSelectedChildId: loc.childId),
      ),
    );
  }
}

class _EmptyMapPlaceholder extends StatelessWidget {
  const _EmptyMapPlaceholder({
    required this.hasChildren,
    this.error,
    required this.onManage,
  });
  final bool hasChildren;
  final String? error;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      color: AppColors.chipGrey,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_searching,
                size: 48, color: AppColors.textSecondaryLight),
            const SizedBox(height: 12),
            Text(
              hasChildren ? t.waitingForLocation : t.addChildToTrack,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondaryLight),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.danger)),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onManage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.people),
              label: Text(t.manageChildren),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCarousel extends StatelessWidget {
  const _ChildCarousel({required this.children, required this.onSelect});
  final List<ChildLocation> children;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white70, Colors.white],
          stops: [0.0, 0.3, 1.0],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        itemCount: children.length,
        itemBuilder: (_, i) {
          final c = children[i];
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AvatarCircle(
                        initials:
                            c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        size: 32,
                        color: AppColors.primary,
                        image: c.avatarUrl != null
                            ? NetworkImage(c.avatarUrl!)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        c.active ? Icons.check_circle : Icons.error,
                        size: 12,
                        color: c.active ? AppColors.success : AppColors.danger,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        c.active ? t.active : t.inactive,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              c.active ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        c.charging ? Icons.bolt_rounded : Icons.power_outlined,
                        size: 12,
                        color: c.charging
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.battery_full,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 2),
                      Text('${c.battery}%',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: onTap == null ? 0.72 : 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black38,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(
                icon,
                color: onTap == null ? AppColors.textMuted : color,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: onTap == null ? AppColors.textMuted : color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: onTap == null ? 0.72 : 1),
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black38,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: onTap == null ? AppColors.textMuted : color),
      ),
    );
  }
}

class _ChargingStatusRow extends StatelessWidget {
  const _ChargingStatusRow({required this.charging});

  final bool charging;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final color = charging ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            charging ? Icons.bolt_rounded : Icons.power_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            charging ? t.deviceIsCharging : t.deviceIsNotCharging,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AroundListenSheet extends StatefulWidget {
  const _AroundListenSheet({
    required this.childId,
    required this.childName,
    required this.sessionToken,
  });

  final int childId;
  final String childName;
  final String sessionToken;

  @override
  State<_AroundListenSheet> createState() => _AroundListenSheetState();
}

class _AroundListenSheetState extends State<_AroundListenSheet> {
  final AudioPlayer _player = AudioPlayer();
  final List<File> _clipQueue = [];
  Timer? _pollTimer;
  Timer? _startupWatchdog;
  int? _lastClipId;
  bool _loading = true;
  bool _pollInFlight = false;
  bool _isPlaying = false;
  String? _error;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) => unawaited(_playNext()));
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    await _pollLatestClip();
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 350),
      (_) => unawaited(_pollLatestClip()),
    );
    _startupWatchdog = Timer(const Duration(seconds: 3), () {
      if (!mounted || !_loading) return;
      setState(() {
        _status = S.of(context).waitingForFirstAudioClip;
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _startupWatchdog?.cancel();
    unawaited(_player.dispose());
    for (final file in _clipQueue) {
      unawaited(_safeDelete(file));
    }
    super.dispose();
  }

  Future<void> _pollLatestClip() async {
    if (_pollInFlight) return;
    _pollInFlight = true;
    try {
      final clip = await ApiClient.instance.latestAroundAudio(
        widget.childId,
        sessionToken: widget.sessionToken,
        afterId: _lastClipId,
      );
      if (!mounted) return;
      if (clip == null) {
        if (_loading) {
          setState(() => _error = null);
        }
        return;
      }

      final clipMap = Map<String, dynamic>.from(clip);
      final clipId = clipMap['id'] as int?;
      final audioUrl = clipMap['audio_url'] as String? ?? '';
      if (clipId == null || audioUrl.isEmpty) return;

      final bytes = await ApiClient.instance.downloadAroundAudio(clipId);
      final dir = await getTemporaryDirectory();
      final localFile = File('${dir.path}/around_clip_$clipId.m4a');
      await localFile.writeAsBytes(bytes, flush: true);

      _lastClipId = clipId;
      _clipQueue.add(localFile);

      if (!_isPlaying) {
        unawaited(_playNext());
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
        _status = S.of(context).listeningTo(widget.childName);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _status = S.of(context).errorLabel;
      });
    } finally {
      _pollInFlight = false;
    }
  }

  Future<void> _playNext() async {
    if (_clipQueue.isEmpty) {
      _isPlaying = false;
      return;
    }
    _isPlaying = true;
    final file = _clipQueue.removeAt(0);
    try {
      await _player.play(DeviceFileSource(file.path));
    } catch (_) {
      await _safeDelete(file);
      _isPlaying = false;
      if (_clipQueue.isNotEmpty) {
        unawaited(_playNext());
      }
      return;
    }

    Future<void>.delayed(const Duration(seconds: 3), () {
      unawaited(_safeDelete(file));
    });
  }

  Future<void> _safeDelete(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  !_loading && _error == null
                      ? Icons.hearing_rounded
                      : Icons.hearing_disabled_rounded,
                  color: (!_loading && _error == null)
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.listeningTo(widget.childName),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _status.isEmpty ? t.connectingToChildPhone : _status,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 14),
            if (_loading && _error == null)
              const LinearProgressIndicator(
                color: AppColors.success,
                backgroundColor: AppColors.chipGrey,
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              t.aroundAudioInfo,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildInfoCard extends StatelessWidget {
  const _ChildInfoCard({
    required this.loc,
    this.onMessage,
    this.onHistory,
  });
  final ChildLocation loc;
  final VoidCallback? onMessage;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final compactLabel = t
        .messageChild(loc.name)
        .replaceAll(loc.name, '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
    final actionLabel = compactLabel.isNotEmpty ? compactLabel : t.navChat;
    final addressLabel =
        loc.address.trim().isNotEmpty ? loc.address : t.resolvingAddress;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name + battery + close
          Row(
            children: [
              AvatarCircle(
                initials: loc.name.isNotEmpty ? loc.name[0].toUpperCase() : '?',
                size: 48,
                color: AppColors.primary,
                image:
                    loc.avatarUrl != null ? NetworkImage(loc.avatarUrl!) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.chipGrey,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _batteryIcon(loc.battery),
                      size: 14,
                      color: _batteryColor(loc.battery),
                    ),
                    const SizedBox(width: 4),
                    Text('${loc.battery}%',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ChargingStatusRow(charging: loc.charging),
          const SizedBox(height: 8),
          // Status row
          Row(
            children: [
              Icon(
                loc.active ? Icons.check_circle : Icons.error,
                size: 16,
                color: loc.active ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 6),
              Text(
                t.lastUpdated(_ago(context, loc.updatedAt)),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                loc.active ? t.statusActive : t.statusPaused,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: loc.active ? AppColors.success : AppColors.danger,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Current location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.currentLocation,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addressLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons: Message + History
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onHistory,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimaryLight,
                    side: const BorderSide(color: AppColors.dividerLight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    t.history,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _batteryIcon(int level) {
    if (level > 80) return Icons.battery_full;
    if (level > 50) return Icons.battery_5_bar;
    if (level > 20) return Icons.battery_3_bar;
    return Icons.battery_1_bar;
  }

  Color _batteryColor(int level) {
    if (level > 50) return AppColors.success;
    if (level > 20) return AppColors.warning;
    return AppColors.danger;
  }

  static String _ago(BuildContext context, DateTime t) {
    final tr = S.of(context);
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return tr.justNow;
    if (d.inMinutes < 60) return tr.minutesAgo(d.inMinutes);
    return tr.hoursAgo(d.inHours);
  }
}
