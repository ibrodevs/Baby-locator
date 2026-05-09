import 'dart:async';

import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/models/purchases_error.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

typedef RevenueCatCustomerInfoCallback = FutureOr<void> Function(
  CustomerInfo customerInfo,
);
typedef RevenueCatErrorCallback = void Function(String message);

const bool revenueCatUiSupported = true;

Widget buildRevenueCatPaywallView({
  required Offering offering,
  required VoidCallback onDismiss,
  required RevenueCatCustomerInfoCallback onPurchaseCompleted,
  required VoidCallback onPurchaseCancelled,
  required RevenueCatErrorCallback onPurchaseError,
  required RevenueCatCustomerInfoCallback onRestoreCompleted,
  required RevenueCatErrorCallback onRestoreError,
}) {
  return PaywallView(
    offering: offering,
    displayCloseButton: false,
    onDismiss: onDismiss,
    onPurchaseCancelled: onPurchaseCancelled,
    onPurchaseCompleted: (customerInfo, _) => onPurchaseCompleted(customerInfo),
    onPurchaseError: (error) => onPurchaseError(_messageFor(error)),
    onRestoreCompleted: (customerInfo) => onRestoreCompleted(customerInfo),
    onRestoreError: (error) => onRestoreError(_messageFor(error)),
  );
}

Future<void> presentRevenueCatCustomerCenter({
  RevenueCatCustomerInfoCallback? onRestoreCompleted,
  VoidCallback? onRestoreStarted,
  RevenueCatErrorCallback? onRestoreFailed,
}) async {
  await RevenueCatUI.presentCustomerCenter(
    onRestoreStarted: onRestoreStarted,
    onRestoreCompleted: onRestoreCompleted,
    onRestoreFailed: (error) => onRestoreFailed?.call(_messageFor(error)),
  );
}

String _messageFor(PurchasesError error) {
  final underlying = error.underlyingErrorMessage.trim();
  if (underlying.isNotEmpty) {
    return underlying;
  }
  final message = error.message.trim();
  if (message.isNotEmpty) {
    return message;
  }
  return 'RevenueCat request failed.';
}
