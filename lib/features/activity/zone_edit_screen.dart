import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/session_providers.dart';
import '../../core/providers/zone_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/brand_header.dart';
import '../map/adaptive_map.dart';

class ZoneEditScreen extends ConsumerStatefulWidget {
  const ZoneEditScreen({super.key, this.zone});
  final SafeZone? zone;

  @override
  ConsumerState<ZoneEditScreen> createState() => _ZoneEditScreenState();
}

class _ZoneEditScreenState extends ConsumerState<ZoneEditScreen> {
  late final TextEditingController _nameController;
  late double _radius;
  late double _lat;
  late double _lng;
  late bool _active;
  late String _scheduleType;
  late Set<int> _selectedDays;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.zone?.name ?? '');
    _radius = widget.zone?.radius ?? 200.0;
    _active = widget.zone?.active ?? true;
    _scheduleType = widget.zone?.scheduleType ?? SafeZone.scheduleAlways;
    _selectedDays = {...?widget.zone?.activeDays};

    // Initial position: zone's pos or first child's pos or default
    _lat = widget.zone?.lat ?? 0;
    _lng = widget.zone?.lng ?? 0;

    if (_lat == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final children = ref.read(allChildrenLocationsProvider);
        if (children.isNotEmpty) {
          setState(() {
            _lat = children.first.lat;
            _lng = children.first.lng;
          });
        } else {
          setState(() {
            _lat = 55.7558; // Moscow default
            _lng = 37.6173;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = S.of(context);
    if (_nameController.text.isEmpty) {
      showAppSnackBar(
        context,
        t.pleaseEnterZoneName,
        type: AppFeedbackType.warning,
      );
      return;
    }
    if (_scheduleType == SafeZone.scheduleDays && _selectedDays.isEmpty) {
      showAppSnackBar(
        context,
        t.chooseAtLeastOneDayError,
        type: AppFeedbackType.warning,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      if (widget.zone == null) {
        await ref.read(safeZonesProvider.notifier).addZone(
              name: _nameController.text,
              lat: _lat,
              lng: _lng,
              radius: _radius,
              active: _active,
              scheduleType: _scheduleType,
              activeDays: _selectedDays.toList()..sort(),
            );
      } else {
        await ref.read(safeZonesProvider.notifier).updateZone(
              widget.zone!.id,
              name: _nameController.text,
              lat: _lat,
              lng: _lng,
              radius: _radius,
              active: _active,
              scheduleType: _scheduleType,
              activeDays: _selectedDays.toList()..sort(),
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          t.failedGeneric(e.toString()),
          type: AppFeedbackType.error,
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.zone == null ? t.addSafeZone : t.editSafeZone),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        actions: [
          if (widget.zone != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final confirm = await showAppConfirmDialog(
                  context: context,
                  title: t.deleteZoneTitle,
                  message: t.deleteZoneMessage,
                  confirmLabel: t.delete,
                  cancelLabel: t.cancel,
                  type: AppFeedbackType.error,
                );
                if (confirm == true) {
                  setState(() => _loading = true);
                  await ref
                      .read(safeZonesProvider.notifier)
                      .deleteZone(widget.zone!.id);
                  if (!mounted) return;
                  navigator.pop();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.zoneEnabled,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Switch(
                              value: _active,
                              activeThumbColor: AppColors.primary,
                              onChanged: (value) =>
                                  setState(() => _active = value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(t.zoneName,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5)),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: t.zoneNameHint,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.activeWhen,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(t.always),
                              selected:
                                  _scheduleType == SafeZone.scheduleAlways,
                              selectedColor: AppColors.primarySoft,
                              labelStyle: TextStyle(
                                color: _scheduleType == SafeZone.scheduleAlways
                                    ? AppColors.primary
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                              onSelected: (_) => setState(() {
                                _scheduleType = SafeZone.scheduleAlways;
                              }),
                            ),
                            ChoiceChip(
                              label: Text(t.daysOfWeek),
                              selected: _scheduleType == SafeZone.scheduleDays,
                              selectedColor: AppColors.primarySoft,
                              labelStyle: TextStyle(
                                color: _scheduleType == SafeZone.scheduleDays
                                    ? AppColors.primary
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                              onSelected: (_) => setState(() {
                                _scheduleType = SafeZone.scheduleDays;
                                _selectedDays = _selectedDays.isEmpty
                                    ? {1, 2, 3, 4, 5}
                                    : _selectedDays;
                              }),
                            ),
                          ],
                        ),
                        if (_scheduleType == SafeZone.scheduleDays) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [1, 2, 3, 4, 5, 6, 7].map((day) {
                              final selected = _selectedDays.contains(day);
                              final label = switch (day) {
                                1 => t.mon,
                                2 => t.tue,
                                3 => t.wed,
                                4 => t.thu,
                                5 => t.fri,
                                6 => t.sat,
                                7 => t.sun,
                                _ => day.toString(),
                              };
                              return FilterChip(
                                label: Text(label),
                                selected: selected,
                                selectedColor: AppColors.primarySoft,
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    if (value) {
                                      _selectedDays.add(day);
                                    } else {
                                      _selectedDays.remove(day);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          if (_selectedDays.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                t.chooseAtLeastOneDay,
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t.radius,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted,
                                    letterSpacing: 0.5)),
                            Text('${_radius.toInt()} m',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary)),
                          ],
                        ),
                        Slider(
                          value: _radius,
                          min: 100,
                          max: 1000,
                          divisions: 18,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.primarySoft,
                          onChanged: (v) => setState(() => _radius = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(t.locationMoveMap,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        if (_lat != 0)
                          AdaptiveMap(
                            latitude: _lat,
                            longitude: _lng,
                            onCameraMove: (lat, lng) {
                              _lat = lat;
                              _lng = lng;
                            },
                          ),
                        // Center Pin
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            child: const Icon(Icons.location_on,
                                size: 48, color: AppColors.primary),
                          ),
                        ),
                        // Radius Preview (Simplified)
                        Center(
                          child: Container(
                            width: _radius * 0.4, // Visual estimation
                            height: _radius * 0.4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.15),
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 10)
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    t.moveMapToSetCenter,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text(
                          widget.zone == null
                              ? t.createSafeZone
                              : t.updateSafeZone,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
