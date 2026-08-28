# Google Play Compliance & Architecture Audit

**Project:** Family Security / Baby Locator  
**Package:** `com.company.familysecurity`  
**Developer:** Quantum limited  
**Date:** August 28, 2026  
**Target SDK:** 35 (Android 15)  
**Min SDK:** 24 (Android 7.0)  

---

## 1. Compliance Audit Matrix

| Policy Area / Requirement | File & Location | Previous Status / Violation | Technical Root Cause | Resolution & Status |
| :--- | :--- | :--- | :--- | :--- |
| **Startup Stability & Crashes** | `lib/main.dart`<br>`lib/core/services/background_command_service.dart`<br>`AndroidManifest.xml` | **REJECTED**<br>“After launch the app crashes” | Service started with multiple foreground service types (`location\|microphone\|mediaPlayback`). On Android 14+, starting FGS with type `microphone` without granted `RECORD_AUDIO` or from background triggers fatal `SecurityException`. Unhandled timeouts during bootstrap also caused crashes. | **RESOLVED (100% Compliant)**<br>Continuous FGS restricted strictly to `location` (`AndroidForegroundType.location`). Multi-type removed. Defensive try-catch around bootstrap, isolate entry points, notification channel creation, and background isolate lifecycle. |
| **AccessibilityService Policy** | `AndroidManifest.xml`<br>`packages/kid_security_android_bridge/.../BlockingAccessibilityService.kt`<br>`lib/core/widgets/accessibility_disclosure.dart` | **REJECTED**<br>Missing/invalid declaration, no prominent in-app disclosure before settings navigation, lack of demo video context. | Previous version opened `Settings.ACTION_ACCESSIBILITY_SETTINGS` directly without in-app disclosure explaining why AccessibilityService is needed and what data is accessed. | **RESOLVED (100% Compliant)**<br>1. Prominent in-app disclosure modal shown before navigating to Settings.<br>2. Clear statement that AccessibilityService is used exclusively for Parental App Blocking.<br>3. Explicit privacy guarantee: NO screen text, keystrokes, passwords, or personal messages read/collected.<br>4. English & Russian service descriptions in XML.<br>5. `isAccessibilityTool` flag omitted. |
| **Background Location Policy** | `lib/core/services/location_service.dart`<br>`lib/core/widgets/background_location_disclosure.dart`<br>`lib/features/child/child_permissions_screen.dart` | **REJECTED**<br>No prominent disclosure before system runtime prompt; background location requested without clear user consent. | `Permission.locationAlways.request()` was triggered without preceding in-app disclosure explaining 24/7 background tracking and parent visibility. | **RESOLVED (100% Compliant)**<br>1. Dedicated `BackgroundLocationDisclosureDialog` shown before any background location request.<br>2. Clearly explains continuous location tracking when closed/in background for parental map, safe zones, and SOS.<br>3. Explicit "Agree & Continue" vs "Not now" options.<br>4. Graceful fallback to foreground-only if denied. |
| **Monitoring App Policy** | `android/app/src/main/AndroidManifest.xml` | **VIOLATION RISK**<br>Missing mandatory child monitoring meta-data tag. | Google Play Parental Control / Monitoring apps require `<meta-data android:name="isMonitoringTool" android:value="child_monitoring" />`. | **RESOLVED (100% Compliant)**<br>Added `<meta-data android:name="isMonitoringTool" android:value="child_monitoring" />` under `<application>` in `AndroidManifest.xml`. |
| **Package Visibility (`QUERY_ALL_PACKAGES`)** | `android/app/src/main/AndroidManifest.xml`<br>`KidSecurityAndroidBridgePlugin.kt` | **VIOLATION RISK**<br>Overly broad permission `QUERY_ALL_PACKAGES` triggers automatic Google Play rejection. | High-risk permission declared without strict necessity. App only needs launcher activities to show installed apps for parent blocking. | **RESOLVED (100% Compliant)**<br>Removed `<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />`. Added targeted `<queries>` intent filter for `android.intent.action.MAIN` with `android.intent.category.LAUNCHER`. |
| **Privacy Policy URL & Transparency** | `Baby-locator-web/privacy-policy.html`<br>`lib/core/compliance/app_compliance.dart`<br>`features/settings/settings_screen.dart` | **REJECTED**<br>Policy not directly accessible or missing specific disclosures. | Privacy policy was hosted on nested or redirect paths and lacked explicit sections on AccessibilityService and background location. | **RESOLVED (100% Compliant)**<br>Direct, single-page web policy at `https://baby-locator-web.vercel.app/privacy-policy.html` with explicit sections for Developer identity, Background Location, AccessibilityService, Data Deletion, and COPPA/Child safety. |
| **Account & Data Deletion** | `Baby-locator-web/delete-account.html`<br>`lib/core/compliance/app_compliance.dart`<br>`features/settings/settings_screen.dart` | **MANDATORY POLICY**<br>Google Play Data Safety requirement for account deletion web link. | Missing web-accessible account deletion request URL. | **RESOLVED (100% Compliant)**<br>Created dedicated web deletion page at `https://baby-locator-web.vercel.app/delete-account.html` and in-app account deletion under Settings > Account. |
| **Foreground Service Types (Android 14+)** | `AndroidManifest.xml`<br>`background_command_service.dart` | **CRASH / REJECTION**<br>Foreground service type mismatch. | BackgroundService declared multi-type `location\|microphone\|mediaPlayback`. Microphone FGS type requires Top Activity and granted `RECORD_AUDIO`. | **RESOLVED (100% Compliant)**<br>Continuous tracking service configured exclusively as `foregroundServiceType="location"`. Audio capture handled on-demand during active session. |

---

## 2. Deep Dive: Crash Analysis & Fixes

### A. Android 14+ Foreground Service Crash (`SecurityException`)
- **Vulnerability:** When a Flutter background service declared `foregroundServiceType="location|microphone|mediaPlayback"` in the Manifest, Android 14 enforced runtime permission checks at service start (`startForeground`). Because microphone permission (`RECORD_AUDIO`) is not granted on cold-boot or child onboarding, the operating system threw a fatal `SecurityException`.
- **Fix:** 
  1. Updated `AndroidManifest.xml` to set `android:foregroundServiceType="location"`.
  2. Updated `background_command_service.dart` to set `foregroundServiceTypes: [AndroidForegroundType.location]`.
  3. Removed `FOREGROUND_SERVICE_MICROPHONE` and `FOREGROUND_SERVICE_MEDIA_PLAYBACK` from continuous service scope.

### B. Cold Boot Permission Race Condition
- **Vulnerability:** `RemoteDeviceService.start()` was executing multiple asynchronous permission requests (`requestBackgroundPermission()`, `microphone.request()`, `notification.request()`) sequentially during app bootstrap. This produced unhandled platform channel exceptions, dialog collisions, and Google Play policy violations.
- **Fix:** Removed automated unprompted permission triggers from `RemoteDeviceService.start()`. Permissions are now requested strictly inside explicit UI screens (`ChildPermissionsScreen`, Onboarding, or feature interactions) with preceding prominent disclosures.

### C. Offline / Network Timeout Startup Resilience
- **Vulnerability:** If the backend API took longer than expected or was unreachable, unhandled exceptions during `_bootstrapApp` could prevent Flutter UI from rendering.
- **Fix:** All bootstrap futures (`localeProvider`, `sessionProvider`, `subscriptionServiceProvider`, `FcmService`, `initBackgroundCommandService`) are wrapped in isolated `try-catch` blocks with explicit fallback timeouts. If network is offline, the app renders cached or default UI safely without crashing.

---

## 3. Policy Alignment Verification

1. **Child Monitoring Standard**: Verified `<meta-data android:name="isMonitoringTool" android:value="child_monitoring" />`.
2. **Prominent Disclosures**: Verified both Background Location and AccessibilityService show modal disclosures before system prompts.
3. **No Keylogging / Screen Content Harvesting**: Accessibility service does not inspect node texts or keystrokes.
4. **Target SDK**: Verified `targetSdk = 35` in `app/build.gradle.kts`.
5. **No Dangerous Permissions**: `QUERY_ALL_PACKAGES` completely removed.
