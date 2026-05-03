import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/services/local_avatar_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/brand_header.dart';
import '../auth/parent_setup_flow_screen.dart';

class ChildrenListScreen extends ConsumerStatefulWidget {
  const ChildrenListScreen({super.key});
  @override
  ConsumerState<ChildrenListScreen> createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends ConsumerState<ChildrenListScreen> {
  List<dynamic> _children = [];
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final list = await ApiClient.instance.listChildren();
      ref.read(parentChildrenProvider.notifier).setFromList(list);
      final normalized = ref.read(parentChildrenProvider);
      final selectedChildId = ref.read(selectedChildIdProvider);
      setState(() {
        _children = normalized;
        _loading = false;
      });
      if (selectedChildId != null &&
          !list.any((child) => child['id'] == selectedChildId)) {
        ref.read(selectedChildIdProvider.notifier).state =
            list.isEmpty ? null : list.first['id'] as int;
      }
    } catch (e) {
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  void _selectAndClose(int id) {
    ref.read(selectedChildIdProvider.notifier).state = id;
    Navigator.of(context).pop();
  }

  Future<void> _editChild(Map<String, dynamic> child) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditChildSheet(child: child),
    );
    if (result == true) _load();
  }

  Future<void> _inviteChild() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ParentSetupFlowScreen(
          onFinished: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _deleteChild(Map<String, dynamic> child) async {
    final t = S.of(context);
    final name = ((child['display_name'] as String?)?.isNotEmpty ?? false)
        ? child['display_name'] as String
        : child['username'] as String;
    final confirm = await showAppConfirmDialog(
      context: context,
      title: t.deleteChildTitle,
      message: t.deleteChildMessage(name),
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      type: AppFeedbackType.error,
    );

    if (confirm != true) return;

    try {
      await ApiClient.instance.deleteChild(child['id'] as int);
      await _load();
      if (!mounted) return;
      showAppSnackBar(
        context,
        t.childDeleted(name),
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        t.failedToDeleteChild(e.toString()),
        type: AppFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(t.myChildren),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _inviteChild,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          t.addChild,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (_err != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 56),
                      child: Text(
                        _err!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    )
                  else ...[
                    if (_children.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(t.noChildrenYet,
                              textAlign: TextAlign.center),
                        ),
                      )
                    else
                      ...List.generate(_children.length, (i) {
                        final c = _children[i] as Map<String, dynamic>;
                        final id = c['id'] as int;
                        final name =
                            (c['display_name'] as String?)?.isNotEmpty == true
                                ? c['display_name'] as String
                                : c['username'] as String;
                        final avatarUrl = c['avatar_url'] as String?;
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: i < _children.length - 1 ? 10 : 0),
                          child: AppCard(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    AvatarCircle(
                                      initials: name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      size: 40,
                                      color: AppColors.primary,
                                      image: avatarImageProvider(avatarUrl),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(name,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _editChild(c),
                                      icon: const Icon(Icons.edit_outlined,
                                          color: AppColors.textSecondaryLight),
                                      tooltip: t.edit,
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      onPressed: () => _deleteChild(c),
                                      icon: const Icon(Icons.delete_outline,
                                          color: AppColors.danger),
                                      tooltip: t.delete,
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () => _selectAndClose(id),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      child: Text(t.track,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ],
              ),
            ),
    );
  }
}

class _EditChildSheet extends StatefulWidget {
  const _EditChildSheet({required this.child});
  final Map<String, dynamic> child;
  @override
  State<_EditChildSheet> createState() => _EditChildSheetState();
}

class _EditChildSheetState extends State<_EditChildSheet> {
  late final TextEditingController _name;
  bool _busy = false;
  String? _err;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
        text: widget.child['display_name'] as String? ?? '');
    _avatarUrl = widget.child['avatar_url'] as String?;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (picked == null) return;
    setState(() => _busy = true);
    try {
      final childId = widget.child['id'] as int;
      final path = await LocalAvatarStore.instance
          .saveChildAvatar(childId, File(picked.path));
      setState(() {
        _avatarUrl = path;
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _err = e.toString();
        _busy = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final childId = widget.child['id'] as int;
      await ApiClient.instance
          .updateChild(childId, displayName: _name.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _err = e.toString();
        _busy = false;
      });
    }
  }

  Future<void> _delete() async {
    final t = S.of(context);
    final navigator = Navigator.of(context);
    final name = (_name.text.trim().isNotEmpty
        ? _name.text.trim()
        : '@${widget.child['username']}');
    final confirm = await showAppConfirmDialog(
      context: context,
      title: t.deleteChildTitle,
      message: t.deleteChildMessage(name),
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      type: AppFeedbackType.error,
    );
    if (confirm != true) return;

    setState(() {
      _busy = true;
      _err = null;
    });

    try {
      await ApiClient.instance.deleteChild(widget.child['id'] as int);
      if (!mounted) return;
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _err = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final username = widget.child['username'] as String? ?? '';
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.editChildProfile,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('@$username',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _busy ? null : _pickAvatar,
              child: Stack(
                children: [
                  AvatarCircle(
                    initials: _name.text.isNotEmpty
                        ? _name.text[0].toUpperCase()
                        : '?',
                    size: 80,
                    color: AppColors.primary,
                    image: avatarImageProvider(_avatarUrl),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _busy ? null : _pickAvatar,
              child: Text(t.changePhoto,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          _F(controller: _name, label: t.displayName),
          if (_err != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_err!,
                  style:
                      const TextStyle(color: AppColors.danger, fontSize: 13)),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _busy ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(t.save,
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _busy ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(
              t.deleteChild,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _F extends StatelessWidget {
  const _F({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerLight)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerLight)),
      ),
    );
  }
}
