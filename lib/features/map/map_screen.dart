import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/services/local_avatar_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/brand_header.dart';
import '../activity/activity_screen.dart';
import '../auth/parent_setup_flow_screen.dart';
import '../chat/chat_screen.dart';
import '../parent/children_list_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_menu_feature_screens.dart';
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
  bool _followSelectedChild = false;
  int? _loadingInviteChildId;
  final Map<int, String> _inviteCodeOverrides = {};
  final Map<int, DateTime?> _inviteExpiryOverrides = {};

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
      final results = await Future.wait<dynamic>([
        ApiClient.instance.listChildren(),
        ApiClient.instance.allChildrenLocations(),
      ]);
      if (!mounted) return;
      final allChildren = (results[0] as List<dynamic>);
      final locationData = (results[1] as List<dynamic>);
      ref.read(parentChildrenProvider.notifier).setFromList(allChildren);
      ref.read(allChildrenLocationsProvider.notifier).setFromApi(locationData);
      final children = ref.read(parentChildrenProvider);
      final selectedChildId = ref.read(selectedChildIdProvider);
      final hasSelectedChild = selectedChildId != null &&
          children.any((child) => child['id'] == selectedChildId);
      if (children.isEmpty) {
        ref.read(selectedChildIdProvider.notifier).state = null;
      } else if (!hasSelectedChild && selectedChildId != null) {
        ref.read(selectedChildIdProvider.notifier).state = null;
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

  void _clearSelectedChild() {
    _selectChild(null, enableFollow: false);
  }

  Future<void> _openAddChildFlow() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ParentSetupFlowScreen(
          onFinished: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (result == true) {
      await _fetchAll();
    }
  }

  Future<void> _ensureInviteCode(_MapChildEntry child) async {
    if (child.hasJoined || _loadingInviteChildId == child.id) return;
    final existingCode = _inviteCodeOverrides[child.id] ?? child.inviteCode;
    if (existingCode != null && existingCode.trim().isNotEmpty) return;

    setState(() => _loadingInviteChildId = child.id);
    try {
      var invite = await ApiClient.instance.getInviteCode(childId: child.id);
      var code = invite['code'] as String?;
      if (code == null || code.trim().isEmpty) {
        invite = await ApiClient.instance.generateInviteCode(childId: child.id);
        code = invite['code'] as String?;
      }

      if (!mounted) return;
      setState(() {
        if (code != null && code.trim().isNotEmpty) {
          _inviteCodeOverrides[child.id] = code;
        }
        _inviteExpiryOverrides[child.id] =
            DateTime.tryParse(invite['expires_at'] as String? ?? '');
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Не удалось получить код приглашения: $e',
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted && _loadingInviteChildId == child.id) {
        setState(() => _loadingInviteChildId = null);
      }
    }
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    showAppSnackBar(
      context,
      S.of(context).codeCopied,
      type: AppFeedbackType.success,
    );
  }

  void _shareInviteCode(String code) {
    SharePlus.instance
        .share(ShareParams(text: S.of(context).inviteShareText(code)));
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
    setState(() => _startingAroundChildId = childId);
    try {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MenuAroundSoundScreen(
            childId: childId,
            childName: child.name,
            avatarUrl: child.avatarUrl,
            autoStart: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        S.of(context).failedGeneric(e.toString()),
        type: AppFeedbackType.error,
      );
    } finally {
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
    final allChildren = ref.watch(parentChildrenProvider);
    final locations = ref.watch(allChildrenLocationsProvider);
    final selectedChildId = ref.watch(selectedChildIdProvider);
    final carouselChildren = _buildChildEntries(allChildren, locations);
    final hasChildren = carouselChildren.isNotEmpty;
    _MapChildEntry? selectedEntry;
    if (selectedChildId != null) {
      for (final child in carouselChildren) {
        if (child.id == selectedChildId) {
          selectedEntry = child;
          break;
        }
      }
    }
    final selectedLocation = selectedEntry?.location;
    final selectedIndex = selectedLocation == null
        ? -1
        : locations
            .indexWhere((child) => child.childId == selectedLocation.childId);
    final mapCenter = _mapCenterFor(locations, selectedChildId);
    final childInfo =
        _buildSelectedChildInfo(context, selectedEntry, selectedLocation);

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
              image: avatarImageProvider(session.user?.avatarUrl),
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
                            child: hasChildren && mapCenter != null
                                ? AdaptiveMap(
                                    latitude: mapCenter.$1,
                                    longitude: mapCenter.$2,
                                    children: locations,
                                    selectedIndex: selectedIndex >= 0
                                        ? selectedIndex
                                        : null,
                                    followTarget: selectedLocation != null &&
                                        _followSelectedChild,
                                    onChildTapped: (idx) {
                                      _selectChild(locations[idx].childId);
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
                          if (selectedEntry != null)
                            Positioned(
                              left: 16,
                              top: 20,
                              child: Column(
                                children: [
                                  _MapIconButton(
                                    icon: Icons.arrow_back_rounded,
                                    color: AppColors.textPrimaryLight,
                                    onTap: _clearSelectedChild,
                                  ),
                                  if (selectedLocation != null) ...[
                                    const SizedBox(height: 12),
                                    _MapIconButton(
                                      icon: _followSelectedChild
                                          ? Icons.gps_fixed_rounded
                                          : Icons.gps_not_fixed_rounded,
                                      color: _followSelectedChild
                                          ? AppColors.primary
                                          : AppColors.textSecondaryLight,
                                      onTap: _recenterOnSelectedChild,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          if (selectedLocation != null)
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
                                    onTap: selectedLocation.childId == null ||
                                            _sendingLoud
                                        ? null
                                        : _loudActive
                                            ? _stopLoud
                                            : () =>
                                                _triggerLoud(selectedLocation),
                                  ),
                                  const SizedBox(height: 12),
                                  _MapActionButton(
                                    icon: Icons.radar_rounded,
                                    label: t.around,
                                    color: AppColors.success,
                                    onTap: selectedLocation.childId == null
                                        ? null
                                        : () => _openAround(selectedLocation),
                                  ),
                                ],
                              ),
                            ),
                          if (hasChildren)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: _MapBottomOverlay(
                                children: carouselChildren,
                                selectedChildId: selectedChildId,
                                onSelect: (idx) {
                                  final child = carouselChildren[idx];
                                  _selectChild(
                                    child.id,
                                    enableFollow: child.location != null,
                                  );
                                  unawaited(_ensureInviteCode(child));
                                },
                                onAddChild: _openAddChildFlow,
                                childInfo: childInfo,
                              ),
                            ),
                          if (!hasChildren)
                            Positioned(
                              right: 16,
                              bottom: 20,
                              child: _AddChildButton(
                                onTap: _openAddChildFlow,
                                tooltip: t.addChild,
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

  List<_MapChildEntry> _buildChildEntries(
    List<Map<String, dynamic>> allChildren,
    List<ChildLocation> locations,
  ) {
    final locationById = <int, ChildLocation>{
      for (final location in locations)
        if (location.childId != null) location.childId!: location,
    };

    return allChildren.where((child) => child['id'] is int).map((child) {
      final id = child['id'] as int;
      final location = locationById[id];
      return _MapChildEntry.fromMap(
        child,
        location: location,
        inviteCodeOverride: _inviteCodeOverrides[id],
        inviteExpiryOverride: _inviteExpiryOverrides[id],
      );
    }).toList(growable: false);
  }

  Widget? _buildSelectedChildInfo(
    BuildContext context,
    _MapChildEntry? selectedEntry,
    ChildLocation? selectedLocation,
  ) {
    if (selectedEntry == null) return null;
    if (selectedLocation != null) {
      return _ChildInfoCard(
        loc: selectedLocation,
        onMessage: () => _openChat(context, selectedLocation),
        onHistory: () => _openActivity(context, selectedLocation),
      );
    }
    if (!selectedEntry.hasJoined) {
      return _ChildInviteInfoCard(
        child: selectedEntry,
        loadingCode: _loadingInviteChildId == selectedEntry.id,
        onCopy: selectedEntry.inviteCode == null
            ? null
            : () => _copyInviteCode(selectedEntry.inviteCode!),
        onShare: selectedEntry.inviteCode == null
            ? null
            : () => _shareInviteCode(selectedEntry.inviteCode!),
      );
    }
    return _ChildWaitingInfoCard(child: selectedEntry);
  }

  (double, double)? _mapCenterFor(
    List<ChildLocation> children,
    int? selectedChildId,
  ) {
    if (children.isEmpty) return null;

    for (final child in children) {
      if (child.childId != null && child.childId == selectedChildId) {
        return (child.lat, child.lng);
      }
    }

    double latSum = 0;
    double lngSum = 0;
    for (final child in children) {
      latSum += child.lat;
      lngSum += child.lng;
    }
    return (latSum / children.length, lngSum / children.length);
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

class _MapBottomOverlay extends StatelessWidget {
  const _MapBottomOverlay({
    required this.children,
    required this.selectedChildId,
    required this.onSelect,
    required this.onAddChild,
    required this.childInfo,
  });

  final List<_MapChildEntry> children;
  final int? selectedChildId;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddChild;
  final Widget? childInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            _ChildAvatarRail(
              children: children,
              selectedChildId: selectedChildId,
              onSelect: onSelect,
            ),
            Positioned(
              right: 16,
              child: _AddChildButton(
                onTap: onAddChild,
                tooltip: S.of(context).addChild,
              ),
            ),
          ],
        ),
        if (childInfo != null) childInfo!,
      ],
    );
  }
}

class _ChildAvatarRail extends StatelessWidget {
  const _ChildAvatarRail({
    required this.children,
    required this.selectedChildId,
    required this.onSelect,
  });

  final List<_MapChildEntry> children;
  final int? selectedChildId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 96, 16),
        itemCount: children.length,
        itemBuilder: (_, i) {
          final c = children[i];
          final isSelected = c.id == selectedChildId;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 72,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    scale: isSelected ? 1.0 : 0.92,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.92),
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AvatarCircle(
                            initials: c.name.isNotEmpty
                                ? c.name[0].toUpperCase()
                                : '?',
                            size: isSelected ? 58 : 52,
                            color: AppColors.primary,
                            image: avatarImageProvider(c.avatarUrl),
                          ),
                          Positioned(
                            right: -1,
                            bottom: -1,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.statusColor,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _MapChildEntry {
  const _MapChildEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.hasJoined,
    required this.inviteCode,
    required this.inviteExpiresAt,
    required this.location,
  });

  final int id;
  final String name;
  final String? avatarUrl;
  final bool hasJoined;
  final String? inviteCode;
  final DateTime? inviteExpiresAt;
  final ChildLocation? location;

  Color get statusColor {
    if (!hasJoined) return AppColors.warning;
    if (location == null) return AppColors.textMuted;
    return location!.active ? AppColors.success : AppColors.danger;
  }

  factory _MapChildEntry.fromMap(
    Map<String, dynamic> child, {
    required ChildLocation? location,
    String? inviteCodeOverride,
    DateTime? inviteExpiryOverride,
  }) {
    final displayName = child['display_name'] as String?;
    final username = child['username'] as String? ?? '';
    final name = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : username;
    final inviteCode =
        inviteCodeOverride ?? child['active_invite_code'] as String?;
    final expiresAt = inviteExpiryOverride ??
        DateTime.tryParse(child['invite_expires_at'] as String? ?? '');
    final hasJoined =
        (child['has_joined'] as bool? ?? false) || location != null;
    return _MapChildEntry(
      id: child['id'] as int,
      name: name.isNotEmpty ? name : 'Ребёнок',
      avatarUrl: child['avatar_url'] as String?,
      hasJoined: hasJoined,
      inviteCode: inviteCode,
      inviteExpiresAt: expiresAt,
      location: location,
    );
  }
}

class _ChildInviteInfoCard extends StatelessWidget {
  const _ChildInviteInfoCard({
    required this.child,
    required this.loadingCode,
    this.onCopy,
    this.onShare,
  });

  final _MapChildEntry child;
  final bool loadingCode;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

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
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AvatarCircle(
                initials:
                    child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                size: 48,
                color: AppColors.primary,
                image: avatarImageProvider(child.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Ещё не вошёл',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Ребёнок ещё не зашёл в приложение по коду. Попросите его открыть приложение и ввести код ниже.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.inviteCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                if (loadingCode)
                  const SizedBox(
                    height: 28,
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5)),
                  )
                else
                  SelectableText(
                    child.inviteCode ?? '------',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                      letterSpacing: 3,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  t.inviteCodeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: loadingCode ? null : onCopy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Скопировать код',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: loadingCode ? null : onShare,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimaryLight,
                    side: const BorderSide(color: AppColors.dividerLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    t.shareCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChildWaitingInfoCard extends StatelessWidget {
  const _ChildWaitingInfoCard({required this.child});

  final _MapChildEntry child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AvatarCircle(
                initials:
                    child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                size: 48,
                color: AppColors.primary,
                image: avatarImageProvider(child.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.chipGrey,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Ребёнок уже вошёл в приложение, но пока ещё не поделился геолокацией.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddChildButton extends StatelessWidget {
  const _AddChildButton({
    required this.onTap,
    required this.tooltip,
  });

  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: Colors.black38,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Tooltip(
            message: tooltip,
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
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
                image: avatarImageProvider(loc.avatarUrl),
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
