import 'dart:async';

import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';

typedef RevenueCatCustomerInfoCallback = FutureOr<void> Function(
  CustomerInfo customerInfo,
);
typedef RevenueCatErrorCallback = void Function(String message);

const bool revenueCatUiSupported = false;

Widget buildRevenueCatPaywallView({
  required Offering offering,
  required VoidCallback onDismiss,
  required RevenueCatCustomerInfoCallback onPurchaseCompleted,
  required VoidCallback onPurchaseCancelled,
  required RevenueCatErrorCallback onPurchaseError,
  required RevenueCatCustomerInfoCallback onRestoreCompleted,
  required RevenueCatErrorCallback onRestoreError,
}) {
  return const SizedBox.shrink();
}

Future<void> presentRevenueCatCustomerCenter({
  RevenueCatCustomerInfoCallback? onRestoreCompleted,
  VoidCallback? onRestoreStarted,
  RevenueCatErrorCallback? onRestoreFailed,
}) async {
  throw UnsupportedError(
    'RevenueCat Customer Center is only available on iOS and Android.',
  );
}
