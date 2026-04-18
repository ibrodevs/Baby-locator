import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../settings/settings_screen.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

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

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    try {
      final list = (await ApiClient.instance.listChildren())
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() => _children = list);
      if (list.isNotEmpty) {
        final selectedChildId = _resolveInitialChildId(list);
        ref.read(selectedChildIdProvider.notifier).state = selectedChildId;
        _selectedChildId = selectedChildId;
        await _fetchChildData(showLoader: true);
      } else {
        ref.read(selectedChildIdProvider.notifier).state = null;
        setState(() => _loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }

    _poll?.cancel();
    _poll = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _fetchChildData(),
    );
  }

  int _resolveInitialChildId(List<Map<String, dynamic>> list) {
    final providerChildId = ref.read(selectedChildIdProvider);
    final preferredIds = [providerChildId].whereType<int>();
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
      final summary = await ApiClient.instance.childStatsSummary(
        _selectedChildId!,
        date: _selectedDate,
        month: _selectedMonth,
      );
      if (!mounted) return;

      final apiSelectedDate = _parseDate(summary['selected_date'] as String?);
      final apiSelectedMonth =
          _parseMonth(summary['selected_month'] as String?) ?? _selectedMonth;

      setState(() {
        _stats = summary;
        _loading = false;
        _error = null;
        _selectedDate = apiSelectedDate ?? _selectedDate;
        _selectedMonth = apiSelectedMonth;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
      _selectedMonth = DateTime(picked.year, picked.month);
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
      _loading = true;
      _error = null;
      _selectedDate = DateTime.now();
      _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    });
    await _fetchChildData(showLoader: true);
  }

  Future<void> _changeMonth(int delta) async {
    final nextMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    final lastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    final nextSelectedDate = DateTime(
      nextMonth.year,
      nextMonth.month,
      math.min(_selectedDate.day, lastDay),
    );
    setState(() {
      _selectedMonth = DateTime(nextMonth.year, nextMonth.month);
      _selectedDate = nextSelectedDate;
    });
    await _fetchChildData();
  }

  Future<void> _selectCalendarDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedMonth = DateTime(date.year, date.month);
    });
    await _fetchChildData();
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
                    app['app_name'] as String? ?? 'App',
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
                        style: TextStyle(
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
                        style: TextStyle(
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
                        style: TextStyle(fontWeight: FontWeight.w800),
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
        appName: app['app_name'] as String? ?? 'App',
        dailyLimitMinutes: minutes,
        enabled: enabled,
      );
      if (!mounted) return;
      await _fetchChildData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? t.limitSavedFor(app['app_name'] as String? ?? 'App')
                : t.limitDisabledFor(app['app_name'] as String? ?? 'App'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.couldNotSaveLimit(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _savingLimit = false);
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  String get _childName {
    if (_selectedChildId == null) return 'Child';
    final child = _children.firstWhere(
      (c) => c['id'] == _selectedChildId,
      orElse: () => {'display_name': 'Child', 'username': 'child'},
    );
    final displayName = child['display_name'] as String?;
    return (displayName?.isNotEmpty ?? false)
        ? displayName!
        : child['username'] as String? ?? 'Child';
  }

  Map<String, dynamic> get _device => _asMap(_stats?['device']);
  Map<String, dynamic> get _usage => _asMap(_stats?['usage']);
  List<Map<String, dynamic>> get _weekly => _asList(_stats?['weekly']);
  List<Map<String, dynamic>> get _calendar => _asList(_stats?['calendar']);
  List<Map<String, dynamic>> get _apps => _asList(_stats?['apps']);

  int get _battery => (_device['battery'] as int?) ?? 0;
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

  @override
  Widget build(BuildContext context) {
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
            title: 'Kid Security',
            trailing: GearButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
          if (_children.length > 1)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _children.length,
                itemBuilder: (_, index) {
                  final child = _children[index];
                  final id = child['id'] as int;
                  final name =
                      ((child['display_name'] as String?)?.isNotEmpty ?? false)
                          ? child['display_name'] as String
                          : child['username'] as String;
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
                      onSelected: (_) => _setSelectedChild(id),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: _buildBody(selectedDateLabel),
          ),
        ],
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
          style: TextStyle(
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            children: [
              Text(
                t.insights,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(999),
                child: Container(
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
          _buildGoalCard(),
          const SizedBox(height: 12),
          _buildWeeklyCard(),
          const SizedBox(height: 12),
          _buildCalendarCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.manageAppLimits,
                  style: TextStyle(
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
            ],
          ),
          const SizedBox(height: 10),
          if (_apps.isEmpty)
            AppCard(
              child: Text(
                _usageAccessGranted
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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

  Widget _buildCalendarCard() {
    final t = S.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.usageCalendar,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                _formatDate(context, 'MMMM yyyy', _selectedMonth),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _UsageCalendar(
            month: _selectedMonth,
            days: _calendar,
            onSelectDate: _selectCalendarDate,
          ),
        ],
      ),
    );
  }

  Widget _buildAppRow(Map<String, dynamic> app) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _AppLimitRow(
        name: app['app_name'] as String? ?? 'App',
        packageName: app['package_name'] as String? ?? '',
        usageMinutes: (app['usage_minutes'] as int?) ?? 0,
        dailyLimitMinutes: app['daily_limit_minutes'] as int?,
        enabled: (app['limit_enabled'] as bool?) ?? false,
        exceeded: (app['exceeded'] as bool?) ?? false,
        onToggle: (value) => _toggleLimit(app, value),
        onEdit: () => _editLimit(app),
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

class _UsageCalendar extends StatelessWidget {
  const _UsageCalendar({
    required this.month,
    required this.days,
    required this.onSelectDate,
  });

  final DateTime month;
  final List<Map<String, dynamic>> days;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final firstDay = DateTime(month.year, month.month);
    final leadingEmpty = firstDay.weekday - 1;
    final maxMinutes = days.fold<int>(
      0,
      (maxValue, day) =>
          math.max(maxValue, (day['total_minutes'] as int?) ?? 0),
    );

    final cells = <Widget>[
      ...List.generate(leadingEmpty, (_) => const SizedBox.shrink()),
      ...days.map((day) {
        final date =
            DateTime.tryParse(day['date'] as String? ?? '') ?? firstDay;
        final totalMinutes = (day['total_minutes'] as int?) ?? 0;
        final hasData = (day['has_data'] as bool?) ?? false;
        final isSelected = (day['is_selected'] as bool?) ?? false;
        final isToday = (day['is_today'] as bool?) ?? false;
        final overLimit = (day['over_limit'] as bool?) ?? false;

        final intensity = maxMinutes == 0 ? 0.0 : totalMinutes / maxMinutes;
        final baseColor = hasData
            ? AppColors.primary.withValues(alpha: 0.12 + (0.28 * intensity))
            : Colors.white;
        final textColor =
            isSelected ? Colors.white : AppColors.textPrimaryLight;
        final secondaryTextColor = isSelected
            ? Colors.white.withValues(alpha: 0.92)
            : AppColors.textSecondaryLight;

        return InkWell(
          onTap: () => onSelectDate(date),
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : baseColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isToday
                        ? AppColors.primary
                        : overLimit
                            ? AppColors.danger.withValues(alpha: 0.35)
                            : AppColors.dividerLight,
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.18)
                        : isToday
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${day['day'] ?? date.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (hasData)
                  Text(
                    totalMinutes >= 60
                        ? '${totalMinutes ~/ 60}h'
                        : '${totalMinutes}m',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: secondaryTextColor,
                    ),
                  ),
                if (overLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    ];

    return Column(
      children: [
        Row(
          children: [
            _CalendarHeaderLabel(t.mon),
            _CalendarHeaderLabel(t.tue),
            _CalendarHeaderLabel(t.wed),
            _CalendarHeaderLabel(t.thu),
            _CalendarHeaderLabel(t.fri),
            _CalendarHeaderLabel(t.sat),
            _CalendarHeaderLabel(t.sun),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.72,
          children: cells,
        ),
      ],
    );
  }
}

class _CalendarHeaderLabel extends StatelessWidget {
  const _CalendarHeaderLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
          ),
        ),
      ),
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
    required this.onToggle,
    required this.onEdit,
  });

  final String name;
  final String packageName;
  final int usageMinutes;
  final int? dailyLimitMinutes;
  final bool enabled;
  final bool exceeded;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

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
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
