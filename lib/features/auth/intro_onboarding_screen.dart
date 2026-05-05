import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations_extras.dart';

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
        mockupBuilder: (ctx) => const _MenuMockup(),
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
    this.asset,
    this.mockupBuilder,
  }) : assert(asset != null || mockupBuilder != null);

  final String title;
  final String subtitle;
  final String? asset;
  final WidgetBuilder? mockupBuilder;
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
                  mockupBuilder: data.mockupBuilder,
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
    required this.mockupBuilder,
    required this.pulse,
    required this.float,
  });

  final String? asset;
  final WidgetBuilder? mockupBuilder;
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
                child: mockupBuilder != null
                    ? mockupBuilder!(context)
                    : Image.asset(
                        asset!,
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

class _MenuMockup extends StatelessWidget {
  const _MenuMockup();

  static const String _sampleChildName = 'Anna';
  static const String _sampleParentName = 'Alex';

  @override
  Widget build(BuildContext context) {
    final extras = ExtraL10n.of(context);
    final tiles = <_MockTile>[
      _MockTile(extras.onlineAroundSoundMenuTitle, Icons.hearing_rounded,
          AppColors.success),
      _MockTile(extras.gameLimitsMenuTitle, Icons.sports_esports_rounded,
          AppColors.primary),
      _MockTile(extras.incomingChatsMenuTitle, Icons.forum_outlined,
          AppColors.accent),
      _MockTile(
          extras.mapPlacesMenuTitle, Icons.map_outlined, AppColors.warning),
      _MockTile(
          extras.movementHistoryMenuTitle, Icons.route_rounded, AppColors.navy),
      _MockTile(extras.appStatsMenuTitle, Icons.bar_chart_rounded,
          AppColors.primary),
      _MockTile(extras.childAchievementsMenuTitle, Icons.emoji_events_outlined,
          AppColors.warning),
      _MockTile(extras.loudSignalMenuTitle,
          Icons.notifications_active_outlined, AppColors.danger),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortest = constraints.biggest.shortestSide;
        final phoneWidth = shortest * 0.82;
        final phoneHeight = phoneWidth * 2.05;
        final s = phoneWidth / 360.0; // scale factor relative to ~360pt phone

        return Center(
          child: Container(
            width: phoneWidth,
            height: phoneHeight,
            padding: EdgeInsets.all(6 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(48 * s),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.20),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(42 * s),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primarySoft.withValues(alpha: 0.85),
                      AppColors.backgroundLight,
                      const Color(0xFFF7FAFF),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    _MockStatusBar(s: s),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20 * s, 8 * s, 20 * s, 0),
                      child: _MockHeader(
                        title: extras.menuLabel,
                        s: s,
                      ),
                    ),
                    SizedBox(height: 14 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * s),
                      child: _MockChildCard(
                        s: s,
                        childName: _sampleChildName,
                        parentLabel:
                            extras.parentPanelLabel(_sampleParentName),
                        selectedLabel: extras.selectedLabel,
                      ),
                    ),
                    SizedBox(height: 22 * s),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            20 * s, 0, 20 * s, 16 * s),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tiles.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12 * s,
                            mainAxisSpacing: 14 * s,
                            childAspectRatio: 0.76,
                          ),
                          itemBuilder: (_, i) =>
                              _MockMenuTile(data: tiles[i], s: s),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MockTile {
  const _MockTile(this.title, this.icon, this.accent);
  final String title;
  final IconData icon;
  final Color accent;
}

class _MockStatusBar extends StatelessWidget {
  const _MockStatusBar({required this.s});
  final double s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22 * s, 10 * s, 22 * s, 4 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '14:37',
            style: TextStyle(
              fontSize: 13 * s,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt,
                  size: 13 * s, color: AppColors.textPrimaryLight),
              SizedBox(width: 5 * s),
              Icon(Icons.wifi,
                  size: 13 * s, color: AppColors.textPrimaryLight),
              SizedBox(width: 5 * s),
              Icon(Icons.battery_full,
                  size: 15 * s, color: AppColors.textPrimaryLight),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockHeader extends StatelessWidget {
  const _MockHeader({required this.title, required this.s});
  final String title;
  final double s;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24 * s,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Icon(Icons.people_alt_outlined,
            size: 22 * s, color: AppColors.textPrimaryLight),
        SizedBox(width: 14 * s),
        Icon(Icons.settings_outlined,
            size: 22 * s, color: AppColors.textPrimaryLight),
      ],
    );
  }
}

class _MockChildCard extends StatelessWidget {
  const _MockChildCard({
    required this.s,
    required this.childName,
    required this.parentLabel,
    required this.selectedLabel,
  });

  final double s;
  final String childName;
  final String parentLabel;
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primarySoft.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              childName.isNotEmpty ? childName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18 * s,
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  parentLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11 * s,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 9 * s, vertical: 6 * s),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 12 * s, color: AppColors.primary),
                SizedBox(width: 4 * s),
                Text(
                  selectedLabel,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w800,
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

class _MockMenuTile extends StatelessWidget {
  const _MockMenuTile({required this.data, required this.s});
  final _MockTile data;
  final double s;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22 * s),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 38 * s,
                height: 38 * s,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14 * s),
                ),
                child: Icon(data.icon,
                    size: 22 * s, color: data.accent),
              ),
            ),
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          data.title,
          maxLines: 3,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9 * s,
            height: 1.18,
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
