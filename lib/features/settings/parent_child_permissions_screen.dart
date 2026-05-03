import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:kid_security/l10n/app_localizations_extras.dart';

import '../../core/services/api_client.dart';
import '../../core/services/local_avatar_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';

class ParentChildPermissionsScreen extends StatefulWidget {
  const ParentChildPermissionsScreen({super.key});

  @override
  State<ParentChildPermissionsScreen> createState() =>
      _ParentChildPermissionsScreenState();
}

class _ParentChildPermissionsScreenState
    extends State<ParentChildPermissionsScreen> {
  bool _loadingChildren = true;
  bool _loadingDetails = false;
  String? _error;
  List<Map<String, dynamic>> _children = [];
  int? _selectedChildId;
  Map<String, dynamic>? _device;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChildren());
  }

  Future<void> _loadChildren() async {
    setState(() {
      _loadingChildren = true;
      _error = null;
    });
    try {
      final children = (await ApiClient.instance.listChildren())
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
      final selectedId = children.isEmpty
          ? null
          : (_selectedChildId != null &&
                  children.any((child) => child['id'] == _selectedChildId))
              ? _selectedChildId
              : children.first['id'] as int;
      if (!mounted) return;
      setState(() {
        _children = children;
        _selectedChildId = selectedId;
        _loadingChildren = false;
      });
      if (selectedId != null) {
        await _loadDetails(selectedId);
      } else if (mounted) {
        setState(() => _device = null);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingChildren = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadDetails(int childId) async {
    setState(() {
      _loadingDetails = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final summary = await ApiClient.instance.childStatsSummary(
        childId,
        date: now,
        month: DateTime(now.year, now.month),
      );
      final device = summary['device'];
      if (!mounted) return;
      setState(() {
        _selectedChildId = childId;
        _device = device is Map<String, dynamic>
            ? device
            : device is Map
                ? Map<String, dynamic>.from(device)
                : <String, dynamic>{};
        _loadingDetails = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingDetails = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final tx = ExtraL10n.of(context);
    final selectedChild = _children.cast<Map<String, dynamic>?>().firstWhere(
          (child) => child?['id'] == _selectedChildId,
          orElse: () => null,
        );
    final childName =
        ((selectedChild?['display_name'] as String?)?.trim().isNotEmpty ??
                false)
            ? selectedChild!['display_name'] as String
            : selectedChild?['username'] as String? ?? tx.childLabel;
    final avatarUrl = resolveChildAvatar(
      selectedChild?['id'] as int?,
      selectedChild?['avatar_url'] as String?,
    );
    final syncedAt = _device?['last_sync_at'] as String?;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryLight,
        title: Text(
          tx.childPermissionsTitle,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _loadChildren,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loadingChildren
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (_children.isEmpty)
                  AppCard(
                    child: Text(
                      tx.addChildToSeePermissions,
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _children.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final child = _children[index];
                        final id = child['id'] as int;
                        final name = ((child['display_name'] as String?)
                                    ?.trim()
                                    .isNotEmpty ??
                                false)
                            ? child['display_name'] as String
                            : child['username'] as String;
                        final selected = id == _selectedChildId;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(name),
                          onSelected: (_) => _loadDetails(id),
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.14),
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimaryLight,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.dividerLight,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Row(
                      children: [
                        AvatarCircle(
                          initials: childName.isNotEmpty
                              ? childName[0].toUpperCase()
                              : '?',
                          size: 54,
                          color: AppColors.primary,
                          image: avatarImageProvider(avatarUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                childName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                syncedAt == null
                                    ? tx.statusesNotSyncedYet
                                    : tx.lastSyncAt(_formatDateTime(syncedAt)),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_loadingDetails)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    _PermissionTile(
                      title: tx.locationEnabledTitle,
                      description: tx.locationEnabledDescription,
                      granted:
                          (_device?['location_service_enabled'] as bool?) ??
                              false,
                    ),
                    _PermissionTile(
                      title: tx.locationPermissionTitle,
                      description: tx.locationPermissionDescription,
                      granted:
                          (_device?['location_permission_granted'] as bool?) ??
                              false,
                    ),
                    _PermissionTile(
                      title: tx.backgroundLocationTitle,
                      description: tx.backgroundLocationDescription,
                      granted:
                          (_device?['background_location_granted'] as bool?) ??
                              false,
                    ),
                    _PermissionTile(
                      title: t.notifications,
                      description: tx.notificationsCommandsDescription,
                      granted:
                          (_device?['notifications_granted'] as bool?) ?? false,
                    ),
                    _PermissionTile(
                      title: tx.microphoneTitle,
                      description: tx.aroundAudioDescription,
                      granted:
                          (_device?['microphone_granted'] as bool?) ?? false,
                    ),
                    _PermissionTile(
                      title: t.allowUsageAccess,
                      description: tx.usageAccessDescriptionParent,
                      granted:
                          (_device?['usage_access_granted'] as bool?) ?? false,
                    ),
                    _PermissionTile(
                      title: t.enableAccessibilityService,
                      description: tx.accessibilityDescriptionParent,
                      granted:
                          (_device?['accessibility_enabled'] as bool?) ?? false,
                    ),
                    _PermissionTile(
                      title: tx.noBatteryRestrictionsTitle,
                      description: tx.noBatteryRestrictionsDescription,
                      granted: (_device?['battery_optimization_disabled']
                              as bool?) ??
                          false,
                    ),
                  ],
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
              ],
            ),
    );
  }

  String _formatDateTime(String rawValue) {
    final dateTime = DateTime.tryParse(rawValue)?.toLocal();
    if (dateTime == null) return rawValue;
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.day)}.${twoDigits(dateTime.month)}.${dateTime.year} '
        '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.title,
    required this.description,
    required this.granted,
  });

  final String title;
  final String description;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final color = granted ? AppColors.success : AppColors.warning;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                granted ? Icons.check_rounded : Icons.error_outline_rounded,
                color: color,
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
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              text: granted
                  ? ExtraL10n.of(context).allowedLabel
                  : ExtraL10n.of(context).notAllowedLabel,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
