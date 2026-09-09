# Baby Locator — Release AAB Verification & Compliance Report (2026)

This document provides the complete, authoritative verification record for the production Google Play release artifact of **Baby Locator**.

---

## 1. Artifact Identity & Cryptographic Hashes

| Parameter | Production Value | Verification Tool / Status |
| :--- | :--- | :--- |
| **Artifact File** | `app-release.aab` | `build/app/outputs/bundle/release/app-release.aab` |
| **File Size** | `112,381,882 bytes` (~112.3 MB) | Verified via `ls -la` / `stat` |
| **SHA-256 Checksum** | `ef674b36e98cbb5b7c6cfa902fd97811c7c6b9710115d99e46546e62a9582996` | Verified via `shasum -a 256` |
| **Package / Application ID** | `com.company.familysecurity` | Matches Play Console registered app entity |
| **Public App Label** | `Baby Locator` (via `@string/app_name`) | Verified across all languages & configurations |
| **Version Name** | `1.0.5` | Verified via `bundletool` & `apkanalyzer` |
| **Version Code** | `8` | Supersedes all rejected / prior builds (code 7) |
| **Target SDK** | `36` (Android 16 ready; min requirement 35) | Verified via `apkanalyzer manifest target-sdk` |
| **Min SDK** | `24` (Android 7.0 Nougat+) | Verified via `apkanalyzer manifest min-sdk` |

---

## 2. Cryptographic Signing & Integrity Verification

The release bundle was built using the official upload keystore and verified using multiple integrity schemes:

### 2.1 Keystore Credentials & Certificate
- **Keystore File:** `android/app/upload-keystore.jks`
- **Key Alias:** `upload`
- **Certificate DN:** `CN=FamilySecurity, OU=Mobile, O=Quantum, L=Bishkek, ST=Chuy, C=KG`
- **Algorithm:** RSA 2048-bit
- **Signer Certificate SHA-256 Digest:**
  ```text
  97:FA:D0:26:0A:A3:33:50:2D:0F:80:75:ED:6D:95:97:05:96:3B:E1:1F:EF:9C:5D:C5:76:49:3C:A6:10:89:1B
  ```
- **Signer Certificate SHA-1 Digest:**
  ```text
  da:0c:b2:38:b5:ac:bf:bb:cd:36:6e:38:46:1a:b4:2e:e6:59:7d:8b
  ```

### 2.2 Signature Scheme Compliance
- **AAB Bundle Verification (`jarsigner -verify`):** `jar verified.` (Pass).
- **Bundletool Validation (`bundletool validate`):** Validated with exit code `0` (Pass).
- **APK Signature Schemes (via `apksigner verify -v` on universal extraction):**
  - **APK Signature Scheme v1 (JAR signing):** `false` (AAB uses v2/v3 on target APKs)
  - **APK Signature Scheme v2:** `true` (Pass)
  - **APK Signature Scheme v3:** `true` (Pass)
- **Debug-Key Prevention:** Silent fallback to debug keys is permanently blocked in `build.gradle.kts`. Any release build attempt without the upload keystore triggers an immediate `GradleException`.

---

## 3. Native Architecture & Binary Library Audit

All architectures required for modern Android distribution are compiled and bundled:

| Architecture | 64-bit / 32-bit | Native Libraries Included | Status |
| :--- | :--- | :--- | :--- |
| **`arm64-v8a`** | 64-bit ARM | `libandroidx.graphics.path.so`<br>`libapp.so`<br>`libdartjni.so`<br>`libdatastore_shared_counter.so`<br>`libflutter.so`<br>`libjingle_peerconnection_so.so` | **PASS** (Google Play 64-bit requirement fulfilled) |
| **`armeabi-v7a`** | 32-bit ARM | `libandroidx.graphics.path.so`<br>`libapp.so`<br>`libdartjni.so`<br>`libdatastore_shared_counter.so`<br>`libflutter.so`<br>`libjingle_peerconnection_so.so` | **PASS** (Legacy device compatibility) |
| **`x86_64`** | 64-bit x86 | `libandroidx.graphics.path.so`<br>`libapp.so`<br>`libdartjni.so`<br>`libdatastore_shared_counter.so`<br>`libflutter.so`<br>`libjingle_peerconnection_so.so` | **PASS** (Chromebooks & modern emulators) |

---

## 4. Manifest Policy Compliance Inspection

The merged release manifest (`aab-manifest.xml`) has been audited against Google Play 2026 policy guidelines:

### 4.1 Monitoring Policy Metadata
```xml
<meta-data
    android:name="isMonitoringTool"
    android:value="child_monitoring" />
```
- **Status:** **PASS**. Confirmed present directly under `<application>`.
- **Note:** `isAccessibilityTool` is **omitted**, complying with Google Play's rule prohibiting parental control apps from posing as general accessibility utilities.

### 4.2 AccessibilityService Scope & Configuration
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
- **`canRetrieveWindowContent`:** Strictly set to `false`. Accessibility node hierarchy traversal, screen reading, passwords, and user inputs are inaccessible at the OS level.
- **Flags:** `flagDefault`. Interactive window traversal flags (`flagRetrieveInteractiveWindows`, `flagReportViewIds`) are completely removed.
- **Detection Mechanism:** Strictly package-level (`AccessibilityEvent.packageName`) with safe fallback to `UsageStatsManager`.

### 4.3 Sensitive Permissions Audit
| Permission | Policy Category | Justification |
| :--- | :--- | :--- |
| `ACCESS_FINE_LOCATION` | Location | Real-time GPS child tracking |
| `ACCESS_COARSE_LOCATION` | Location | Approximate location & battery savings |
| `ACCESS_BACKGROUND_LOCATION` | Location (Special) | Safety zone geofencing & real-time alerts when child app is in background |
| `FOREGROUND_SERVICE_LOCATION` | FGS | Continuous location reporting under Android 14+ |
| `RECORD_AUDIO` | Microphone | Listen Around parental ambient audio monitoring |
| `FOREGROUND_SERVICE_MICROPHONE` | FGS | Continuous microphone capture under Android 14+ with ongoing notification |
| `USE_FULL_SCREEN_INTENT` | Emergency Alert | Reserved strictly for high-urgency child SOS alarm; Android 14+ check with notification fallback |
| `PACKAGE_USAGE_STATS` | Device Activity | Screen time reporting and app blocking fallback |
| `READ_PHONE_STATE` | Phone | **ABSENT (100% Not Collected)** |
| `READ_PHONE_NUMBERS` | Phone | **ABSENT (100% Not Collected)** |
| `READ_CONTACTS` | Contacts | **ABSENT (100% Not Collected)** |

---

## 5. Device Regression Gate (Requires Real Android Devices)

Because no physical Android devices were attached to the host during automated compilation, the following test matrix must be completed on real devices running Android 10, 12, 13, 14, 15, and 16 before final rollout:

| Functional Area | Test Scenario & Acceptance Criteria | Target OS Versions | Manual Test Status |
| :--- | :--- | :--- | :--- |
| **1. Authentication & Pairing** | Parent account registration; child pairing via 6-digit invite code; session restoration after process kill; logout. | Android 10–16 | ⏳ Requires physical device |
| **2. App Blocking (Accessibility)** | 1. Parent remotely blocks an app (e.g. YouTube).<br>2. Child launches the blocked app.<br>3. `BlockingAccessibilityService` intercepts package, issues `GLOBAL_ACTION_BACK`, and displays `AppBlockedActivity`.<br>4. Pressing Back does NOT reveal the blocked app.<br>5. Parent remotely unblocks: app launches immediately.<br>6. Device reboot: blocking persists (`BOOT_COMPLETED`).<br>7. System apps (Launcher, Settings, Phone) are NEVER blocked. | Android 10–16 | ⏳ Requires physical device |
| **3. Listen Around (Microphone)** | 1. Prominent disclosure modal appears before runtime permission.<br>2. Declining disclosure does not request Android permission.<br>3. Parent requests Listen Around: child device receives high-priority request (not silent FSI wake-up).<br>4. Upon starting capture, persistent ongoing notification is visible in notification shade (`FOREGROUND_SERVICE_MICROPHONE`).<br>5. Live audio streams via WebRTC.<br>6. Parent stops: microphone FGS immediately terminates and notification disappears. | Android 12–16 | ⏳ Requires physical device |
| **4. Emergency SOS (FSI)** | 1. Child triggers SOS button.<br>2. Parent device locked: Full-Screen Intent wakes device and sounds loud siren.<br>3. **Android 14+ Specific:** If user denied `USE_FULL_SCREEN_INTENT` in Special App Access, app falls back gracefully to a high-priority Heads-Up Notification with sound and vibration.<br>4. Parent tapping notification opens the SOS alert map. | Android 10–16 (Focus on 14+) | ⏳ Requires physical device |
| **5. Background Location & Geofencing** | 1. Prominent disclosure modal shown before background location permission.<br>2. User selects "Allow all the time" in OS settings.<br>3. Child leaves Safe Zone: parent receives instant push notification.<br>4. Location updates continue while screen is locked and in Doze mode. | Android 10–16 | ⏳ Requires physical device |
| **6. Account Deletion** | 1. Parent taps "Delete Account" in settings.<br>2. App calls `DELETE /api/auth/me/`.<br>3. Backend cascades deletion: linked child profiles, location records, chat messages, and storage media files are wiped.<br>4. App logs out and returns to onboarding. | Android / Server | ✅ Verified via automated backend tests (16/16 pass); live staging run recommended |

---

## 6. Verification Summary & Next Steps

- **Build Quality:** Fully compliant release AAB produced, signed with production upload key, and validated through `bundletool` and `apksigner`.
- **Policy Compliance:** Zero undeclared permissions; `isMonitoringTool="child_monitoring"` confirmed; AccessibilityService hardened to `canRetrieveWindowContent="false"`.
- **Readiness:** Artifact is prepared for upload to Google Play Console closed testing / production track.
