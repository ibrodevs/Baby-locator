import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';

import '../../core/services/api_client.dart';
import '../../core/services/local_avatar_store.dart';
import '../../core/services/parent_webrtc_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/brand_header.dart';

class MenuAroundSoundScreen extends StatefulWidget {
  const MenuAroundSoundScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.avatarUrl,
    this.autoStart = false,
  });

  final int childId;
  final String childName;
  final String? avatarUrl;
  final bool autoStart;

  @override
  State<MenuAroundSoundScreen> createState() => _MenuAroundSoundScreenState();
}

class _MenuAroundSoundScreenState extends State<MenuAroundSoundScreen> {
  // "Звук вокруг" runs over WebRTC (Opus + jitter buffer + congestion
  // control) — the same peer-to-peer audio pipeline as the monitoring
  // feature. It is the only protocol on this stack that delivers smooth
  // continuous voice on cellular networks; the previous HTTP-streaming
  // implementation glitched whenever the network paused for >1-2s.
  final ParentWebRTCService _liveAudio = ParentWebRTCService();

  Map<String, dynamic>? _stats;
  bool _starting = false;
  bool _listening = false;
  String? _error;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _liveAudio.onStatus = _handleStatus;
    _liveAudio.onAudioStarted = _handleAudioStarted;
    _liveAudio.onAudioStopped = _handleAudioStopped;
    _liveAudio.onError = _handleError;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSummary();
      if (widget.autoStart && mounted) {
        await _startListening();
      }
    });
  }

  @override
  void dispose() {
    _liveAudio.onStatus = null;
    _liveAudio.onAudioStarted = null;
    _liveAudio.onAudioStopped = null;
    _liveAudio.onError = null;
    unawaited(_liveAudio.stopListening());
    super.dispose();
  }

  Map<String, dynamic> get _device {
    final value = _stats?['device'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  int get _battery => (_device['battery'] as int?) ?? 0;
  bool get _charging => (_device['charging'] as bool?) ?? false;
  bool get _active => (_device['active'] as bool?) ?? false;

  void _handleStatus(String status) {
    if (!mounted) return;
    setState(() {
      _status = status;
    });
  }

  void _handleAudioStarted() {
    if (!mounted) return;
    setState(() {
      _starting = false;
      _listening = true;
      _error = null;
      _status = S.of(context).listeningTo(widget.childName);
    });
  }

  void _handleAudioStopped() {
    if (!mounted) return;
    setState(() {
      _starting = false;
      _listening = false;
    });
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _starting = false;
      _listening = false;
      _error = message;
      _status = S.of(context).errorLabel;
    });
  }

  Future<void> _loadSummary() async {
    setState(() {
      _error = null;
    });
    try {
      final now = DateTime.now();
      final summary = await ApiClient.instance.childStatsSummary(
        widget.childId,
        date: now,
        month: DateTime(now.year, now.month),
      );
      if (!mounted) return;
      setState(() {
        _stats = summary;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _startListening() async {
    if (_starting || _listening) return;
    final t = S.of(context);
    setState(() {
      _starting = true;
      _error = null;
      _status = t.connectingToChildPhone;
    });
    await _liveAudio.startListening(childId: widget.childId);
    if (!mounted) return;
    if (_liveAudio.isListening && !_listening) {
      setState(() {
        _error = null;
      });
    }
  }

  Future<void> _stopListening() async {
    await _liveAudio.stopListening();
    if (!mounted) return;
    setState(() {
      _status = '';
      _error = null;
      _listening = false;
      _starting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Звук вокруг ребёнка',
      subtitle: widget.childName,
      onRefresh: _loadSummary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _FeatureHeroCard(
            childName: widget.childName,
            avatarUrl: widget.avatarUrl,
            accent: AppColors.success,
            subtitle: _active ? 'Телефон на связи' : 'Телефон офлайн',
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(
                  text: _active
                      ? S.of(context).statusActive
                      : S.of(context).statusOffline,
                  color: _active ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(height: 10),
                Text(
                  _battery > 0 ? 'Батарея $_battery%' : 'Батарея неизвестна',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.hearing_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Онлайн аудио с телефона ребёнка',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _status.isEmpty
                      ? 'Нажмите кнопку ниже, чтобы начать непрерывно слушать звук рядом с ребёнком.'
                      : _status,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if ((_listening || _starting) && _error == null) ...[
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    color: AppColors.success,
                    backgroundColor: AppColors.chipGrey,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _starting
                        ? null
                        : _listening
                            ? _stopListening
                            : _startListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _listening ? AppColors.danger : AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: Icon(
                      _listening
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      _listening
                          ? 'Остановить прослушивание'
                          : 'Начать слушать',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Row(
              children: [
                _MiniStat(
                  label: 'Статус',
                  value: _active ? 'Онлайн' : 'Офлайн',
                  color: _active ? AppColors.success : AppColors.danger,
                ),
                _MiniStat(
                  label: 'Зарядка',
                  value: _charging ? 'Да' : 'Нет',
                  color: _charging ? AppColors.success : AppColors.textMuted,
                ),
                _MiniStat(
                  label: 'Звук',
                  value: _listening ? 'Идёт' : 'Ждёт',
                  color: _listening ? AppColors.primary : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuGameLimitsScreen extends StatefulWidget {
  const MenuGameLimitsScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.avatarUrl,
  });

  final int childId;
  final String childName;
  final String? avatarUrl;

  @override
  State<MenuGameLimitsScreen> createState() => _MenuGameLimitsScreenState();
}

class _MenuGameLimitsScreenState extends State<MenuGameLimitsScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Set<String> _blockedPackages = {};
  Map<String, int> _blockedIdByPackage = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Map<String, dynamic> get _usage {
    final value = _stats?['usage'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  List<Map<String, dynamic>> get _apps {
    return _asList(_stats?['apps'])
        .where((item) {
          final pkg = (item['package_name'] as String? ?? '').trim();
          return pkg.isNotEmpty;
        })
        .fold<Map<String, Map<String, dynamic>>>({}, (acc, item) {
          final pkg = (item['package_name'] as String? ?? '').trim();
          final existing = acc[pkg];
          final nextUsage = (item['usage_minutes'] as int?) ?? 0;
          final existingUsage = (existing?['usage_minutes'] as int?) ?? 0;
          if (existing == null || nextUsage >= existingUsage) {
            acc[pkg] = Map<String, dynamic>.from(item);
          }
          return acc;
        })
        .values
        .toList()
      ..sort(
        (a, b) => ((b['usage_minutes'] as int?) ?? 0)
            .compareTo((a['usage_minutes'] as int?) ?? 0),
      );
  }

  bool get _usageAccessGranted => (_stats?['device'] is Map &&
      (((_stats!['device'] as Map)['usage_access_granted'] as bool?) ?? false));

  int get _selectedTotal => (_usage['selected_total_minutes'] as int?) ?? 0;
  int get _selectedLimit =>
      (_usage['selected_total_limit_minutes'] as int?) ?? 0;
  int get _overLimitApps => (_usage['over_limit_apps'] as int?) ?? 0;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        ApiClient.instance.childStatsSummary(
          widget.childId,
          date: now,
          month: DateTime(now.year, now.month),
        ),
        ApiClient.instance.getBlockedApps(widget.childId),
      ]);
      if (!mounted) return;
      final blocked =
          (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _blockedPackages =
            blocked.map((b) => b['package_name'] as String).toSet();
        _blockedIdByPackage = {
          for (final b in blocked) b['package_name'] as String: b['id'] as int,
        };
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
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
                    app['app_name'] as String? ?? 'Приложение',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Включить лимит',
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
                      const Text(
                        'Дневной лимит',
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
                    onChanged: (value) =>
                        setSheetState(() => minutes = value.round()),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(
                        _LimitEditResult(minutes: minutes, enabled: enabled),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Сохранить',
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
    final previousStats = _cloneStats();
    setState(() {
      _saving = true;
      _applyLimitLocally(
        packageName: app['package_name'] as String? ?? '',
        appName: app['app_name'] as String? ?? 'Приложение',
        iconB64: app['icon_b64'] as String?,
        enabled: enabled,
        minutes: minutes,
      );
    });
    try {
      await ApiClient.instance.setChildAppLimit(
        childId: widget.childId,
        packageName: app['package_name'] as String? ?? '',
        appName: app['app_name'] as String? ?? 'Приложение',
        dailyLimitMinutes: minutes,
        enabled: enabled,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        enabled ? 'Лимит сохранён.' : 'Лимит отключён.',
        type: AppFeedbackType.success,
      );
      unawaited(_refreshSilently());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stats = previousStats;
      });
      showAppSnackBar(
        context,
        e.toString(),
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleBlock(Map<String, dynamic> app) async {
    if (_saving) return;
    final pkg = app['package_name'] as String? ?? '';
    final name = app['app_name'] as String? ?? 'Приложение';
    if (pkg.isEmpty) return;
    final previousStats = _cloneStats();
    final previousBlockedPackages = Set<String>.from(_blockedPackages);
    final previousBlockedIdByPackage = Map<String, int>.from(_blockedIdByPackage);
    setState(() {
      _saving = true;
      _applyBlockedLocally(
        packageName: pkg,
        blocked: !_blockedPackages.contains(pkg),
      );
    });
    try {
      if (previousBlockedPackages.contains(pkg)) {
        final blockedId = previousBlockedIdByPackage[pkg];
        if (blockedId != null) {
          await ApiClient.instance.unblockApp(widget.childId, blockedId);
        }
      } else {
        await ApiClient.instance.blockApp(
          widget.childId,
          packageName: pkg,
          appName: name,
        );
      }
      if (!mounted) return;
      showAppSnackBar(
        context,
        _blockedPackages.contains(pkg)
            ? '$name заблокировано.'
            : '$name разблокировано.',
        type: AppFeedbackType.success,
      );
      unawaited(_refreshSilently());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stats = previousStats;
        _blockedPackages = previousBlockedPackages;
        _blockedIdByPackage = previousBlockedIdByPackage;
      });
      showAppSnackBar(
        context,
        e.toString(),
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Лимиты на игры',
      subtitle: widget.childName,
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _FeatureHeroCard(
                  childName: widget.childName,
                  avatarUrl: widget.avatarUrl,
                  accent: AppColors.primary,
                  subtitle: 'Управление экранным временем и блокировками',
                  trailing: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _MiniStat(
                      label: 'Сегодня',
                      value: _formatMinutes(_selectedTotal),
                      color: AppColors.primary,
                    ),
                    _MiniStat(
                      label: 'Лимиты',
                      value: _selectedLimit > 0
                          ? _formatMinutes(_selectedLimit)
                          : 'Нет',
                      color: AppColors.success,
                    ),
                    _MiniStat(
                      label: 'Превышено',
                      value: '$_overLimitApps',
                      color: _overLimitApps > 0
                          ? AppColors.danger
                          : AppColors.textMuted,
                    ),
                  ],
                ),
                if (!_usageAccessGranted) ...[
                  const SizedBox(height: 14),
                  const AppCard(
                    child: Text(
                      'На телефоне ребёнка нужно открыть доступ к статистике использования, чтобы видеть реальные данные приложений и управлять лимитами.',
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 16),
                if (_apps.isEmpty)
                  const AppCard(
                    child: Text(
                      'Пока нет данных по приложениям для выбранного ребёнка.',
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  )
                else
                  ..._apps.map(_buildAppCard),
              ],
            ),
    );
  }

  Widget _buildAppCard(Map<String, dynamic> app) {
    final appName = app['app_name'] as String? ?? 'Приложение';
    final packageName = app['package_name'] as String? ?? '';
    final usageMinutes = (app['usage_minutes'] as int?) ?? 0;
    final enabled = (app['limit_enabled'] as bool?) ?? false;
    final exceeded = (app['exceeded'] as bool?) ?? false;
    final dailyLimitMinutes = app['daily_limit_minutes'] as int?;
    final iconB64 = app['icon_b64'] as String?;
    final blocked = _blockedPackages.contains(packageName);
    final accent = blocked
        ? AppColors.danger
        : exceeded
            ? AppColors.warning
            : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          children: [
            Row(
              children: [
                AppIconAvatar(
                  iconB64: iconB64,
                  appName: appName,
                  accent: accent,
                  size: 42,
                  borderRadius: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.success,
                  onChanged: (value) => _toggleLimit(app, value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  color: AppColors.primary,
                  label: _formatMinutes(usageMinutes),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.flag_outlined,
                  color: dailyLimitMinutes != null && enabled
                      ? AppColors.success
                      : AppColors.textMuted,
                  label: dailyLimitMinutes != null && enabled
                      ? 'Лимит ${_formatMinutes(dailyLimitMinutes)}'
                      : 'Без лимита',
                ),
                const Spacer(),
                if (blocked)
                  const Text(
                    'Заблокировано',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editLimit(app),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Изменить лимит',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _toggleBlock(app),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          blocked ? AppColors.success : AppColors.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      blocked ? 'Разблокировать' : 'Блокировать',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0м';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '$remainingMinutesм';
    if (remainingMinutes == 0) return '$hoursч';
    return '$hoursч $remainingMinutesм';
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Map<String, dynamic>? _cloneStats() {
    final stats = _stats;
    if (stats == null) return null;
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(stats)) as Map<String, dynamic>,
    );
  }

  Future<void> _refreshSilently() async {
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        ApiClient.instance.childStatsSummary(
          widget.childId,
          date: now,
          month: DateTime(now.year, now.month),
        ),
        ApiClient.instance.getBlockedApps(widget.childId),
      ]);
      if (!mounted) return;
      final blocked =
          (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _blockedPackages =
            blocked.map((b) => b['package_name'] as String).toSet();
        _blockedIdByPackage = {
          for (final b in blocked) b['package_name'] as String: b['id'] as int,
        };
      });
    } catch (_) {
      // Best effort only. The UI is already updated optimistically.
    }
  }

  void _applyLimitLocally({
    required String packageName,
    required String appName,
    required String? iconB64,
    required bool enabled,
    required int minutes,
  }) {
    if (packageName.trim().isEmpty) return;
    final stats = _cloneStats() ?? <String, dynamic>{};
    final apps = _apps.toList(growable: true);
    final index = apps.indexWhere((app) => app['package_name'] == packageName);
    final nextApp = index >= 0
        ? Map<String, dynamic>.from(apps[index])
        : <String, dynamic>{
            'package_name': packageName,
            'app_name': appName,
            'usage_minutes': 0,
            if (iconB64 != null && iconB64.isNotEmpty) 'icon_b64': iconB64,
          };
    nextApp['app_name'] = appName;
    nextApp['daily_limit_minutes'] = minutes;
    nextApp['limit_enabled'] = enabled;
    nextApp['exceeded'] =
        enabled && ((nextApp['usage_minutes'] as int?) ?? 0) > minutes;
    if (iconB64 != null && iconB64.isNotEmpty) {
      nextApp['icon_b64'] = iconB64;
    }
    if (index >= 0) {
      apps[index] = nextApp;
    } else {
      apps.add(nextApp);
    }
    stats['apps'] = apps;
    _stats = stats;
  }

  void _applyBlockedLocally({
    required String packageName,
    required bool blocked,
  }) {
    final nextBlocked = Set<String>.from(_blockedPackages);
    final nextBlockedIds = Map<String, int>.from(_blockedIdByPackage);
    if (blocked) {
      nextBlocked.add(packageName);
    } else {
      nextBlocked.remove(packageName);
      nextBlockedIds.remove(packageName);
    }
    _blockedPackages = nextBlocked;
    _blockedIdByPackage = nextBlockedIds;
  }
}

class MenuAchievementsScreen extends StatefulWidget {
  const MenuAchievementsScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.avatarUrl,
  });

  final int childId;
  final String childName;
  final String? avatarUrl;

  @override
  State<MenuAchievementsScreen> createState() => _MenuAchievementsScreenState();
}

class _MenuAchievementsScreenState extends State<MenuAchievementsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _rewards = [];
  Map<String, dynamic> _stars = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  int get _earnedStars => (_stars['total_earned'] as int?) ?? 0;
  int get _balanceStars => (_stars['balance'] as int?) ?? 0;
  int get _pendingTasks =>
      _tasks.where((task) => (task['status'] as String?) == 'pending').length;
  int get _completedTasks =>
      _tasks.where((task) => (task['status'] as String?) == 'completed').length;
  int get _approvedTasks =>
      _tasks.where((task) => (task['status'] as String?) == 'approved').length;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiClient.instance.getTasks(widget.childId),
        ApiClient.instance.getRewards(widget.childId),
        ApiClient.instance.getStars(widget.childId),
      ]);
      if (!mounted) return;
      setState(() {
        _tasks = (results[0] as List<dynamic>).cast<Map<String, dynamic>>();
        _rewards = (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
        _stars = results[2] as Map<String, dynamic>;
        _loading = false;
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
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Достижения ребёнка',
      subtitle: widget.childName,
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.rewardsGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.24),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AvatarCircle(
                        size: 56,
                        initials: widget.childName.isNotEmpty
                            ? widget.childName[0].toUpperCase()
                            : '?',
                        color: Colors.white,
                        image: avatarImageProvider(widget.avatarUrl),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.childName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Звёзды, задачи и доступные награды',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_earnedStars',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'заработано',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _MiniStat(
                      label: 'Баланс',
                      value: '$_balanceStars',
                      color: AppColors.primary,
                    ),
                    _MiniStat(
                      label: 'Задач ждёт',
                      value: '$_pendingTasks',
                      color: AppColors.warning,
                    ),
                    _MiniStat(
                      label: 'Одобрено',
                      value: '$_approvedTasks',
                      color: AppColors.success,
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Задачи',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                if (_tasks.isEmpty)
                  const AppCard(
                    child: Text(
                      'Пока задач нет.',
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  )
                else
                  ..._tasks.take(8).map(_buildTaskCard),
                const SizedBox(height: 18),
                const Text(
                  'Награды',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                if (_rewards.isEmpty)
                  const AppCard(
                    child: Text(
                      'Пока наград нет.',
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  )
                else
                  ..._rewards.take(8).map(_buildRewardCard),
                if (_completedTasks > 0) ...[
                  const SizedBox(height: 14),
                  AppCard(
                    child: Text(
                      'Выполнено, ждёт подтверждения: $_completedTasks',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] as String? ?? 'pending';
    final statusData = switch (status) {
      'approved' => ('Одобрено', AppColors.success),
      'completed' => ('Ждёт одобрения', AppColors.warning),
      _ => ('В процессе', AppColors.primary),
    };
    final rewardStars = (task['reward_stars'] as int?) ?? 0;
    final title = task['title'] as String? ?? 'Задача';
    final description = task['description'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                StatusBadge(text: statusData.$1, color: statusData.$2),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              '+$rewardStars звёзд',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final claimed = (reward['claimed'] as bool?) ?? false;
    final title = reward['title'] as String? ?? 'Награда';
    final requiredStars = (reward['required_stars'] as int?) ?? 0;
    final claimedAt = DateTime.tryParse(reward['claimed_at'] as String? ?? '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (claimed ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                claimed ? Icons.check_rounded : Icons.card_giftcard_rounded,
                color: claimed ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    claimed && claimedAt != null
                        ? 'Достигнуто ${claimedAt.day.toString().padLeft(2, '0')}.${claimedAt.month.toString().padLeft(2, '0')}.${claimedAt.year}'
                        : 'Нужно $requiredStars звёзд',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              text: claimed ? 'Достигнуто' : 'Доступна',
              color: claimed ? AppColors.success : AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuLoudSignalScreen extends StatefulWidget {
  const MenuLoudSignalScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.avatarUrl,
  });

  final int childId;
  final String childName;
  final String? avatarUrl;

  @override
  State<MenuLoudSignalScreen> createState() => _MenuLoudSignalScreenState();
}

class _MenuLoudSignalScreenState extends State<MenuLoudSignalScreen> {
  bool _loading = true;
  bool _active = false;
  bool _saving = false;
  String? _error;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Map<String, dynamic> get _device {
    final value = _stats?['device'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final summary = await ApiClient.instance.childStatsSummary(
        widget.childId,
        date: now,
        month: DateTime(now.year, now.month),
      );
      if (!mounted) return;
      setState(() {
        _stats = summary;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _toggle() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_active) {
        await ApiClient.instance.stopLoud(widget.childId);
      } else {
        await ApiClient.instance.triggerLoud(widget.childId);
      }
      if (!mounted) return;
      setState(() {
        _active = !_active;
      });
      showAppSnackBar(
        context,
        _active
            ? S.of(context).loudSignalSent(widget.childName)
            : 'Громкий сигнал остановлен.',
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      showAppSnackBar(
        context,
        e.toString(),
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final battery = (_device['battery'] as int?) ?? 0;
    final charging = (_device['charging'] as bool?) ?? false;
    final isActive = (_device['active'] as bool?) ?? false;

    return _FeatureScaffold(
      title: 'Громкий сигнал',
      subtitle: widget.childName,
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _FeatureHeroCard(
                  childName: widget.childName,
                  avatarUrl: widget.avatarUrl,
                  accent: _active ? AppColors.danger : AppColors.primary,
                  subtitle: _active
                      ? 'Сейчас на устройстве включён громкий сигнал'
                      : 'Отправьте сигнал, чтобы ребёнок быстро нашёл телефон',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _MiniStat(
                      label: 'Связь',
                      value: isActive ? 'Онлайн' : 'Офлайн',
                      color: isActive ? AppColors.success : AppColors.danger,
                    ),
                    _MiniStat(
                      label: 'Батарея',
                      value: battery > 0 ? '$battery%' : 'Нет',
                      color: AppColors.primary,
                    ),
                    _MiniStat(
                      label: 'Зарядка',
                      value: charging ? 'Да' : 'Нет',
                      color: charging ? AppColors.success : AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _active
                            ? 'Сигнал уже отправлен'
                            : 'Отправить громкий звуковой сигнал',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _active
                            ? 'Если ребёнок уже нашёл телефон, вы можете сразу остановить сигнал.'
                            : 'Полезно, когда телефон рядом, но его не видно или он в беззвучном режиме.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.textSecondaryLight,
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _toggle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _active ? AppColors.danger : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: Icon(
                            _active
                                ? Icons.stop_circle_outlined
                                : Icons.notifications_active_outlined,
                          ),
                          label: Text(
                            _active ? 'Остановить сигнал' : 'Включить сигнал',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _FeatureScaffold extends StatelessWidget {
  const _FeatureScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final body = onRefresh == null
        ? child
        : RefreshIndicator(
            onRefresh: onRefresh!,
            child: child,
          );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _FeatureHeroCard extends StatelessWidget {
  const _FeatureHeroCard({
    required this.childName,
    required this.accent,
    this.avatarUrl,
    this.subtitle,
    this.trailing,
  });

  final String childName;
  final Color accent;
  final String? avatarUrl;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          AvatarCircle(
            size: 56,
            initials: childName.isNotEmpty ? childName[0].toUpperCase() : '?',
            color: accent,
            image: avatarImageProvider(avatarUrl),
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
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
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

class _LimitEditResult {
  const _LimitEditResult({
    required this.minutes,
    required this.enabled,
  });

  final int minutes;
  final bool enabled;
}

String formatMenuDate(DateTime date) {
  return DateFormat('d MMM, HH:mm').format(date);
}

class AppIconAvatar extends StatelessWidget {
  const AppIconAvatar({
    super.key,
    required this.iconB64,
    required this.appName,
    required this.accent,
    this.size = 42,
    this.borderRadius = 14,
  });

  final String? iconB64;
  final String appName;
  final Color accent;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bytes = _decode(iconB64);
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        appName.isNotEmpty ? appName[0].toUpperCase() : 'A',
        style: TextStyle(
          color: accent,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static Uint8List? _decode(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }
}
