import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_language_sheet.dart';
import 'parent_auth_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.replaceAll(RegExp(r'\D'), '');
    if (code.isEmpty) {
      setState(() => _error = 'Введите код.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref.read(sessionProvider.notifier).registerChild(code: code);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Не удалось войти по коду: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openParentLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ParentAuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          Positioned(
            left: -40,
            top: 80,
            child: _BlurOrb(
              size: 180,
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            right: -30,
            bottom: 140,
            child: _BlurOrb(
              size: 220,
              color: AppColors.accent.withValues(alpha: 0.12),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    18,
                    24,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: AppLanguageButton(compact: true),
                        ),
                        const SizedBox(height: 36),
                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: AppColors.rewardsGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.24),
                                  blurRadius: 26,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_open_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Введите код',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ребёнку не нужен пароль. Достаточно ввести код, который прислал родитель.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: _error == null
                                  ? AppColors.dividerLight
                                  : AppColors.danger,
                            ),
                          ),
                          child: TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 10,
                              color: AppColors.navy,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '000000',
                              hintStyle: TextStyle(
                                letterSpacing: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                            onSubmitted: (_) {
                              if (!_busy) {
                                _submitCode();
                              }
                            },
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _submitCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _busy
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Войти по коду',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: _busy ? null : _openParentLogin,
                          child: const Text(
                            'Войти как родитель',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: AppColors.primary),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Сначала родитель настраивает профиль ребёнка, фото и дом. После этого ребёнок просто вводит код и сразу попадает в готовый аккаунт.',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.01),
          ],
        ),
      ),
    );
  }
}
