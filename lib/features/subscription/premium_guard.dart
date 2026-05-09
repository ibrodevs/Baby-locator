import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/subscriptions/subscription_service.dart';
import '../../l10n/app_localizations.dart';
import 'premium_onboarding_screen.dart';

enum PremiumFeature {
  additionalChildren,
  liveMap,
  movementHistory,
  audioMonitoring,
  screenTime,
  appStats,
  achievements,
  loudAlarm,
  fullMenu,
  generic,
}

extension PremiumFeatureCopy on PremiumFeature {
  String titleFor(BuildContext context) {
    final t = S.of(context);
    return switch (this) {
      PremiumFeature.additionalChildren => t.premiumTitleAdditionalChildren,
      PremiumFeature.liveMap => t.premiumTitleLiveMap,
      PremiumFeature.movementHistory => t.premiumTitleMovementHistory,
      PremiumFeature.audioMonitoring => t.premiumTitleAudioMonitoring,
      PremiumFeature.screenTime => t.premiumTitleScreenTime,
      PremiumFeature.appStats => t.premiumTitleAppStats,
      PremiumFeature.achievements => t.premiumTitleAchievements,
      PremiumFeature.loudAlarm => t.premiumTitleLoudAlarm,
      PremiumFeature.fullMenu => t.premiumTitleFullMenu,
      PremiumFeature.generic => t.premiumTitleGeneric,
    };
  }

  String subtitleFor(BuildContext context) {
    final t = S.of(context);
    return switch (this) {
      PremiumFeature.additionalChildren => t.premiumSubtitleAdditionalChildren,
      PremiumFeature.liveMap => t.premiumSubtitleLiveMap,
      PremiumFeature.movementHistory => t.premiumSubtitleMovementHistory,
      PremiumFeature.audioMonitoring => t.premiumSubtitleAudioMonitoring,
      PremiumFeature.screenTime => t.premiumSubtitleScreenTime,
      PremiumFeature.appStats => t.premiumSubtitleAppStats,
      PremiumFeature.achievements => t.premiumSubtitleAchievements,
      PremiumFeature.loudAlarm => t.premiumSubtitleLoudAlarm,
      PremiumFeature.fullMenu => t.premiumSubtitleFullMenu,
      PremiumFeature.generic => t.premiumSubtitleGeneric,
    };
  }
}

Future<bool> requirePremium(
  BuildContext context, {
  PremiumFeature feature = PremiumFeature.generic,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final state = container.read(subscriptionServiceProvider);
  if (state.isPremium) return true;

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PremiumOnboardingScreen(feature: feature),
    ),
  );

  if (result == true) {
    return true;
  }

  return container.read(subscriptionServiceProvider).isPremium;
}

Future<bool> requirePremiumForAdditionalChild(
  BuildContext context, {
  required int currentChildrenCount,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final state = container.read(subscriptionServiceProvider);
  if (canAccessMultipleChildren(
    isPremium: state.isPremium,
    currentChildrenCount: currentChildrenCount,
  )) {
    return true;
  }
  return requirePremium(
    context,
    feature: PremiumFeature.additionalChildren,
  );
}
