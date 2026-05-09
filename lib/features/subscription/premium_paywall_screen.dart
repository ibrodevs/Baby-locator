import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

import '../../core/subscriptions/subscription_catalog.dart';
import '../../core/subscriptions/revenuecat_ui_bridge.dart';
import '../../core/subscriptions/subscription_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/brand_header.dart';
import '../../l10n/app_localizations.dart';
import 'premium_guard.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({
    super.key,
    this.feature = PremiumFeature.generic,
  });

  final PremiumFeature feature;

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  bool _refreshing = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepare());
    });
  }

  Future<void> _prepare() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    final service = ref.read(subscriptionServiceProvider.notifier);
    try {
      await Future.wait([
        service.fetchOfferings(),
        service.refreshCustomerInfo(),
      ]);
      if (!mounted) return;
      if (ref.read(subscriptionServiceProvider).isPremium) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      // Surface the service state below.
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _restorePurchases() async {
    if (_restoring) return;
    setState(() => _restoring = true);
    final service = ref.read(subscriptionServiceProvider.notifier);
    try {
      final info = await service.restorePurchases();
      if (!mounted) return;
      if (info != null && isPremiumUser(info)) {
        showAppSnackBar(
          context,
          S.of(context).subscriptionRestored,
          type: AppFeedbackType.success,
        );
        Navigator.of(context).pop(true);
        return;
      }
      showAppSnackBar(
        context,
        S.of(context).noSubscriptionFound,
        type: AppFeedbackType.warning,
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        error.toString(),
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _handlePurchaseCompleted(CustomerInfo customerInfo) async {
    if (!mounted) return;
    if (isPremiumUser(customerInfo)) {
      showAppSnackBar(
        context,
        S.of(context).subscriptionNowActive,
        type: AppFeedbackType.success,
      );
      Navigator.of(context).pop(true);
      return;
    }
    showAppSnackBar(
      context,
      S.of(context).purchaseEntitlementPending,
      type: AppFeedbackType.warning,
    );
  }

  Future<void> _purchasePackage(Package package) async {
    final service = ref.read(subscriptionServiceProvider.notifier);
    try {
      final customerInfo = await service.purchasePackage(package);
      if (customerInfo == null) return;
      await _handlePurchaseCompleted(customerInfo);
    } on SubscriptionException catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        error.message,
        type:
            error.isCancelled ? AppFeedbackType.warning : AppFeedbackType.error,
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        error.toString(),
        type: AppFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionServiceProvider);
    final packages = subscription.paywallPackages;
    final error = subscription.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            BrandHeader(
              title: S.of(context).paywallProductName,
              titlePrefix: S.of(context).paywallUpgrade,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _prepare,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _HeroCard(
                      feature: widget.feature,
                    ),
                    const SizedBox(height: 16),
                    _BenefitsCard(feature: widget.feature),
                    const SizedBox(height: 16),
                    _PlansPreview(packages: packages),
                    const SizedBox(height: 16),
                    if (!revenueCatUiSupported)
                      const _UnsupportedUiCard()
                    else if (packages.isEmpty)
                      _LoadingOrErrorCard(
                        loading: _refreshing || subscription.loadingOfferings,
                        errorMessage: error,
                        onRetry: _prepare,
                      )
                    else
                      _PurchaseActionsCard(
                        packages: packages,
                        purchaseInProgress: subscription.purchaseInProgress,
                        onPurchase: _purchasePackage,
                      ),
                    const SizedBox(height: 16),
                    _FooterActions(
                      restoring: _restoring || subscription.restoringPurchases,
                      onRestore: _restorePurchases,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.feature,
  });

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2A74),
            Color(0xFF1C62F0),
            Color(0xFF4D8CFF),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD166),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  S.of(context).paywallBestValueSave(
                        revenueCatYearlySavingsPercent,
                      ),
                  style: const TextStyle(
                    color: Color(0xFF3D2A00),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            feature.titleFor(context),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            feature.subtitleFor(context),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    final benefits = switch (feature) {
      PremiumFeature.additionalChildren => [
          t.paywallBenefitAddChildren,
          t.paywallBenefitUnlockTools,
          t.paywallBenefitFullDashboard,
        ],
      _ => [
          t.paywallBenefitAudio,
          t.paywallBenefitAppLimits,
          t.paywallBenefitAlarm,
        ],
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.paywallIncludedWithPro,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 14),
          for (final benefit in benefits) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    benefit,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (benefit != benefits.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PlansPreview extends StatelessWidget {
  const _PlansPreview({required this.packages});

  final List<Package> packages;

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).paywallPlansTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        for (final package in packages) ...[
          _PlanTile(package: package),
          if (package != packages.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.package});

  final Package package;

  bool get _isRecommended =>
      matchesRevenueCatProductId(
        package.storeProduct.identifier,
        revenueCatYearlyProductId,
      ) ||
      package.packageType == PackageType.annual;

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final perMonth = _displayPerMonthEquivalent(package);

    return AppCard(
      padding: const EdgeInsets.all(18),
      color: _isRecommended ? AppColors.primarySoft : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _titleFor(package, context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (_isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          S.of(context).paywallRecommended,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.title,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (perMonth != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).paywallPerMonthEquivalent(perMonth),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _displayPrice(package),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(Package package, BuildContext context) {
    if (package.storeProduct.identifier == revenueCatMonthlyProductId ||
        matchesRevenueCatProductId(
          package.storeProduct.identifier,
          revenueCatMonthlyProductId,
        ) ||
        package.packageType == PackageType.monthly) {
      return S.of(context).monthly;
    }
    if (package.storeProduct.identifier == revenueCatYearlyProductId ||
        matchesRevenueCatProductId(
          package.storeProduct.identifier,
          revenueCatYearlyProductId,
        ) ||
        package.packageType == PackageType.annual) {
      return S.of(context).yearly;
    }
    return package.storeProduct.title;
  }
}

class _PurchaseActionsCard extends StatelessWidget {
  const _PurchaseActionsCard({
    required this.packages,
    required this.purchaseInProgress,
    required this.onPurchase,
  });

  final List<Package> packages;
  final bool purchaseInProgress;
  final ValueChanged<Package> onPurchase;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).paywallChooseYourPlan,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).paywallChoosePlanDescription,
            style: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          for (final package in packages) ...[
            _PurchaseButton(
              package: package,
              loading: purchaseInProgress,
              onPressed: () => onPurchase(package),
            ),
            if (package != packages.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({
    required this.package,
    required this.loading,
    required this.onPressed,
  });

  final Package package;
  final bool loading;
  final VoidCallback onPressed;

  bool get _isRecommended =>
      matchesRevenueCatProductId(
        package.storeProduct.identifier,
        revenueCatYearlyProductId,
      ) ||
      package.packageType == PackageType.annual;

  @override
  Widget build(BuildContext context) {
    final perMonth = _displayPerMonthEquivalent(package);

    return InkWell(
      onTap: loading ? null : onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _isRecommended ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isRecommended ? AppColors.primary : AppColors.dividerLight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.packageType == PackageType.annual
                            ? S.of(context).yearly
                            : S.of(context).monthly,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      if (_isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            S.of(context).bestValue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _displayPrice(package),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  if (perMonth != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      S.of(context).paywallPerMonthEquivalent(perMonth),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.textPrimaryLight,
                  ),
          ],
        ),
      ),
    );
  }
}

String _displayPrice(Package package) {
  if (package.storeProduct.identifier == revenueCatMonthlyProductId ||
      matchesRevenueCatProductId(
        package.storeProduct.identifier,
        revenueCatMonthlyProductId,
      ) ||
      package.packageType == PackageType.monthly) {
    return revenueCatMonthlyDisplayPrice;
  }
  if (package.storeProduct.identifier == revenueCatYearlyProductId ||
      matchesRevenueCatProductId(
        package.storeProduct.identifier,
        revenueCatYearlyProductId,
      ) ||
      package.packageType == PackageType.annual) {
    return revenueCatYearlyDisplayPrice;
  }
  return package.storeProduct.priceString;
}

String? _displayPerMonthEquivalent(Package package) {
  if (package.storeProduct.identifier == revenueCatYearlyProductId ||
      matchesRevenueCatProductId(
        package.storeProduct.identifier,
        revenueCatYearlyProductId,
      ) ||
      package.packageType == PackageType.annual) {
    return revenueCatYearlyEquivalentDisplayPrice;
  }
  return null;
}

class _LoadingOrErrorCard extends StatelessWidget {
  const _LoadingOrErrorCard({
    required this.loading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool loading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          if (loading) ...[
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(height: 14),
            Text(
              S.of(context).paywallLoadingPlans,
              style: const TextStyle(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else ...[
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 30,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? S.of(context).paywallNoOffering,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(S.of(context).retry),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnsupportedUiCard extends StatelessWidget {
  const _UnsupportedUiCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        S.of(context).paywallPlatformOnly,
        style: const TextStyle(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w600,
          height: 1.45,
        ),
      ),
    );
  }
}

class _FooterActions extends StatelessWidget {
  const _FooterActions({
    required this.restoring,
    required this.onRestore,
  });

  final bool restoring;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: restoring ? null : onRestore,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.dividerLight),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: restoring
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    S.of(context).restorePurchases,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }
}
