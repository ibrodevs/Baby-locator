import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
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
  int? _startingAroundChildId;

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

  void _selectChild(int? childId) {
    ref.read(selectedChildIdProvider.notifier).state = childId;
  }

  Future<void> _triggerLoud(ChildLocation child) async {
    if (_sendingLoud) return;
    final childId = child.childId;
    if (childId == null) return;
    setState(() => _sendingLoud = true);
    try {
      await ApiClient.instance.triggerLoud(childId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loud signal sent to ${child.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send loud signal: $e')),
      );
    } finally {
      if (mounted) setState(() => _sendingLoud = false);
    }
  }

  Future<void> _openAround(ChildLocation child) async {
    final childId = child.childId;
    if (childId == null || _startingAroundChildId == childId) return;
    setState(() => _startingAroundChildId = childId);
    String? sessionToken;
    try {
      final command = await ApiClient.instance.startAround(childId);
      sessionToken =
          ((command['payload'] as Map?)?['session_token'] as String?) ?? '';
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AroundListenSheet(
          childId: childId,
          childName: child.name,
          sessionToken: sessionToken ?? '',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start Around: $e')),
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
          Expanded(
            child: Stack(
              children: [
                // Map
                Positioned.fill(
                  child: hasChildren && mapChild != null
                      ? AdaptiveMap(
                          latitude: mapChild.lat,
                          longitude: mapChild.lng,
                          children: children,
                          selectedIndex:
                              selectedIndex >= 0 ? selectedIndex : null,
                          onChildTapped: (idx) {
                            _selectChild(children[idx].childId);
                          },
                        )
                      : _EmptyMapPlaceholder(
                          hasChildren: hasChildren,
                          error: _err,
                          onManage: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ChildrenListScreen()),
                            );
                            _fetchAll();
                          },
                        ),
                ),
                // Action buttons (LOUD / AROUND)
                if (hasChildren)
                  Positioned(
                    right: 16,
                    top: 20,
                    child: Column(
                      children: [
                        _MapActionButton(
                          icon: Icons.volume_up_rounded,
                          label: t.loud,
                          color: AppColors.primary,
                          onTap: selected == null ||
                                  selected.childId == null ||
                                  _sendingLoud
                              ? null
                              : () => _triggerLoud(selected),
                        ),
                        const SizedBox(height: 12),
                        _MapActionButton(
                          icon: Icons.radar_rounded,
                          label: t.around,
                          color: AppColors.success,
                          onTap: selected == null || selected.childId == null
                              ? null
                              : () => _openAround(selected),
                        ),
                      ],
                    ),
                  ),
                // Bottom child info card
                if (hasChildren)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: selected != null
                        ? _ChildInfoCard(
                            loc: selected,
                            onMessage: () => _openChat(context, selected),
                            onHistory: () => _openActivity(context, selected),
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
  Timer? _pollTimer;
  int? _lastClipId;
  bool _loading = true;
  String? _error;
  String _status = 'Waiting for audio from child phone...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    await _pollLatestClip();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _pollLatestClip(),
    );
  }

  Future<void> _pollLatestClip() async {
    try {
      final clip = await ApiClient.instance.latestAroundAudio(
        widget.childId,
        sessionToken: widget.sessionToken,
        afterId: _lastClipId,
      );
      if (!mounted) return;
      if (clip == null) {
        setState(() {
          _loading = false;
          _error = null;
        });
        return;
      }
      final clipMap = Map<String, dynamic>.from(clip);
      final clipId = clipMap['id'] as int?;
      final url = clipMap['audio_url'] as String? ?? '';
      if (clipId == null || url.isEmpty) return;
      _lastClipId = clipId;

      // Download via authenticated API endpoint to avoid 404 on media
      // files and iOS streaming errors with remote M4A URLs.
      final bytes = await ApiClient.instance.downloadAroundAudio(clipId);
      final dir = await getTemporaryDirectory();
      final localFile = File('${dir.path}/around_clip_$clipId.m4a');
      await localFile.writeAsBytes(bytes, flush: true);

      await _player.stop();
      await _player.play(DeviceFileSource(localFile.path));
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
        _status = 'Listening to ${widget.childName} surroundings';
      });

      // Clean up the file after playback completes.
      _player.onPlayerComplete.first.then((_) async {
        if (await localFile.exists()) await localFile.delete();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.hearing_rounded, color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Around: ${widget.childName}',
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
              _status,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
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
            const Text(
              'The sheet stays open while the child phone keeps sending short microphone clips.',
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
                      loc.address.isEmpty
                          ? '${loc.lat.toStringAsFixed(5)}, ${loc.lng.toStringAsFixed(5)}'
                          : loc.address,
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
                    t.messageChild(loc.name),
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
