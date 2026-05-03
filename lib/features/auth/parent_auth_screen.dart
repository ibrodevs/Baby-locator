import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';
import '../root/root_screen.dart';

class ParentAuthScreen extends ConsumerStatefulWidget {
  const ParentAuthScreen({super.key});

  @override
  ConsumerState<ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends ConsumerState<ParentAuthScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrapParentFlow();
  }

  Future<void> _bootstrapParentFlow() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = ref.read(sessionProvider);
      if (session.user?.role != UserRole.parent) {
        await _registerHiddenParent();
      }
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _registerHiddenParent() async {
    final random = Random.secure();
    for (var attempt = 0; attempt < 5; attempt++) {
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final username = 'parent_${timestamp}_${random.nextInt(9999)}';
      final password =
          'p${random.nextInt(1 << 32)}_${timestamp.toRadixString(16)}';

      try {
        await ref.read(sessionProvider.notifier).registerParent(
              username: username,
              password: password,
            );
        return;
      } catch (_) {
        if (attempt == 4) rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Подготавливаем сценарий для родителя...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Не удалось открыть сценарий родителя.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _bootstrapParentFlow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Повторить',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const RootScreen();
  }
}
