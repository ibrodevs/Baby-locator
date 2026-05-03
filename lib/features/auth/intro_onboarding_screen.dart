import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

const String introSeenKey = 'intro_onboarding_seen_v1';

class IntroOnboardingScreen extends StatefulWidget {
  const IntroOnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<IntroOnboardingScreen> createState() => _IntroOnboardingScreenState();
}

class _IntroOnboardingScreenState extends State<IntroOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;

  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _pageController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markSeenAndFinish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(introSeenKey, true);
    } catch (_) {}
    if (mounted) widget.onFinished();
  }

  void _next() {
    if (_index < _pages(context).length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _markSeenAndFinish();
    }
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
    _pageController
      ..reset()
      ..forward();
  }

  List<_IntroPageData> _pages(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return [
      _IntroPageData(
        title: _t(code, {
          'ru': 'Семейный\nлокатор',
          'en': 'Family\nlocator',
        }),
        subtitle: _t(code, {
          'ru': 'Всегда знайте,\nгде ваши близкие',
          'en': 'Always know where\nyour loved ones are',
        }),
        asset: 'assets/images/onboard_1.png',
      ),
      _IntroPageData(
        title: _t(code, {
          'ru': 'Ограничьте\nэкранное время',
          'en': 'Limit\nscreen time',
        }),
        subtitle: _t(code, {
          'ru': 'Устанавливайте лимиты\nиспользования устройства',
          'en': 'Set limits for\ndevice usage',
        }),
        asset: 'assets/images/onboard_2.png',
      ),
      _IntroPageData(
        title: _t(code, {
          'ru': 'Родительский\nконтроль',
          'en': 'Parental\ncontrol',
        }),
        subtitle: _t(code, {
          'ru': 'Защитите ребенка\nи управляйте доступом',
          'en': 'Protect your child\nand manage access',
        }),
        asset: 'assets/images/onboard_3.png',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    final code = Localizations.localeOf(context).languageCode;
    final continueLabel = _t(code, {
      'ru': 'Продолжить',
      'en': 'Continue',
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (_, i) => _IntroPage(
                  data: pages[i],
                  pulse: _pulseController,
                  float: _floatController,
                  entrance: _pageController,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    continueLabel,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _t(String code, Map<String, String> map) =>
    map[code] ?? map['en'] ?? map.values.first;

class _IntroPageData {
  const _IntroPageData({
    required this.title,
    required this.subtitle,
    required this.asset,
  });

  final String title;
  final String subtitle;
  final String asset;
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.data,
    required this.pulse,
    required this.float,
    required this.entrance,
  });

  final _IntroPageData data;
  final AnimationController pulse;
  final AnimationController float;
  final AnimationController entrance;

  @override
  Widget build(BuildContext context) {
    final fadeText = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    final slideText = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    final fadeImage = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    final scaleImage = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: entrance,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          FadeTransition(
            opacity: fadeText,
            child: SlideTransition(
              position: slideText,
              child: Column(
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: AppColors.navy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: FadeTransition(
              opacity: fadeImage,
              child: ScaleTransition(
                scale: scaleImage,
                child: _AnimatedPhoneStage(
                  asset: data.asset,
                  pulse: pulse,
                  float: float,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPhoneStage extends StatelessWidget {
  const _AnimatedPhoneStage({
    required this.asset,
    required this.pulse,
    required this.float,
  });

  final String asset;
  final AnimationController pulse;
  final AnimationController float;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing soft halo behind the phone
            AnimatedBuilder(
              animation: pulse,
              builder: (_, __) {
                final t = pulse.value;
                return Container(
                  width: size * (0.92 + 0.06 * t),
                  height: size * (0.92 + 0.06 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary
                        .withValues(alpha: 0.05 + 0.05 * (1 - t)),
                  ),
                );
              },
            ),
            // Inner ring
            AnimatedBuilder(
              animation: pulse,
              builder: (_, __) {
                final t = pulse.value;
                return Container(
                  width: size * (0.74 + 0.04 * t),
                  height: size * (0.74 + 0.04 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary
                        .withValues(alpha: 0.07 + 0.06 * t),
                  ),
                );
              },
            ),
            // Floating phone image
            AnimatedBuilder(
              animation: float,
              builder: (_, child) {
                final t = Curves.easeInOut.transform(float.value);
                return Transform.translate(
                  offset: Offset(0, -6 + 12 * t),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
