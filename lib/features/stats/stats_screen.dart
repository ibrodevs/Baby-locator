import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';
import 'package:intl/intl.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/child_selector_chips.dart';
import '../activity/activity_screen.dart';
import '../chat/chat_screen.dart';
import '../map/map_screen.dart';
import '../parent/children_list_screen.dart';
import '../settings/settings_screen.dart';
import 'stats_menu_feature_screens.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({
    super.key,
    this.showMenu = false,
    this.initialSelectedChildId,
  });

  final bool showMenu;
  final int? initialSelectedChildId;

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  List<Map<String, dynamic>> _children = [];
  int? _selectedChildId;
  Map<String, dynamic>? _stats;
  bool _loading = true;
  bool _savingLimit = false;
  String? _error;
  Timer? _poll;
  Set<String> _blockedPackages = {};
  Map<String, int> _blockedIdByPackage = {};

  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final cachedChildren = ref.read(parentChildrenProvider);
    if (cachedChildren.isNotEmpty) {
      await _syncChildren(cachedChildren);
    } else {
      try {
        await ref.read(parentChildrenProvider.notifier).refresh();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }

    if (!widget.showMenu) {
      _poll?.cancel();
      _poll = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _fetchChildData(),
      );
    }
  }

  Future<void> _syncChildren(List<Map<String, dynamic>> children) async {
    if (!mounted) return;
    final nextChildren = children
        .map((child) => Map<String, dynamic>.from(child))
        .toList(growable: false);

    if (nextChildren.isEmpty) {
      ref.read(selectedChildIdProvider.notifier).state = null;
      setState(() {
        _children = const [];
        _selectedChildId = null;
        _stats = null;
        _loading = false;
        _blockedPackages = const {};
        _blockedIdByPackage = const {};
      });
      return;
    }

    final nextSelectedChildId = _resolveInitialChildId(nextChildren);
    final selectionChanged = nextSelectedChildId != _selectedChildId;

    setState(() {
      _children = nextChildren;
      if (selectionChanged) {
        _selectedChildId = nextSelectedChildId;
        _stats = null;
        _loading = !widget.showMenu;
        _error = null;
        _selectedDate = DateTime.now();
        _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
        _blockedPackages = {};
        _blockedIdByPackage = {};
      } else if (widget.showMenu) {
        _loading = false;
      }
    });

    if (ref.read(selectedChildIdProvider) != nextSelectedChildId) {
      ref.read(selectedChildIdProvider.notifier).state = nextSelectedChildId;
    }

    if (selectionChanged && !widget.showMenu) {
      await _fetchChildData(showLoader: true);
    }
  }

  int _resolveInitialChildId(List<Map<String, dynamic>> list) {
    final providerChildId = ref.read(selectedChildIdProvider);
    final preferredIds = [
      _selectedChildId,
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

  Future<void> _fetchChildData({bool showLoader = false}) async {
    if (_selectedChildId == null) return;
    if (showLoader && mounted) {
      setState(() => _loading = true);
    }

    try {
      final results = await Future.wait([
        ApiClient.instance.childStatsSummary(
          _selectedChildId!,
          date: _selectedDate,
          month: _visibleMonth,
        ),
        ApiClient.instance.getBlockedApps(_selectedChildId!),
      ]);
      if (!mounted) return;

      final summary = results[0] as Map<String, dynamic>;
      final blocked =
          (results[1] as List<dynamic>).cast<Map<String, dynamic>>();

      final apiSelectedDate = _parseDate(summary['selected_date'] as String?);
      final apiSelectedMonth =
          _parseMonth(summary['selected_month'] as String?);

      setState(() {
        _stats = summary;
        _loading = false;
        _error = null;
        _selectedDate = apiSelectedDate ?? _selectedDate;
        _visibleMonth = apiSelectedMonth ?? _visibleMonth;
        _blockedPackages =
            blocked.map((b) => b['package_name'] as String).toSet();
        _blockedIdByPackage = {
          for (final b in blocked) b['package_name'] as String: b['id'] as int,
        };
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _selectDate(DateTime picked) async {
    setState(() {
      _selectedDate = picked;
      _visibleMonth = DateTime(picked.year, picked.month);
    });
    await _fetchChildData();
  }

  Future<void> _changeMonth(int offset) async {
    final targetMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    final lastDayOfTargetMonth =
        DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
    final nextDate = DateTime(
      targetMonth.year,
      targetMonth.month,
      math.min(_selectedDate.day, lastDayOfTargetMonth),
    );
    setState(() {
      _visibleMonth = targetMonth;
      _selectedDate = nextDate;
    });
    await _fetchChildData();
  }

  Future<void> _setSelectedChild(int id) async {
    ref.read(selectedChildIdProvider.notifier).state = id;
    await _applySelectedChild(id, syncProvider: false);
  }

  Future<void> _applySelectedChild(
    int id, {
    bool syncProvider = true,
  }) async {
    if (_selectedChildId == id) return;
    if (syncProvider) {
      ref.read(selectedChildIdProvider.notifier).state = id;
    }
    setState(() {
      _selectedChildId = id;
      _stats = null;
      _loading = !widget.showMenu;
      _error = null;
      _selectedDate = DateTime.now();
      _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
    });
    if (!widget.showMenu) {
      await _fetchChildData(showLoader: true);
    }
  }

  Future<void> _toggleLimit(Map<String, dynamic> app, bool enabled) async {
    final currentLimit = (app['daily_limit_minutes'] as int?) ?? 60;
    await _saveLimit(
      app: app,
      enabled: enabled,
      minutes: currentLimit == 0 ? 60 : currentLimit,
    );
  }

  Future<void> _editLimit(Map<String, dynamic> app) async {
    final t = S.of(context);
    final result = await showModalBottomSheet<_LimitEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final currentLimit = (app['daily_limit_minutes'] as int?) ?? 60;
        var enabled = (app['limit_enabled'] as bool?) ?? false;
        var minutes = currentLimit == 0 ? 60 : currentLimit;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app['app_name'] as String? ?? t.appLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.usageOnDate(
                      _formatMinutes((app['usage_minutes'] as int?) ?? 0),
                      _formatDate(context, 'MMM d', _selectedDate),
                    ),
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        t.enableDailyLimit,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: enabled,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.success,
                        onChanged: (value) =>
                            setSheetState(() => enabled = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        t.dailyLimit,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatMinutes(minutes),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: minutes.toDouble(),
                    min: 15,
                    max: 360,
                    divisions: 23,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setSheetState(
                      () => minutes = value.round(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(
                        _LimitEditResult(
                          minutes: minutes,
                          enabled: enabled,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        t.saveLimit,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    await _saveLimit(
      app: app,
      enabled: result.enabled,
      minutes: result.minutes,
    );
  }

  Future<void> _saveLimit({
    required Map<String, dynamic> app,
    required bool enabled,
    required int minutes,
  }) async {
    final t = S.of(context);
    if (_selectedChildId == null) return;
    setState(() => _savingLimit = true);
    try {
      await ApiClient.instance.setChildAppLimit(
        childId: _selectedChildId!,
        packageName: app['package_name'] as String? ?? '',
        appName: app['app_name'] as String? ?? t.appLabel,
        dailyLimitMinutes: minutes,
        enabled: enabled,
      );
      if (!mounted) return;
      await _fetchChildData();
      if (!mounted) return;
      showAppSnackBar(
        context,
        enabled
            ? t.limitSavedFor(app['app_name'] as String? ?? t.appLabel)
            : t.limitDisabledFor(app['app_name'] as String? ?? t.appLabel),
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        t.couldNotSaveLimit(e.toString()),
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _savingLimit = false);
    }
  }

  Future<void> _showAddAppSheet() async {
    final t = S.of(context);
    final knownApps = _allKnownApps;
    if (knownApps.isEmpty) {
      showAppSnackBar(
        context,
        t.noAdditionalAppsToAdd,
        type: AppFeedbackType.info,
      );
      return;
    }

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = query.isEmpty
                ? knownApps
                : knownApps
                    .where((a) =>
                        (a['app_name'] as String? ?? '')
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                        (a['package_name'] as String? ?? '')
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                    .toList();
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).addApp,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setSheetState(() => query = v),
                    decoration: InputDecoration(
                      hintText: S.of(context).searchPlaceholder,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.dividerLight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final app = filtered[i];
                        final name = app['app_name'] as String? ?? '';
                        final pkg = app['package_name'] as String? ?? '';
                        return ListTile(
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _AppLimitRow._colorForApp(pkg),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            pkg,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(app),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected == null || _selectedChildId == null) return;
    // Set a default limit of 60 minutes for the newly added app
    setState(() => _savingLimit = true);
    try {
      await ApiClient.instance.setChildAppLimit(
        childId: _selectedChildId!,
        packageName: selected['package_name'] as String? ?? '',
        appName: selected['app_name'] as String? ?? t.appLabel,
        dailyLimitMinutes: 60,
        enabled: true,
      );
      if (!mounted) return;
      await _fetchChildData();
      if (!mounted) return;
      showAppSnackBar(
        context,
        t.limitAddedForApp(selected['app_name'] as String? ?? t.appLabel),
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        e.toString(),
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _savingLimit = false);
    }
  }

  Future<void> _toggleBlock(Map<String, dynamic> app) async {
    if (_selectedChildId == null) return;
    final pkg = app['package_name'] as String? ?? '';
    final name = app['app_name'] as String? ?? S.of(context).appLabel;
    if (pkg.isEmpty) return;

    try {
      if (_blockedPackages.contains(pkg)) {
        final blockedId = _blockedIdByPackage[pkg];
        if (blockedId != null) {
          await ApiClient.instance.unblockApp(_selectedChildId!, blockedId);
        }
      } else {
        await ApiClient.instance.blockApp(
          _selectedChildId!,
          packageName: pkg,
          appName: name,
        );
      }
      if (!mounted) return;
      await _fetchChildData();
      if (!mounted) return;
      final isBlocked = _blockedPackages.contains(pkg);
      showAppSnackBar(
        context,
        isBlocked
            ? S.of(context).appBlocked(name)
            : S.of(context).appUnblocked(name),
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        e.toString(),
        type: AppFeedbackType.error,
      );
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  String get _childName {
    final t = S.of(context);
    if (_selectedChildId == null) return t.childLabel;
    return _displayNameForChild(
      _selectedChild ??
          <String, dynamic>{
            'display_name': t.childLabel,
            'username': 'child',
          },
    );
  }

  Map<String, dynamic>? get _selectedChild {
    if (_selectedChildId == null) return null;
    for (final child in _children) {
      if (child['id'] == _selectedChildId) return child;
    }
    return null;
  }

  Map<String, dynamic> get _device => _asMap(_stats?['device']);
  Map<String, dynamic> get _usage => _asMap(_stats?['usage']);
  List<Map<String, dynamic>> get _weekly => _asList(_stats?['weekly']);
  List<Map<String, dynamic>> get _calendar => _asList(_stats?['calendar']);
  List<Map<String, dynamic>> get _apps => _asList(_stats?['apps']);
  List<Map<String, dynamic>> get _allKnownApps =>
      _asList(_stats?['all_known_apps']);

  int get _battery => (_device['battery'] as int?) ?? 0;
  bool get _charging => (_device['charging'] as bool?) ?? false;
  bool get _isActive => (_device['active'] as bool?) ?? false;
  bool get _usageAccessGranted =>
      (_device['usage_access_granted'] as bool?) ?? false;
  bool get _isIosDevice =>
      ((_device['platform'] as String?) ?? '').toLowerCase() == 'ios';
  int get _selectedTotal => (_usage['selected_total_minutes'] as int?) ?? 0;
  int get _selectedLimit =>
      (_usage['selected_total_limit_minutes'] as int?) ?? 0;
  int get _overLimitApps => (_usage['over_limit_apps'] as int?) ?? 0;
  double? get _goalProgress {
    final value = _usage['goal_progress'];
    return value is num ? value.toDouble() : null;
  }

  bool get _selectedDayHasData {
    for (final day in _calendar) {
      if ((day['is_selected'] as bool?) ?? false) {
        return (day['has_data'] as bool?) ?? false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<Map<String, dynamic>>>(parentChildrenProvider,
        (previous, next) {
      unawaited(_syncChildren(next));
    });
    ref.listen<int?>(selectedChildIdProvider, (previous, next) {
      if (!mounted || next == null || next == _selectedChildId) return;
      if (_children.any((child) => child['id'] == next)) {
        _applySelectedChild(next, syncProvider: false);
      }
    });
    final t = S.of(context);
    final session = ref.watch(sessionProvider);
    final selectedDateLabel =
        _formatDate(context, 'MMM d, yyyy', _selectedDate);

    if (widget.showMenu) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildMenuScreen(session),
      );
    }

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
            titlePrefix: t.parentProfile,
            title: t.appName,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _openMenuScreen,
                  icon: const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.textPrimaryLight,
                  ),
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
            children: _children,
            selectedChildId: _selectedChildId,
            onSelected: _setSelectedChild,
          ),
          Expanded(
            child: _buildBody(selectedDateLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuScreen(dynamic session) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primarySoft.withValues(alpha: 0.85),
            AppColors.backgroundLight,
            const Color(0xFFF7FAFF),
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshMenu,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Меню',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openManageChildren,
                    icon: const Icon(
                      Icons.people_alt_outlined,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_children.isEmpty)
                _buildMenuEmptyState()
              else ...[
                _buildMenuChildCard(session),
                if (_children.length > 1) ...[
                  const SizedBox(height: 16),
                  _buildMenuChildSelector(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                _buildMenuGrid(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuEmptyState() {
    final t = S.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Меню появится после добавления ребёнка',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.addChildForStats,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openManageChildren,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Добавить ребёнка',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuChildCard(dynamic session) {
    final child = _selectedChild;
    final childName = child != null ? _displayNameForChild(child) : _childName;
    final avatarUrl = child?['avatar_url'] as String?;
    final parentName = (session.user?.displayName as String?)?.trim() ?? '';
    final parentLabel =
        parentName.isEmpty ? 'Быстрый доступ' : 'Панель $parentName';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primarySoft.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarCircle(
            size: 54,
            initials: childName.isNotEmpty ? childName[0].toUpperCase() : '?',
            color: AppColors.primary,
            image: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  parentLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Выбран',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuChildSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final child in _children)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _MenuChildChip(
                label: _displayNameForChild(child),
                avatarUrl: child['avatar_url'] as String?,
                selected: child['id'] == _selectedChildId,
                onTap: () => _setSelectedChild(child['id'] as int),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final tiles = <_MenuTileData>[
      _MenuTileData(
        title: 'Онлайн звук\nвокруг ребенка',
        icon: Icons.hearing_rounded,
        accent: AppColors.success,
        onTap: _openAroundForSelectedChild,
      ),
      _MenuTileData(
        title: 'Лимиты на игры',
        icon: Icons.sports_esports_rounded,
        accent: AppColors.primary,
        onTap: _openGameLimits,
      ),
      _MenuTileData(
        title: 'Входящие чаты',
        icon: Icons.forum_outlined,
        accent: AppColors.accent,
        onTap: _openChats,
      ),
      _MenuTileData(
        title: 'Места на карте',
        icon: Icons.map_outlined,
        accent: AppColors.warning,
        onTap: _openMapScreen,
      ),
      _MenuTileData(
        title: 'История\nпередвижения',
        icon: Icons.route_rounded,
        accent: AppColors.navy,
        onTap: _openHistory,
      ),
      _MenuTileData(
        title: 'Статистика\nприложений',
        icon: Icons.bar_chart_rounded,
        accent: AppColors.primary,
        onTap: _openStatsDetails,
      ),
      _MenuTileData(
        title: 'Достижения\nребенка',
        icon: Icons.emoji_events_outlined,
        accent: AppColors.warning,
        onTap: _openAchievements,
      ),
      _MenuTileData(
        title: 'Громкий\nсигнал',
        icon: Icons.notifications_active_outlined,
        accent: AppColors.danger,
        onTap: _openLoudSignal,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 560 ? 4 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 22,
            childAspectRatio: 0.76,
          ),
          itemBuilder: (context, index) => _MenuFeatureTile(data: tiles[index]),
        );
      },
    );
  }

  Future<void> _refreshMenu() async {
    try {
      await ref.read(parentChildrenProvider.notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        e.toString(),
        type: AppFeedbackType.error,
      );
    }
  }

  String _displayNameForChild(Map<String, dynamic> child) {
    final t = S.of(context);
    final displayName = (child['display_name'] as String?)?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;
    final username = (child['username'] as String?)?.trim() ?? '';
    return username.isNotEmpty ? username : t.childLabel;
  }

  Future<void> _openMenuScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StatsScreen(
          showMenu: true,
          initialSelectedChildId: _selectedChildId,
        ),
      ),
    );
  }

  Future<void> _openManageChildren() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ChildrenListScreen(),
        ),
      ),
    );
    if (!mounted) return;
    await _refreshMenu();
  }

  Future<void> _openStandaloneScreen(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  Future<void> _openEmbeddedScreen(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: screen,
        ),
      ),
    );
  }

  Map<String, dynamic>? _selectedMenuChildOrWarn() {
    final child = _selectedChild;
    if (child != null) return child;
    showAppSnackBar(
      context,
      'Сначала добавьте ребёнка.',
      type: AppFeedbackType.warning,
    );
    return null;
  }

  int? _selectedMenuChildIdOrWarn() {
    final childId = _selectedChildId;
    if (childId != null) return childId;
    showAppSnackBar(
      context,
      'Сначала добавьте ребёнка.',
      type: AppFeedbackType.warning,
    );
    return null;
  }

  Future<void> _openMapScreen() async {
    await _openEmbeddedScreen(const MapScreen());
  }

  Future<void> _openChats() async {
    final childId = _selectedMenuChildIdOrWarn();
    if (childId == null) return;
    await _openEmbeddedScreen(
      ChatScreen(initialSelectedChildId: childId),
    );
  }

  Future<void> _openHistory() async {
    final childId = _selectedMenuChildIdOrWarn();
    if (childId == null) return;
    await _openEmbeddedScreen(
      ActivityScreen(initialSelectedChildId: childId),
    );
  }

  Future<void> _openAchievements() async {
    final child = _selectedMenuChildOrWarn();
    if (child == null) return;
    await _openStandaloneScreen(
      MenuAchievementsScreen(
        childId: child['id'] as int,
        childName: _displayNameForChild(child),
        avatarUrl: child['avatar_url'] as String?,
      ),
    );
  }

  Future<void> _openStatsDetails() async {
    final childId = _selectedMenuChildIdOrWarn();
    if (childId == null) return;
    await _openEmbeddedScreen(
      StatsScreen(
        showMenu: false,
        initialSelectedChildId: childId,
      ),
    );
  }

  Future<void> _openGameLimits() async {
    final child = _selectedMenuChildOrWarn();
    if (child == null) return;
    await _openStandaloneScreen(
      MenuGameLimitsScreen(
        childId: child['id'] as int,
        childName: _displayNameForChild(child),
        avatarUrl: child['avatar_url'] as String?,
      ),
    );
  }

  Future<void> _openLoudSignal() async {
    final child = _selectedMenuChildOrWarn();
    if (child == null) return;
    await _openStandaloneScreen(
      MenuLoudSignalScreen(
        childId: child['id'] as int,
        childName: _displayNameForChild(child),
        avatarUrl: child['avatar_url'] as String?,
      ),
    );
  }

  Future<void> _openAroundForSelectedChild() async {
    final child = _selectedMenuChildOrWarn();
    if (child == null) return;
    await _openStandaloneScreen(
      MenuAroundSoundScreen(
        childId: child['id'] as int,
        childName: _displayNameForChild(child),
        avatarUrl: child['avatar_url'] as String?,
      ),
    );
  }

  Widget _buildBody(String selectedDateLabel) {
    final t = S.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_children.isEmpty) {
      return Center(
        child: Text(
          t.addChildForStats,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchChildData(showLoader: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            children: [
              Text(
                t.insights,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.dividerLight),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      selectedDateLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.childStats(_childName),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 14),
          _buildDeviceCard(),
          const SizedBox(height: 12),
          _buildCalendarCard(),
          const SizedBox(height: 12),
          _selectedDayHasData
              ? _buildGoalCard()
              : _buildNoDataCard(selectedDateLabel),
          const SizedBox(height: 12),
          _buildWeeklyCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.manageAppLimits,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_savingLimit)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (!_savingLimit && _allKnownApps.isNotEmpty)
                InkWell(
                  onTap: _showAddAppSheet,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          t.add,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_apps.isEmpty)
            AppCard(
              child: Text(
                !_selectedDayHasData
                    ? _noDataLabel(context)
                    : _usageAccessGranted
                        ? t.noAppUsageData
                        : _isIosDevice
                            ? t.iosAppLimitsUnavailable
                            : t.grantUsageAccessHint,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            )
          else
            ..._apps.map(_buildAppRow),
        ],
      ),
    );
  }

  Widget _buildDeviceCard() {
    final t = S.of(context);
    final deviceName = _device['device_name'] as String? ?? '';
    final manufacturer = _device['manufacturer'] as String? ?? '';
    final model = _device['model'] as String? ?? '';
    final address = _device['address'] as String? ?? '';

    final hardware = [
      if (deviceName.isNotEmpty) deviceName,
      if (deviceName.isEmpty && manufacturer.isNotEmpty) manufacturer,
      if (model.isNotEmpty && model != deviceName) model,
    ].join(' · ');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.deviceStatus,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              StatusBadge(
                text: _isActive ? t.statusActive : t.statusOffline,
                color: _isActive ? AppColors.success : AppColors.danger,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hardware.isEmpty ? _childName : hardware,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                icon: _batteryIcon(_battery),
                color: _batteryColor(_battery),
                label: _battery > 0
                    ? t.batteryPercent(_battery)
                    : t.batteryUnknown,
              ),
              _MetricChip(
                icon: _charging ? Icons.bolt_rounded : Icons.power_outlined,
                color: _charging ? AppColors.success : AppColors.textMuted,
                label: _charging ? t.chargingShort : t.notChargingShort,
              ),
              _MetricChip(
                icon: Icons.schedule,
                color: AppColors.primary,
                label:
                    _syncedLabel(context, _device['last_sync_at'] as String?),
              ),
              _MetricChip(
                icon: _usageAccessGranted
                    ? Icons.verified_user_outlined
                    : Icons.lock_clock_outlined,
                color:
                    _usageAccessGranted ? AppColors.success : AppColors.warning,
                label: _usageAccessGranted
                    ? t.usageAccessGranted
                    : t.usageAccessNeeded,
              ),
            ],
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              address,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
          if (!_usageAccessGranted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _isIosDevice ? t.iosUsageAccessNote : t.androidUsageAccessNote,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    final t = S.of(context);
    final progress = _goalProgress;
    final showRing = progress != null && _selectedLimit > 0;
    final progressValue = showRing ? progress : 0.0;
    final progressText = showRing ? '${(progressValue * 100).round()} %' : '--';

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.dailyUsage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  showRing
                      ? t.usageOfLimit(
                          _formatMinutes(_selectedTotal),
                          _formatMinutes(_selectedLimit),
                        )
                      : t.usageOnDate(
                          _formatMinutes(_selectedTotal),
                          _formatDate(context, 'MMM d', _selectedDate),
                        ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  progressText,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedLimit > 0
                      ? _overLimitApps > 0
                          ? t.appLimitExceeded(_overLimitApps)
                          : t.allLimitsInRange
                      : t.setAppLimitsHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          _BigBlueRing(value: progressValue),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final t = S.of(context);
    final monthLabel = _formatDate(context, 'LLLL yyyy', _visibleMonth);
    final weekdayLabels = [t.mon, t.tue, t.wed, t.thu, t.fri, t.sat, t.sun];
    final firstWeekday =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday;
    final leadingEmpty = firstWeekday - DateTime.monday;
    final cells = <Widget>[
      for (final label in weekdayLabels)
        Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ),
      for (var i = 0; i < leadingEmpty; i++) const SizedBox.shrink(),
      for (final day in _calendar)
        _CalendarDayCell(
          date: _parseDate(day['date'] as String?) ?? _selectedDate,
          dayLabel: '${(day['day'] as int?) ?? 0}',
          hasData: (day['has_data'] as bool?) ?? false,
          isSelected: (day['is_selected'] as bool?) ?? false,
          isToday: (day['is_today'] as bool?) ?? false,
          isOverLimit: (day['over_limit'] as bool?) ?? false,
          onTap: () => _selectDate(
            _parseDate(day['date'] as String?) ?? _selectedDate,
          ),
        ),
    ];

    return AppCard(
      color: const Color(0xFFF7F8FC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.usageCalendar,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _CalendarNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _changeMonth(-1),
              ),
              const SizedBox(width: 8),
              _CalendarNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        monthLabel[0].toUpperCase() + monthLabel.substring(1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _formatDate(context, 'd MMM', _selectedDate),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 7,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 5,
                  childAspectRatio: 1.14,
                  children: cells,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _CalendarLegendDot(
                      color: AppColors.primary,
                      label: t.selectedDay,
                    ),
                    _CalendarLegendDot(
                      color: AppColors.success,
                      label: t.hasData,
                    ),
                    _CalendarLegendDot(
                      color: AppColors.danger,
                      label: t.over,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(String selectedDateLabel) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _noDataLabel(context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            S.of(context).noStatisticsFoundFor(selectedDateLabel),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCard() {
    final t = S.of(context);
    final maxMinutes = _weekly.fold<int>(
      0,
      (maxValue, day) =>
          math.max(maxValue, (day['total_minutes'] as int?) ?? 0),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.weeklyUsage,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                _formatMinutes(_selectedTotal),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 144,
            child: _WeeklyBars(
              days: _weekly,
              maxMinutes: maxMinutes == 0 ? 1 : maxMinutes,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppRow(Map<String, dynamic> app) {
    final pkg = app['package_name'] as String? ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _AppLimitRow(
        name: app['app_name'] as String? ?? S.of(context).appLabel,
        packageName: pkg,
        usageMinutes: (app['usage_minutes'] as int?) ?? 0,
        dailyLimitMinutes: app['daily_limit_minutes'] as int?,
        enabled: (app['limit_enabled'] as bool?) ?? false,
        exceeded: (app['exceeded'] as bool?) ?? false,
        blocked: _blockedPackages.contains(pkg),
        onToggle: (value) => _toggleLimit(app, value),
        onEdit: () => _editLimit(app),
        onBlock: () => _toggleBlock(app),
      ),
    );
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  DateTime? _parseMonth(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split('-');
    if (parts.length != 2) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return null;
    return DateTime(year, month);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '${remainingMinutes}m';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  String _noDataLabel(BuildContext context) {
    return S.of(context).noData;
  }

  String _formatDate(BuildContext context, String pattern, DateTime date) {
    return DateFormat(
      pattern,
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }

  String _friendlyTime(
    BuildContext context,
    String? iso, {
    required String fallback,
  }) {
    if (iso == null || iso.isEmpty) return fallback;
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return fallback;
    final t = S.of(context);
    final diff = DateTime.now().difference(date);
    final value = diff.inSeconds < 60
        ? t.justNow
        : diff.inMinutes < 60
            ? t.minutesAgo(diff.inMinutes)
            : diff.inHours < 24
                ? t.hoursAgo(diff.inHours)
                : _formatDate(context, 'MMM d, HH:mm', date);
    return value;
  }

  String _syncedLabel(BuildContext context, String? iso) {
    final t = S.of(context);
    final value = _friendlyTime(
      context,
      iso,
      fallback: t.noDeviceSyncYet,
    );
    return value == t.noDeviceSyncYet ? value : t.synced(value);
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
}

class _LimitEditResult {
  const _LimitEditResult({
    required this.minutes,
    required this.enabled,
  });

  final int minutes;
  final bool enabled;
}

class _MenuTileData {
  const _MenuTileData({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final Future<void> Function() onTap;
}

class _MenuFeatureTile extends StatelessWidget {
  const _MenuFeatureTile({
    required this.data,
  });

  final _MenuTileData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => unawaited(data.onTap()),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    data.icon,
                    size: 32,
                    color: data.accent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            maxLines: 3,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.18,
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuChildChip extends StatelessWidget {
  const _MenuChildChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.avatarUrl,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.7),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarCircle(
              size: 28,
              initials: label.isNotEmpty ? label[0].toUpperCase() : '?',
              color: AppColors.primary,
              image: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimaryLight,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimaryLight),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.dayLabel,
    required this.hasData,
    required this.isSelected,
    required this.isToday,
    required this.isOverLimit,
    required this.onTap,
  });

  final DateTime date;
  final String dayLabel;
  final bool hasData;
  final bool isSelected;
  final bool isToday;
  final bool isOverLimit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? Colors.white
        : isOverLimit
            ? AppColors.danger
            : AppColors.textPrimaryLight;
    final backgroundColor = isSelected
        ? AppColors.primary
        : isToday
            ? AppColors.primarySoft
            : const Color(0xFFF6F7FB);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday && !isSelected
                ? AppColors.primary.withValues(alpha: 0.28)
                : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 1),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: hasData
                    ? (isSelected ? Colors.white : AppColors.success)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarLegendDot extends StatelessWidget {
  const _CalendarLegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chipGrey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BigBlueRing extends StatelessWidget {
  const _BigBlueRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 8,
              backgroundColor: AppColors.dividerLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const Icon(
            Icons.timer_outlined,
            color: AppColors.primary,
            size: 26,
          ),
        ],
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({
    required this.days,
    required this.maxMinutes,
  });

  final List<Map<String, dynamic>> days;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(days.length, (index) {
        final day = days[index];
        final minutes = (day['total_minutes'] as int?) ?? 0;
        final active = (day['is_selected'] as bool?) ?? false;
        final value = maxMinutes == 0 ? 0.0 : minutes / maxMinutes;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  minutes == 0
                      ? ''
                      : minutes ~/ 60 > 0
                          ? '${minutes ~/ 60}h'
                          : '${minutes}m',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: minutes == 0 ? 0 : value.clamp(0.08, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.dividerLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  switch (((day['label'] as String?) ?? '').toUpperCase()) {
                    'MON' => t.mon,
                    'TUE' => t.tue,
                    'WED' => t.wed,
                    'THU' => t.thu,
                    'FRI' => t.fri,
                    'SAT' => t.sat,
                    'SUN' => t.sun,
                    _ => (day['label'] as String?) ?? '',
                  },
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AppLimitRow extends StatelessWidget {
  const _AppLimitRow({
    required this.name,
    required this.packageName,
    required this.usageMinutes,
    required this.dailyLimitMinutes,
    required this.enabled,
    required this.exceeded,
    required this.blocked,
    required this.onToggle,
    required this.onEdit,
    required this.onBlock,
  });

  final String name;
  final String packageName;
  final int usageMinutes;
  final int? dailyLimitMinutes;
  final bool enabled;
  final bool exceeded;
  final bool blocked;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final limitText = enabled && dailyLimitMinutes != null
        ? t.limitMinutes(_formatMinutes(dailyLimitMinutes!))
        : t.noLimit;
    final usageText = exceeded
        ? t.usageTodayOverLimit(_formatMinutes(usageMinutes))
        : t.usageToday(_formatMinutes(usageMinutes));

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _colorForApp(packageName),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (exceeded)
                      StatusBadge(
                        text: t.over,
                        color: AppColors.danger,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  usageText,
                  style: TextStyle(
                    fontSize: 12,
                    color: exceeded
                        ? AppColors.danger
                        : AppColors.textSecondaryLight,
                    fontWeight: exceeded ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chipGrey,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          limitText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onBlock,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: blocked
                              ? AppColors.danger.withValues(alpha: 0.15)
                              : AppColors.chipGrey,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              blocked
                                  ? Icons.lock_rounded
                                  : Icons.lock_open_rounded,
                              size: 12,
                              color: blocked
                                  ? AppColors.danger
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              blocked ? t.blocked : t.block,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: blocked
                                    ? AppColors.danger
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            activeThumbColor: Colors.white,
            activeTrackColor: exceeded ? AppColors.danger : AppColors.success,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '${remainingMinutes}m';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  static Color _colorForApp(String seed) {
    const palette = [
      Color(0xFF0F766E),
      Color(0xFFDC2626),
      Color(0xFFEA580C),
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
      Color(0xFFCA8A04),
      Color(0xFFBE185D),
    ];
    final index = seed.hashCode.abs() % palette.length;
    return palette[index];
  }
}
