import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kid_security/l10n/app_localizations.dart';

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_language_sheet.dart';
import '../child/child_root_screen.dart';
import 'parent_auth_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  bool _busy = false;
  String? _error;

  late final AnimationController _entryController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final t = S.of(context);
    final code = _codeController.text.replaceAll(RegExp(r'\D'), '');
    if (code.isEmpty) {
      setState(() => _error = _enterInviteCodeError(context));
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref.read(sessionProvider.notifier).registerChild(code: code);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ChildRootScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = t.invalidInviteCode);
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
    final t = S.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
              color: AppColors.primary.withValues(alpha: 0.1),
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
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              alignment: Alignment.centerRight,
                              child: AppLanguageButton(compact: true),
                            ),
                            const SizedBox(height: 40),
                            Center(
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: AppColors.rewardsGradient,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.24),
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
                            const SizedBox(height: 32),
                            Text(
                              t.childRegisterTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.childRegisterSubtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                                    : Text(
                                        t.signIn,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 58,
                              child: ElevatedButton(
                                onPressed: _busy ? null : _openParentLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  _signInAsParent(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
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

String _enterInviteCodeError(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return switch (code) {
    'ar' => 'أدخل رمز الدعوة',
    'az' => 'Dəvət kodunu daxil edin',
    'de' => 'Gib den Einladungscode ein',
    'es' => 'Introduce el código de invitación',
    'fr' => "Saisissez le code d'invitation",
    'hy' => 'Մուտքագրեք հրավերի կոդը',
    'it' => 'Inserisci il codice di invito',
    'ka' => 'შეიყვანეთ მოსაწვევის კოდი',
    'kk' => 'Шақыру кодын енгізіңіз',
    'ky' => 'Чакыруу кодун киргизиңиз',
    'pl' => 'Wpisz kod zaproszenia',
    'pt' => 'Digite o código de convite',
    'ru' => 'Введите код приглашения',
    'tg' => 'Рамзи даъватро ворид кунед',
    'tk' => 'Çakylyk koduny giriziň',
    'uz' => 'Taklif kodini kiriting',
    _ => 'Enter the invite code',
  };
}

String _signInAsParent(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return switch (code) {
    'ar' => 'تسجيل الدخول كوالد',
    'az' => 'Valideyn kimi daxil ol',
    'de' => 'Als Elternteil anmelden',
    'es' => 'Iniciar sesión como padre',
    'fr' => 'Se connecter en tant que parent',
    'hy' => 'Մուտք գործել որպես ծնող',
    'it' => 'Accedi come genitore',
    'ka' => 'შესვლა როგორც მშობელი',
    'kk' => 'Ата-ана ретінде кіру',
    'ky' => 'Ата-эне катары кирүү',
    'pl' => 'Zaloguj się jako rodzic',
    'pt' => 'Entrar como responsável',
    'ru' => 'Войти как родитель',
    'tg' => 'Ҳамчун волид ворид шавед',
    'tk' => 'Ene-ata hökmünde gir',
    'uz' => 'Ota-ona sifatida kirish',
    _ => 'Sign in as parent',
  };
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
