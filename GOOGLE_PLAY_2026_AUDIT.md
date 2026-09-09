# Comprehensive Google Play Compliance & Technical Audit (2026)
**Application:** Baby Locator (Parental Control & Family Safety)  
**Package / Application ID:** `com.example.kid_security`  
**Date of Audit:** September 2026  
**Status:** In Remediation for Google Play Policy Compliance  

---

## 1. Executive Summary & Google Play Rejection Analysis

Google Play rejected the previous submission citing four key non-compliance issues:

1. **Misleading Claims / Store Listing Mismatch:**
   - **Finding:** The application label in `android/app/src/main/res/values/strings.xml` was set to `"Family Security"`, and the launcher icon resources in `res/mipmap-*` contained the default Flutter SDK logo rather than the official Baby Locator shield & child brand asset (`assets/1212.png`).
   - **Resolution:** Unify the public branding to **Baby Locator** across all application resources, metadata, manifests, notifications, and web pages. Generate consistent launcher icons and a 512×512 Google Play icon directly from `assets/1212.png`.

2. **AccessibilityService Description Missing from Google Play Listing:**
   - **Finding:** The store listing did not sufficiently detail the specific usage of the AccessibilityService API.
   - **Resolution:** Provide exact, transparent copy detailing that AccessibilityService is strictly used on the child device to detect the foreground application package name for parental App Blocking and Screen Time management.

3. **Missing `isMonitoringTool` Declaration:**
   - **Finding:** Google Play requires all parental monitoring applications to explicitly declare `isMonitoringTool="child_monitoring"` in the merged release manifest.
   - **Resolution:** Verify and enforce `<meta-data android:name="isMonitoringTool" android:value="child_monitoring" />` in the main manifest, release build, and preflight validation.

4. **Incomplete AccessibilityService Data Disclosures (Address & Phone Number):**
   - **Finding:** Google flagged undeclared data access for Address and Phone Number.
   - **Audit Result:**
     - **Address:** The application collects latitude and longitude and performs reverse geocoding via Google Maps API, storing the resulting street address in the backend (`LocationUpdate.address`) for display to the authenticated parent. This must be disclosed in the privacy policy, prominent disclosure, and Data Safety form.
     - **Phone Number:** Full audit confirmed that **phone numbers are NOT collected** anywhere in the mobile app or backend. AccessibilityService previously had `canRetrieveWindowContent="true"`, which theoretically permitted reading screen text. By restricting AccessibilityService to `canRetrieveWindowContent="false"` and relying strictly on `AccessibilityEvent.packageName`, screen inspection is eliminated.

---

## 2. Android Manifest & Permissions Audit

### 2.1 Manifest Permissions
| Permission | Purpose | Justification |
| :--- | :--- | :--- |
| `android.permission.ACCESS_FINE_LOCATION` | Precise GPS tracking | Core parental safety: child real-time map location & safe zones |
| `android.permission.ACCESS_COARSE_LOCATION` | Approximate cell/Wi-Fi location | Fallback location when GPS signal is degraded |
| `android.permission.ACCESS_BACKGROUND_LOCATION` | Background tracking | Allows linked parents to view child's location when app is minimized |
| `android.permission.FOREGROUND_SERVICE` | Base foreground service | Required for ongoing continuous background tasks |
| `android.permission.FOREGROUND_SERVICE_LOCATION` | Location FGS type | Required on Android 14+ for continuous location tracking |
| `android.permission.FOREGROUND_SERVICE_MICROPHONE` | Microphone FGS type | Required on Android 14+ for active Listen Around audio streaming |
| `android.permission.RECORD_AUDIO` | Microphone capture | Captures ambient audio during parent-initiated Listen Around session |
| `android.permission.MODIFY_AUDIO_SETTINGS` | Audio routing | Speakerphone / alarm routing for loud sound signal |
| `android.permission.POST_NOTIFICATIONS` | Notifications (Android 13+) | Required for monitoring notification, alerts, and chat messages |
| `android.permission.USE_FULL_SCREEN_INTENT` | Emergency full-screen alert | Reserved exclusively for immediate critical SOS emergency alerts |
| `android.permission.PACKAGE_USAGE_STATS` | App usage & screen time | Reads daily app usage minutes and foreground transitions (special access) |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Boot recovery | Restarts child monitoring service after device restart |
| `android.permission.WAKE_LOCK` | Wake lock | Ensures CPU does not sleep during active SOS or location transmission |
| `android.permission.VIBRATE` | Haptic feedback | Alert vibration for incoming SOS and notifications |
| `android.permission.INTERNET` | Network communication | Secure HTTPS / WebSocket communication with backend |
| `com.android.vending.BILLING` | In-app purchases | Google Play subscription processing (RevenueCat) |

### 2.2 Permissions Excluded / Not Requested
- `android.permission.QUERY_ALL_PACKAGES`: **NOT present**. Package visibility is handled via targeted `<queries>` for launcher intent.
- `android.permission.READ_PHONE_STATE`: **NOT present**.
- `android.permission.READ_PHONE_NUMBERS`: **NOT present**.
- `android.permission.READ_CONTACTS`: **NOT present**.
- `android.permission.CAMERA`: **NOT present**.

---

## 3. Foreground Services & Background Execution Audit

### 3.1 BackgroundService (`id.flutter.flutter_background_service.BackgroundService`)
- **Type:** `location` (`android:foregroundServiceType="location"`)
- **Lifecycle:** Starts when child mode is authenticated; auto-starts on boot if session is active.
- **Persistent Notification:**
  - Title: `Baby Locator`
  - Body: `Location and parental safety features are active.`
- **Responsibilities:** Periodic GPS polling, location updates, battery telemetry, checking blocked apps list.
- **Android 14+ Compliance:** Does not declare microphone type; avoids cold-boot `SecurityException` while-in-use crashes.

### 3.2 MicrophoneForegroundService (`com.example.kid_security.MicrophoneForegroundService`)
- **Type:** `microphone` (`android:foregroundServiceType="microphone"`)
- **Lifecycle:** On-demand; started only when a valid parent-initiated Listen Around session is active. Stopped immediately when the session ends or times out.
- **Persistent Notification:**
  - Title: `Baby Locator`
  - Body: `Microphone is active. Live audio is being shared with your linked parent.`
- **Prominent Disclosure:** A dedicated in-app disclosure modal is shown before requesting runtime `RECORD_AUDIO` permission.

---

## 4. AccessibilityService Audit & Scope Minimization

### 4.1 Component Configuration
- **Class:** `com.example.kid_security.bridge.BlockingAccessibilityService`
- **Config XML:** `res/xml/blocking_accessibility_config.xml`
- **Previous Configuration:**
  - `canRetrieveWindowContent="true"`
  - `flags="flagDefault|flagRetrieveInteractiveWindows|flagReportViewIds"`
  - Queried `windows` list and `rootInActiveWindow` nodes.
- **New Hardened Configuration:**
  - `canRetrieveWindowContent="false"`
  - `flags="flagDefault"`
  - Package detection relies strictly on `AccessibilityEvent.packageName` received in `TYPE_WINDOW_STATE_CHANGED` events.
  - Safe fallback: queries `UsageStatsManager` foreground package when accessibility event is delayed.
  - Exclusions: Automatically excludes system UI (`com.android.systemui`), settings (`com.android.settings`), package installer, device launchers, and Baby Locator itself.

---

## 5. Phone Number Audit (Evidence: NOT COLLECTED)

| Check | Target | Result | Evidence |
| :--- | :--- | :--- | :--- |
| Android Manifest | Permissions | **Passed** | Zero phone-related permissions (`READ_PHONE_STATE`, `READ_PHONE_NUMBERS`, `READ_CONTACTS` absent). |
| Native Code | Telephony APIs | **Passed** | No calls to `TelephonyManager`, `SubscriptionManager`, or `getLine1Number`. |
| Flutter Code | Models & Forms | **Passed** | No phone number text fields, models, or storage keys in `lib/`. |
| Backend Models | Django Accounts | **Passed** | `User` model contains `username`, `display_name`, `avatar`, `role`, `battery_level`, `fcm_token`. Zero phone fields. |
| Backend API | Serializers & Views | **Passed** | No phone data accepted, stored, or serialized. |
| Accessibility | Window Inspection | **Passed** | `canRetrieveWindowContent="false"` ensures no screen text nodes can be read. |

**Conclusion:** **Phone Number is NOT COLLECTED** by Baby Locator.

---

## 6. Location & Address Data Flow

1. **GPS Coordinates:** Gathered by child device via `Geolocator.getPositionStream` and `getCurrentPosition`.
2. **Reverse Geocoding:** Converted via Google Maps Geocoding API (`https://maps.googleapis.com/maps/api/geocode/json`) to a human-readable street address.
3. **Backend Storage:** Sent via `POST /api/locations/` and stored in `LocationUpdate` (`latitude`, `longitude`, `address`, `battery_level`).
4. **Parent Access:** Authenticated parent retrieves location history and latest address via `GET /api/children/<id>/location/`.
5. **Data Retention:** Retained with the child profile until account deletion or explicit history purge.

---

## 7. Listen Around (Microphone) Data Flow

1. **Parent Trigger:** Parent taps "Start Listening" in the Baby Locator app.
2. **Command Dispatch:** Backend creates a `RemoteDeviceCommand` (`around_start`) with a cryptographically secure `session_token`.
3. **FCM Delivery:** FCM message signals the child device to start audio streaming.
4. **Service Start:** Child app starts `MicrophoneForegroundService` displaying ongoing notification: `Baby Locator — Microphone is active. Live audio is being shared with your linked parent.`
5. **Native Capture & Stream:** `AroundAudioRecorder` captures raw mono PCM (16 kHz, 16-bit) and streams it via chunked HTTP POST to `/api/around-audio/live/upload/?session_token=...`.
6. **Live Broker:** Django backend `LiveAudioBroker` stores chunks in an ephemeral in-memory ring buffer (up to 512 KB FIFO) and relays them directly to the parent's download stream (`/api/children/<id>/around-audio/live/stream/`).
7. **Storage:** Live ambient audio is **ephemeral** and **not persisted to disk or database** during real-time streaming.
8. **Session Termination:** Stopped by parent or session timeout (typically 60–120 seconds).

---

## 8. Full Screen Intent & Emergency SOS

1. **Use Case:** Exclusively reserved for emergency SOS alerts triggered by a child.
2. **Android 14+ Handling:** Checked via `NotificationManager.canUseFullScreenIntent()`.
   - If granted: launches full-screen `SosAlertActivity` with emergency sound and vibration.
   - If denied: falls back to a maximum-priority heads-up notification with alarm audio and vibration, launching `SosAlertActivity` on tap.
3. **Policy Compliance:** No silent or background use of `USE_FULL_SCREEN_INTENT` for non-emergency tasks (e.g. Listen Around wake-up hack completely removed).

---

## 9. Account Deletion Audit

- **Web Endpoint:** `https://baby-locator.online/delete-account.html`
- **Mobile In-App:** Settings -> Delete Account with confirmation modal.
- **Backend API:** `DELETE /api/auth/me/` executes a cascading delete:
  - Parent deletion: deletes parent account, associated child profiles (when linked exclusively to this parent), location updates, alerts, app usage snapshots, and media files from storage.
  - Child deletion: deletes child data and disassociates from parent.
