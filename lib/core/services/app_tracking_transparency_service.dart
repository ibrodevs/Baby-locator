import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AppTrackingAuthorizationStatus {
  notSupported,
  notDetermined,
  restricted,
  denied,
  authorized,
}

class AppTrackingTransparencyService {
  AppTrackingTransparencyService._();

  static final AppTrackingTransparencyService instance =
      AppTrackingTransparencyService._();

  static const MethodChannel _channel =
      MethodChannel('kid_security/app_tracking_transparency');

  Future<AppTrackingAuthorizationStatus> getStatus() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return AppTrackingAuthorizationStatus.notSupported;
    }

    try {
      final raw = await _channel.invokeMethod<String>('getTrackingStatus');
      return _parseStatus(raw);
    } catch (_) {
      return AppTrackingAuthorizationStatus.notSupported;
    }
  }

  Future<AppTrackingAuthorizationStatus> requestIfNeeded() async {
    final status = await getStatus();
    if (status != AppTrackingAuthorizationStatus.notDetermined) {
      return status;
    }

    try {
      final raw = await _channel.invokeMethod<String>(
        'requestTrackingAuthorization',
      );
      return _parseStatus(raw);
    } catch (_) {
      return status;
    }
  }

  AppTrackingAuthorizationStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'not_determined':
        return AppTrackingAuthorizationStatus.notDetermined;
      case 'restricted':
        return AppTrackingAuthorizationStatus.restricted;
      case 'denied':
        return AppTrackingAuthorizationStatus.denied;
      case 'authorized':
        return AppTrackingAuthorizationStatus.authorized;
      default:
        return AppTrackingAuthorizationStatus.notSupported;
    }
  }
}
