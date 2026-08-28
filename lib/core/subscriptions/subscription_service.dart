import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../providers/session_providers.dart';
import 'revenuecat_ui_bridge.dart';

const String _revenueCatFallbackApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: 'goog_EqvRQpJxoxPTrEyftuZNYNpXrog',
);
const String _revenueCatAndroidApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY_ANDROID',
  defaultValue: 'goog_EqvRQpJxoxPTrEyftuZNYNpXrog',
);
const String _revenueCatIosApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY_IOS',
  defaultValue: 'goog_EqvRQpJxoxPTrEyftuZNYNpXrog',
);
const String revenueCatEntitlementId = 'family_security_pro';
const String revenueCatDefaultOfferingId = 'default';
const String revenueCatMonthlyProductId = 'monthly';
const String revenueCatYearlyProductId = 'yearly';
const String revenueCatIosMonthlyProductId =
    'com.location.tracke.parental.control.monthly';
const String revenueCatIosYearlyProductId =
    'com.location.tracke.parental.control.yearly';
const List<String> revenueCatMonthlyProductIds = [
  revenueCatMonthlyProductId,
  revenueCatIosMonthlyProductId,
];
const List<String> revenueCatYearlyProductIds = [
  revenueCatYearlyProductId,
  revenueCatIosYearlyProductId,
];
const int freePlanChildLimit = 1;

bool matchesRevenueCatProductId(String storeProductId, String configuredId) {
  final normalizedStoreId = storeProductId.trim();
  final normalizedConfiguredId = configuredId.trim();
  if (normalizedStoreId.isEmpty || normalizedConfiguredId.isEmpty) {
    return false;
  }
  if (normalizedStoreId == normalizedConfiguredId) {
    return true;
  }

  final storeSegments = normalizedStoreId.split(':');
  return storeSegments.contains(normalizedConfiguredId);
}

bool matchesAnyRevenueCatProductId(
  String storeProductId,
  Iterable<String> configuredIds,
) {
  for (final configuredId in configuredIds) {
    if (matchesRevenueCatProductId(storeProductId, configuredId)) {
      return true;
    }
  }
  return false;
}

bool isRevenueCatMonthlyProductId(String storeProductId) {
  return matchesAnyRevenueCatProductId(
    storeProductId,
    revenueCatMonthlyProductIds,
  );
}

bool isRevenueCatYearlyProductId(String storeProductId) {
  return matchesAnyRevenueCatProductId(
    storeProductId,
    revenueCatYearlyProductIds,
  );
}


class SubscriptionConfigStore {
  static const _androidKeyPref = 'revenuecat_api_key_android';
  static const _iosKeyPref = 'revenuecat_api_key_ios';
  static const _fallbackKeyPref = 'revenuecat_api_key_fallback';

  static String? _cachedAndroidKey;
  static String? _cachedIosKey;
  static String? _cachedFallbackKey;

  static Future<void> loadCachedKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedAndroidKey = prefs.getString(_androidKeyPref);
      if (_cachedAndroidKey?.startsWith('test_') == true) {
        _cachedAndroidKey = null;
        await prefs.remove(_androidKeyPref);
      }
      _cachedIosKey = prefs.getString(_iosKeyPref);
      if (_cachedIosKey?.startsWith('test_') == true) {
        _cachedIosKey = null;
        await prefs.remove(_iosKeyPref);
      }
      _cachedFallbackKey = prefs.getString(_fallbackKeyPref);
      if (_cachedFallbackKey?.startsWith('test_') == true) {
        _cachedFallbackKey = null;
        await prefs.remove(_fallbackKeyPref);
      }
    } catch (_) {}
  }

  static Future<void> updateFromRemote(Map<String, dynamic> remote) async {
    try {
      final androidKey = (remote['android_api_key'] as String?)?.trim();
      final iosKey = (remote['ios_api_key'] as String?)?.trim();
      final fallbackKey = (remote['api_key'] as String?)?.trim();

      final prefs = await SharedPreferences.getInstance();
      if (androidKey != null && androidKey.isNotEmpty && !androidKey.startsWith('test_')) {
        _cachedAndroidKey = androidKey;
        await prefs.setString(_androidKeyPref, androidKey);
      }
      if (iosKey != null && iosKey.isNotEmpty && !iosKey.startsWith('test_')) {
        _cachedIosKey = iosKey;
        await prefs.setString(_iosKeyPref, iosKey);
      }
      if (fallbackKey != null && fallbackKey.isNotEmpty && !fallbackKey.startsWith('test_')) {
        _cachedFallbackKey = fallbackKey;
        await prefs.setString(_fallbackKeyPref, fallbackKey);
      }
    } catch (_) {}
  }

  static String resolveApiKey() {
    final dynamicAndroid = _cachedAndroidKey?.trim() ?? '';
    final dynamicIos = _cachedIosKey?.trim() ?? '';
    final dynamicFallback = _cachedFallbackKey?.trim() ?? '';

    final envAndroid = _revenueCatAndroidApiKey.trim();
    final envIos = _revenueCatIosApiKey.trim();
    final envFallback = _revenueCatFallbackApiKey.trim();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (dynamicAndroid.isNotEmpty && !dynamicAndroid.startsWith('test_')) return dynamicAndroid;
        if (envAndroid.isNotEmpty && !envAndroid.startsWith('test_')) return envAndroid;
        if (dynamicFallback.isNotEmpty && !dynamicFallback.startsWith('test_')) return dynamicFallback;
        return envFallback;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        if (dynamicIos.isNotEmpty && !dynamicIos.startsWith('test_')) return dynamicIos;
        if (envIos.isNotEmpty && !envIos.startsWith('test_')) return envIos;
        if (dynamicFallback.isNotEmpty && !dynamicFallback.startsWith('test_')) return dynamicFallback;
        return envFallback;
      default:
        if (dynamicFallback.isNotEmpty && !dynamicFallback.startsWith('test_')) return dynamicFallback;
        return envFallback;
    }
  }
}

String get revenueCatApiKey => SubscriptionConfigStore.resolveApiKey();


bool isPremiumUser(CustomerInfo info) {
  return info.entitlements.active.containsKey(revenueCatEntitlementId);
}

bool canAccessMultipleChildren({
  required bool isPremium,
  required int currentChildrenCount,
}) {
  return isPremium || currentChildrenCount < freePlanChildLimit;
}

bool isPremiumRequiredError(Object error) {
  if (error is! ApiException) return false;
  return error.statusCode == 403 &&
      error.message.toLowerCase().contains('premium');
}

class SubscriptionException implements Exception {
  const SubscriptionException({
    required this.message,
    this.isCancelled = false,
  });

  final String message;
  final bool isCancelled;

  @override
  String toString() => message;
}

class SubscriptionState {
  const SubscriptionState({
    this.initialized = false,
    this.configured = false,
    this.loadingOfferings = false,
    this.refreshingCustomerInfo = false,
    this.purchaseInProgress = false,
    this.restoringPurchases = false,
    this.backendIsPremium = false,
    this.appUserId,
    this.customerInfo,
    this.offerings,
    this.errorMessage,
  });

  final bool initialized;
  final bool configured;
  final bool loadingOfferings;
  final bool refreshingCustomerInfo;
  final bool purchaseInProgress;
  final bool restoringPurchases;
  final bool backendIsPremium;
  final String? appUserId;
  final CustomerInfo? customerInfo;
  final Offerings? offerings;
  final String? errorMessage;

  bool get isPremium {
    if (backendIsPremium) return true;
    final info = customerInfo;
    return info != null && isPremiumUser(info);
  }

  bool get hasActiveEntitlement =>
      backendIsPremium ||
      (customerInfo?.entitlements.active.containsKey(
            revenueCatEntitlementId,
          ) ??
          false);

  Offering? get currentOffering =>
      offerings?.getOffering(revenueCatDefaultOfferingId) ?? offerings?.current;

  Package? get monthlyPackage =>
      _findPackage(currentOffering, revenueCatMonthlyProductIds) ??
      currentOffering?.monthly;

  Package? get yearlyPackage =>
      _findPackage(currentOffering, revenueCatYearlyProductIds) ??
      currentOffering?.annual;

  List<Package> get paywallPackages {
    final packages = <Package>[];
    void addPackage(Package? package) {
      if (package == null) return;
      if (_isHiddenPaywallPackage(package)) return;
      if (packages.any(
        (item) =>
            item.storeProduct.identifier == package.storeProduct.identifier,
      )) {
        return;
      }
      packages.add(package);
    }

    addPackage(yearlyPackage);
    addPackage(monthlyPackage);

    if (packages.isEmpty && currentOffering != null) {
      for (final package in currentOffering!.availablePackages) {
        addPackage(package);
      }
    }

    return packages;
  }

  SubscriptionState copyWith({
    bool? initialized,
    bool? configured,
    bool? loadingOfferings,
    bool? refreshingCustomerInfo,
    bool? purchaseInProgress,
    bool? restoringPurchases,
    bool? backendIsPremium,
    String? appUserId,
    CustomerInfo? customerInfo,
    Offerings? offerings,
    String? errorMessage,
    bool clearAppUserId = false,
    bool clearCustomerInfo = false,
    bool clearOfferings = false,
    bool clearError = false,
  }) {
    return SubscriptionState(
      initialized: initialized ?? this.initialized,
      configured: configured ?? this.configured,
      loadingOfferings: loadingOfferings ?? this.loadingOfferings,
      refreshingCustomerInfo:
          refreshingCustomerInfo ?? this.refreshingCustomerInfo,
      purchaseInProgress: purchaseInProgress ?? this.purchaseInProgress,
      restoringPurchases: restoringPurchases ?? this.restoringPurchases,
      backendIsPremium: backendIsPremium ?? this.backendIsPremium,
      appUserId: clearAppUserId ? null : appUserId ?? this.appUserId,
      customerInfo:
          clearCustomerInfo ? null : customerInfo ?? this.customerInfo,
      offerings: clearOfferings ? null : offerings ?? this.offerings,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  static Package? _findPackage(
      Offering? offering, Iterable<String> productIds) {
    if (offering == null) return null;
    for (final package in offering.availablePackages) {
      if (matchesAnyRevenueCatProductId(
        package.storeProduct.identifier,
        productIds,
      )) {
        return package;
      }
    }
    return null;
  }

  static bool _isHiddenPaywallPackage(Package package) {
    return package.packageType == PackageType.lifetime;
  }
}

class SubscriptionService extends StateNotifier<SubscriptionState> {
  SubscriptionService() : super(const SubscriptionState());

  bool _customerInfoListenerAttached = false;
  Future<void>? _configureFuture;

  Future<void> bootstrap({SessionUser? user}) async {
    try {
      if (user?.isPremium == true) {
        state = state.copyWith(backendIsPremium: true);
      }
      await SubscriptionConfigStore.loadCachedKeys();
      try {
        final remoteConfig = await ApiClient.instance
            .getSubscriptionConfig()
            .timeout(const Duration(seconds: 4));
        if (remoteConfig != null) {
          await SubscriptionConfigStore.updateFromRemote(remoteConfig);
        }
      } catch (e) {
        debugPrint('[SubscriptionService] Remote config fetch skipped: $e');
      }

      await _configureIfNeeded(user);
      await Future.wait([
        fetchOfferings(),
        refreshCustomerInfo(),
      ]);
      state = state.copyWith(initialized: true, clearError: true);
    } catch (error) {
      state = state.copyWith(
        initialized: true,
        errorMessage: _friendlyErrorMessage(error),
      );
      rethrow;
    }
  }

  void syncBackendPremium(bool isPremium) {
    if (state.backendIsPremium != isPremium) {
      state = state.copyWith(backendIsPremium: isPremium);
    }
  }

  Future<void> syncSessionUser(SessionUser? user) async {
    if (user != null) {
      state = state.copyWith(backendIsPremium: user.isPremium);
    }
    await _configureIfNeeded(user);
    final nextAppUserId = _normalizeAppUserId(user);

    if (user != null && nextAppUserId == null) {
      const error = SubscriptionException(
        message: 'RevenueCat appUserID is invalid for this account.',
      );
      state = state.copyWith(errorMessage: error.message);
      throw error;
    }

    if (nextAppUserId == null) {
      await _logOutIfNeeded();
      return;
    }

    if (state.appUserId == nextAppUserId) {
      await refreshCustomerInfo();
      return;
    }

    try {
      final result = await Purchases.logIn(nextAppUserId);
      _applyCustomerInfo(
        result.customerInfo,
        appUserId: nextAppUserId,
      );
      state = state.copyWith(clearError: true);
    } on PlatformException catch (error) {
      throw _mapRevenueCatError(error);
    }
  }

  Future<Offerings?> fetchOfferings() async {
    state = state.copyWith(loadingOfferings: true, clearError: true);
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(revenueCatDefaultOfferingId) ??
          offerings.current;
      if (offering == null || offering.availablePackages.isEmpty) {
        throw const SubscriptionException(
          message: 'No active subscription offering is available right now.',
        );
      }
      state = state.copyWith(
        offerings: offerings,
        loadingOfferings: false,
      );
      return offerings;
    } catch (error) {
      state = state.copyWith(
        loadingOfferings: false,
        errorMessage: _friendlyErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<CustomerInfo?> refreshCustomerInfo() async {
    state = state.copyWith(refreshingCustomerInfo: true, clearError: true);
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _applyCustomerInfo(customerInfo);
      state = state.copyWith(refreshingCustomerInfo: false);
      return customerInfo;
    } catch (error) {
      state = state.copyWith(
        refreshingCustomerInfo: false,
        errorMessage: _friendlyErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    state = state.copyWith(purchaseInProgress: true, clearError: true);
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      _applyCustomerInfo(result.customerInfo);
      state = state.copyWith(purchaseInProgress: false);
      return result.customerInfo;
    } on PlatformException catch (error) {
      final mapped = _mapRevenueCatError(error);
      state = state.copyWith(
        purchaseInProgress: false,
        errorMessage: mapped.message,
      );
      throw mapped;
    } catch (error) {
      final mapped = SubscriptionException(
        message: _friendlyErrorMessage(error),
      );
      state = state.copyWith(
        purchaseInProgress: false,
        errorMessage: mapped.message,
      );
      throw mapped;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    state = state.copyWith(restoringPurchases: true, clearError: true);
    try {
      final customerInfo = await Purchases.restorePurchases();
      _applyCustomerInfo(customerInfo);
      state = state.copyWith(restoringPurchases: false);
      return customerInfo;
    } on PlatformException catch (error) {
      final mapped = _mapRevenueCatError(error);
      state = state.copyWith(
        restoringPurchases: false,
        errorMessage: mapped.message,
      );
      throw mapped;
    } catch (error) {
      final mapped = SubscriptionException(
        message: _friendlyErrorMessage(error),
      );
      state = state.copyWith(
        restoringPurchases: false,
        errorMessage: mapped.message,
      );
      throw mapped;
    }
  }

  Future<void> openCustomerCenter() async {
    try {
      await presentRevenueCatCustomerCenter(
        onRestoreCompleted: (customerInfo) {
          _applyCustomerInfo(customerInfo);
        },
      );
      await refreshCustomerInfo();
    } catch (error) {
      final mapped = SubscriptionException(
        message: _friendlyErrorMessage(error),
      );
      state = state.copyWith(errorMessage: mapped.message);
      throw mapped;
    }
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearError: true);
  }

  Future<void> _configureIfNeeded(SessionUser? user) async {
    if (state.configured) return;
    final inFlight = _configureFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _configure(user);
    _configureFuture = future;
    try {
      await future;
    } finally {
      _configureFuture = null;
    }
  }

  Future<void> _configure(SessionUser? user) async {
    if (revenueCatApiKey.trim().isEmpty) {
      throw const SubscriptionException(
        message: 'RevenueCat API key is missing.',
      );
    }

    final configuration = PurchasesConfiguration(revenueCatApiKey);
    final appUserId = _normalizeAppUserId(user);
    if (appUserId != null) {
      configuration.appUserID = appUserId;
    }

    await Purchases.setLogLevel(
      kReleaseMode ? LogLevel.info : LogLevel.debug,
    );
    await Purchases.configure(configuration);

    if (!_customerInfoListenerAttached) {
      Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdated);
      _customerInfoListenerAttached = true;
    }

    state = state.copyWith(
      configured: true,
      appUserId: appUserId,
      clearError: true,
    );
  }

  Future<void> _logOutIfNeeded() async {
    try {
      final customerInfo = await Purchases.logOut();
      _applyCustomerInfo(customerInfo, clearAppUserId: true);
      state = state.copyWith(clearError: true);
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.logOutWithAnonymousUserError) {
        state = state.copyWith(
          clearAppUserId: true,
          clearCustomerInfo: true,
          clearError: true,
        );
        return;
      }
      final mapped = _mapRevenueCatError(error);
      state = state.copyWith(errorMessage: mapped.message);
      throw mapped;
    }
  }

  void _handleCustomerInfoUpdated(CustomerInfo customerInfo) {
    _applyCustomerInfo(customerInfo);
  }

  void _applyCustomerInfo(
    CustomerInfo customerInfo, {
    String? appUserId,
    bool clearAppUserId = false,
  }) {
    state = state.copyWith(
      customerInfo: customerInfo,
      appUserId: clearAppUserId
          ? null
          : appUserId ??
              _normalizeRevenueCatUserId(customerInfo.originalAppUserId),
      clearError: true,
    );
  }

  String? _normalizeAppUserId(SessionUser? user) {
    final id = user?.id;
    if (id == null || id <= 0) {
      return null;
    }
    return '$id';
  }

  String? _normalizeRevenueCatUserId(String? appUserId) {
    if (appUserId == null) return state.appUserId;
    final trimmed = appUserId.trim();
    if (trimmed.isEmpty || trimmed.startsWith(r'$RCAnonymousID:')) {
      return null;
    }
    return trimmed;
  }

  SubscriptionException _mapRevenueCatError(PlatformException error) {
    final code = PurchasesErrorHelper.getErrorCode(error);
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return const SubscriptionException(
          message: 'Purchase was cancelled.',
          isCancelled: true,
        );
      case PurchasesErrorCode.networkError:
      case PurchasesErrorCode.offlineConnectionError:
        return const SubscriptionException(
          message: 'Network error while contacting RevenueCat.',
        );
      case PurchasesErrorCode.invalidAppUserIdError:
        return const SubscriptionException(
          message: 'RevenueCat appUserID is invalid.',
        );
      case PurchasesErrorCode.invalidCredentialsError:
      case PurchasesErrorCode.configurationError:
        return const SubscriptionException(
          message: 'RevenueCat is not configured correctly for this app.',
        );
      default:
        final message = error.message?.trim();
        return SubscriptionException(
          message: message == null || message.isEmpty
              ? 'Subscription request failed.'
              : message,
        );
    }
  }

  String _friendlyErrorMessage(Object error) {
    if (error is SubscriptionException) {
      return error.message;
    }
    if (error is PlatformException) {
      return _mapRevenueCatError(error).message;
    }
    return error.toString();
  }
}

final subscriptionServiceProvider =
    StateNotifierProvider<SubscriptionService, SubscriptionState>(
  (ref) => SubscriptionService(),
);

