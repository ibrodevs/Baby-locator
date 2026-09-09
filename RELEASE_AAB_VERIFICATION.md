# Baby Locator — Release AAB Verification & Compliance Report (2026)

This document summarizes the binary, manifest, and signing verification results for the production release artifact of **Baby Locator**.

---

## 1. Artifact Identity & Parameters

| Parameter | Configured Value | Status |
| :--- | :--- | :--- |
| **Application ID** | `com.example.kid_security` | **Retained Unchanged** (Matches existing Google Play App entity) |
| **Public App Label** | `Baby Locator` (via `@string/app_name`) | **VERIFIED** (Resolved mismatch with Store Listing) |
| **Version Name** | `1.0.5` | **VERIFIED** (Incremented from 1.0.4) |
| **Version Code** | `8` | **VERIFIED** (Incremented from 7 to supersede rejected builds) |
| **Target SDK** | `35` (Android 15) / `36` (Android 16 ready) | **VERIFIED** |
| **Min SDK** | `24` (Android 7.0+) | **VERIFIED** |

---

## 2. Release Manifest Inspection

### 2.1 Child Monitoring Metadata
```xml
<meta-data
    android:name="isMonitoringTool"
    android:value="child_monitoring" />
```
- **Status:** **PASS**. Confirmed present in `AndroidManifest.xml`.
- **Note:** `isAccessibilityTool` flag is strictly omitted, ensuring full compliance with Google Play Parental Control policy.

### 2.2 AccessibilityService Configuration
```xml
<service
    android:name="com.example.kid_security.bridge.BlockingAccessibilityService"
    android:label="@string/blocking_accessibility_label"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/blocking_accessibility_config" />
</service>
```
Configuration XML (`res/xml/blocking_accessibility_config.xml`):
```xml
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagDefault"
    android:canRetrieveWindowContent="false"
    android:notificationTimeout="100"
    android:description="@string/blocking_accessibility_description" />
```
- **`canRetrieveWindowContent`:** Strictly set to `false`.
- **Flags:** Hardened to `flagDefault`. Interactive window traversal and view ID reporting removed.
- **Data Scope:** Restricted strictly to `AccessibilityEvent.packageName`.

### 2.3 Foreground Service & Sensitive Permissions
- `android.permission.ACCESS_FINE_LOCATION`: Declared.
- `android.permission.ACCESS_BACKGROUND_LOCATION`: Declared.
- `android.permission.FOREGROUND_SERVICE_LOCATION`: Declared.
- `android.permission.RECORD_AUDIO`: Declared.
- `android.permission.FOREGROUND_SERVICE_MICROPHONE`: Declared.
- `android.permission.USE_FULL_SCREEN_INTENT`: Declared (emergency SOS only, with Android 14+ `NotificationManager.canUseFullScreenIntent()` compatibility check).
- `MicrophoneForegroundService`: Declared with `android:foregroundServiceType="microphone"`.
- `BackgroundService`: Declared with `android:foregroundServiceType="location"`.
- **Phone Permissions:** `READ_PHONE_STATE`, `READ_PHONE_NUMBERS`, `READ_CONTACTS` are **100% absent**.

---

## 3. Signing Configuration & Integrity

- **Keystore Location:** `android/app/upload-keystore.jks` (verified present).
- **Configuration File:** `android/key.properties` (verified present).
- **Release Signing Hardening:** The Gradle build configuration (`android/app/build.gradle.kts`) throws an explicit `GradleException` if signing credentials are missing when a release task is executed. Silent debug-signing fallback has been permanently disabled.

---

## 4. Visual Identity & Brand Consistency

- **Launcher Icon:** All density mipmap folders (`mipmap-mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`) have been regenerated directly from the official brand logo (`assets/1212.png`).
- **Store Icon:** Single source of truth 512×512 PNG created at `store_assets/google_play/icon_512.png`.
- **Installed App Name:** `Baby Locator`.
- **Play Store Title:** `Baby Locator`.
