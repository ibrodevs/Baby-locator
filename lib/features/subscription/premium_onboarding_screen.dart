import 'package:flutter/material.dart';

import '../../core/subscriptions/subscription_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'premium_guard.dart';
import 'premium_paywall_screen.dart';

const _supportedLangs = {'ar', 'de', 'en', 'es', 'fr', 'it', 'pt', 'ru'};
const _slideCount = 4;
const _assetBase = 'assets/subscriptions/Kid Security (3)';

String _lang(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return _supportedLangs.contains(code) ? code : 'en';
}

String _slideAsset(String lang, int index) =>
    '$_assetBase/${index.toString().padLeft(2, '0')}_GooglePlay_Phone_$lang.png';

class PremiumOnboardingScreen extends StatefulWidget {
  const PremiumOnboardingScreen({
    super.key,
    this.feature = PremiumFeature.generic,
  });

  final PremiumFeature feature;

  @override
  State<PremiumOnboardingScreen> createState() =>
      _PremiumOnboardingScreenState();
}

class _PremiumOnboardingScreenState extends State<PremiumOnboardingScreen> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openPaywall() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PremiumPaywallScreen(feature: widget.feature),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  void _next() {
    if (_page < _slideCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _openPaywall();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _lang(context);
    final isLast = _page == _slideCount - 1;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _slideCount,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Image.asset(
              _slideAsset(lang, i + 1),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Skip button
          Positioned(
            top: topInset + 12,
            right: 16,
            child: TextButton(
              onPressed: _openPaywall,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black45,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                S.of(context).skip,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),

          // Bottom gradient + controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 40, 24, bottomInset + 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Price cards — visible only on last slide
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: isLast
                        ? const _PricingRow(key: ValueKey('prices'))
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                  if (isLast) const SizedBox(height: 16),

                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slideCount, (i) {
                      final active = _page == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Next / Get Premium button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        isLast ? S.of(context).getPremium : S.of(context).next,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Row(
      children: [
        Expanded(
          child: _PriceTile(
            label: t.monthly,
            price: revenueCatMonthlyDisplayPrice,
            sub: t.perMonth,
            highlighted: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PriceTile(
            label: t.yearly,
            price: revenueCatYearlyDisplayPrice,
            sub: t.perYearSave58,
            highlighted: true,
          ),
        ),
      ],
    );
  }
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({
    required this.label,
    required this.price,
    required this.sub,
    required this.highlighted,
  });

  final String label;
  final String price;
  final String sub;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: highlighted
            ? null
            : Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlighted)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD166),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                S.of(context).bestValue,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3D2A00),
                ),
              ),
            ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
