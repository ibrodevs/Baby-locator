import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import 'adaptive_map.dart';
import 'map_models.dart';

enum _HistoryRange { today, yesterday, week }

class MovementHistoryScreen extends StatefulWidget {
  const MovementHistoryScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.avatarUrl,
  });

  final int childId;
  final String childName;
  final String? avatarUrl;

  @override
  State<MovementHistoryScreen> createState() => _MovementHistoryScreenState();
}

class _MovementHistoryScreenState extends State<MovementHistoryScreen> {
  static const Color _pathColor = Color(0xFF1C62F0);
  static const Duration _playbackTick = Duration(milliseconds: 600);

  bool _loading = true;
  String? _error;
  List<_HistoryPoint> _all = const [];
  List<_HistoryPoint> _filtered = const [];
  int _currentIndex = 0;
  _HistoryRange _range = _HistoryRange.today;
  bool _playing = false;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ApiClient.instance.childHistory(widget.childId);
      final points = <_HistoryPoint>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final lat = (item['lat'] as num?)?.toDouble();
        final lng = (item['lng'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;
        final ts = DateTime.tryParse(item['created_at'] as String? ?? '');
        if (ts == null) continue;
        points.add(_HistoryPoint(
          lat: lat,
          lng: lng,
          timestamp: ts.toLocal(),
          address: (item['address'] as String?)?.trim() ?? '',
          battery: (item['battery'] as int?) ?? 0,
          charging: (item['charging'] as bool?) ?? false,
        ));
      }
      points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      if (!mounted) return;
      setState(() {
        _all = points;
        _loading = false;
        _applyRange(_range);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _applyRange(_HistoryRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime from;
    DateTime to;
    switch (range) {
      case _HistoryRange.today:
        from = today;
        to = today.add(const Duration(days: 1));
        break;
      case _HistoryRange.yesterday:
        from = today.subtract(const Duration(days: 1));
        to = today;
        break;
      case _HistoryRange.week:
        from = today.subtract(const Duration(days: 6));
        to = today.add(const Duration(days: 1));
        break;
    }
    final filtered = _all
        .where((p) => !p.timestamp.isBefore(from) && p.timestamp.isBefore(to))
        .toList(growable: false);
    _range = range;
    _filtered = filtered;
    _currentIndex = filtered.isEmpty ? 0 : filtered.length - 1;
    _stopPlayback();
  }

  void _onRangeChanged(_HistoryRange range) {
    setState(() => _applyRange(range));
  }

  void _togglePlayback() {
    if (_filtered.length < 2) return;
    if (_playing) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    if (_currentIndex >= _filtered.length - 1) {
      _currentIndex = 0;
    }
    _playing = true;
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(_playbackTick, (_) {
      if (!mounted) return;
      setState(() {
        if (_currentIndex >= _filtered.length - 1) {
          _stopPlayback();
        } else {
          _currentIndex += 1;
        }
      });
    });
    setState(() {});
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    _playing = false;
  }

  ChildLocation _markerForCurrent() {
    final p = _filtered[_currentIndex];
    return ChildLocation(
      name: widget.childName,
      lat: p.lat,
      lng: p.lng,
      address: p.address,
      battery: p.battery,
      charging: p.charging,
      updatedAt: p.timestamp,
      active: true,
      childId: widget.childId,
      avatarUrl: widget.avatarUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              childName: widget.childName,
              onClose: () => Navigator.of(context).maybePop(),
              onRefresh: _loading ? null : _load,
            ),
            _RangeBar(value: _range, onChanged: _onRangeChanged),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _load);
    }
    if (_filtered.isEmpty) {
      return const _EmptyView();
    }

    final current = _filtered[_currentIndex];
    final marker = _markerForCurrent();

    // Traveled portion (blue) — from start up to and including current point.
    final traveledPath = [
      for (final p in _filtered.sublist(0, _currentIndex + 1))
        MapLatLng(p.lat, p.lng),
    ];
    // Remaining portion (gray ghost) — from current point to end.
    final remainingPath = _currentIndex < _filtered.length - 1
        ? [
            for (final p in _filtered.sublist(_currentIndex))
              MapLatLng(p.lat, p.lng),
          ]
        : const <MapLatLng>[];

    final mapCenter = MapLatLng(current.lat, current.lng);

    return Stack(
      children: [
        Positioned.fill(
          child: AdaptiveMap(
            latitude: mapCenter.latitude,
            longitude: mapCenter.longitude,
            children: [marker],
            ghostPath: remainingPath,
            path: traveledPath,
            pathColor: _pathColor,
            pathWidth: 6,
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 12,
          child: _CurrentPointCard(point: current, total: _filtered.length, index: _currentIndex),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _SliderPanel(
            points: _filtered,
            index: _currentIndex,
            playing: _playing,
            onChanged: (v) {
              setState(() {
                _currentIndex = v;
              });
            },
            onChangeStart: (_) => _stopPlayback(),
            onTogglePlay: _togglePlayback,
          ),
        ),
      ],
    );
  }
}

class _HistoryPoint {
  const _HistoryPoint({
    required this.lat,
    required this.lng,
    required this.timestamp,
    required this.address,
    required this.battery,
    required this.charging,
  });

  final double lat;
  final double lng;
  final DateTime timestamp;
  final String address;
  final int battery;
  final bool charging;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.childName,
    required this.onClose,
    required this.onRefresh,
  });

  final String childName;
  final VoidCallback onClose;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.movementHistoryScreenTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  childName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.value, required this.onChanged});

  final _HistoryRange value;
  final ValueChanged<_HistoryRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          _chip(t.today, _HistoryRange.today),
          const SizedBox(width: 8),
          _chip(t.yesterdayLabel, _HistoryRange.yesterday),
          const SizedBox(width: 8),
          _chip(t.last7DaysLabel, _HistoryRange.week),
        ],
      ),
    );
  }

  Widget _chip(String label, _HistoryRange r) {
    final selected = value == r;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.dividerLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentPointCard extends StatelessWidget {
  const _CurrentPointCard({
    required this.point,
    required this.total,
    required this.index,
  });

  final _HistoryPoint point;
  final int total;
  final int index;

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('d MMM, HH:mm');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timeline_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeFmt.format(point.timestamp),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  point.address.isEmpty
                      ? '${point.lat.toStringAsFixed(5)}, ${point.lng.toStringAsFixed(5)}'
                      : point.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.chipGrey,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${index + 1}/$total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderPanel extends StatelessWidget {
  const _SliderPanel({
    required this.points,
    required this.index,
    required this.playing,
    required this.onChanged,
    required this.onChangeStart,
    required this.onTogglePlay,
  });

  final List<_HistoryPoint> points;
  final int index;
  final bool playing;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeStart;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final canPlay = points.length >= 2;
    final first = points.first.timestamp;
    final last = points.last.timestamp;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: canPlay ? onTogglePlay : null,
                icon: Icon(
                  playing
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 40,
                  color: canPlay ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.dividerLight,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.18),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    min: 0,
                    max: (points.length - 1).toDouble().clamp(0, double.infinity),
                    value: index.toDouble().clamp(
                          0,
                          (points.length - 1).toDouble(),
                        ),
                    divisions: points.length > 1 ? points.length - 1 : null,
                    onChangeStart: (v) => onChangeStart(v.round()),
                    onChanged: points.length < 2
                        ? null
                        : (v) => onChanged(v.round()),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              children: [
                Text(
                  timeFmt.format(first),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  timeFmt.format(last),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timeline_rounded,
                size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              t.noMovementDataForPeriod,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(t.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
