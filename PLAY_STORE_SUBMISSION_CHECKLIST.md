# Google Play Store: Submission & Release Checklist

**Application:** Family Security (`com.company.familysecurity`)  
**Target Release Track:** Production / Closed Testing

---

## 1. Store Presence & Metadata

- [x] **App Name:** Family Security: Parental Control (or Family Security: Детская безопасность)
- [x] **Short Description:** Real-time child location tracking, safe zones, SOS alerts, and parental app blocking.
- [x] **Full Description:** Comprehensive description covering family safety, GPS tracking, safe zones, parental app blocking via AccessibilityService, and SOS assistance.
- [x] **App Icon:** 512x512 PNG (32-bit color, no alpha).
- [x] **Feature Graphic:** 1024x500 JPEG/PNG.
- [x] **Phone Screenshots:** At least 4 screenshots (Parent Map, Safe Zones, App Blocking, SOS Alerts).
- [x] **Tablet Screenshots:** 7-inch and 10-inch screenshots provided if tablet distribution is enabled.
- [x] **Category:** Parenting / Tools.
- [x] **Tags:** Parental Control, Family Locator, Child Safety, Screen Time.

---

## 2. Policy & Compliance Declarations

- [x] **Privacy Policy URL:** `https://baby-locator-web.vercel.app/privacy-policy.html` (Live, HTTPS, direct link, no redirects).
- [x] **Account & Data Deletion URL:** `https://baby-locator-web.vercel.app/delete-account.html` (Entered in Data Safety section).
- [x] **Target Audience & Content:**
  - Target age: Families (Parents of children).
  - Designed for Families / Family Policy compliant.
- [x] **AccessibilityService API Declaration:**
  - Filled out using [GOOGLE_PLAY_ACCESSIBILITY_DECLARATION.md](file:///Users/imac5/Desktop/Projects/Baby%20locator/Baby-locator/GOOGLE_PLAY_ACCESSIBILITY_DECLARATION.md).
  - Selected "Parental control / App blocking".
  - Attached demonstration video link.
- [x] **Location Permissions Declaration:**
  - Declared `ACCESS_BACKGROUND_LOCATION` for child real-time location tracking and safe zone departure/arrival alerts.
  - Attached Background Location demonstration video link.
- [x] **Data Safety Section:**
  - Filled out according to [GOOGLE_PLAY_DATA_SAFETY.md](file:///Users/imac5/Desktop/Projects/Baby%20locator/Baby-locator/GOOGLE_PLAY_DATA_SAFETY.md).
  - Declared location, user ID, messages, on-demand audio, and device identifiers.
- [x] **Monitoring App Declaration:**
  - `<meta-data android:name="isMonitoringTool" android:value="child_monitoring" />` present in Manifest.
  - Google Play Console questionnaire answered as a Parental Control / Monitoring app.
- [x] **Financial Features / Government Apps:** Marked Not Applicable.
- [x] **Advertising ID Declaration:** Marked No (if no third-party ad networks are used).

---

## 3. Technical & Build Requirements

- [x] **Target SDK:** 35 (Android 15).
- [x] **Min SDK:** 24 (Android 7.0).
- [x] **Package Format:** Android App Bundle (`.aab`).
- [x] **Release Signing:** Keystore configured via `android/key.properties`.
- [x] **FGS Policy:** Only `foregroundServiceType="location"` declared on continuous background service.
- [x] **Package Visibility:** `QUERY_ALL_PACKAGES` removed; replaced with targeted `<queries>`.
- [x] **Startup Stability:** All bootstrap flows protected by try-catch handlers and timeouts.
- [x] **In-App Disclosures:**
  - `BackgroundLocationDisclosureDialog` active before background location prompt.
  - `AccessibilityDisclosureDialog` active before accessibility settings navigation.

---

## 4. Test Track Strategy & Review Recommendations

1. **Internal / Closed Testing First:**
   - Upload AAB to Closed Testing track first.
   - Invite testers to verify on real Android 14 and Android 15 devices.
   - Verify that Google Play pre-launch reports show 0 crashes and 0 accessibility policy warnings.
2. **Reviewer Demo Credentials:**
   - In Google Play Console under **App access**, provide valid demo credentials:
     - **Parent account:** `test_parent_reviewer@gmail.com` / `ReviewerPass2026!`
     - **Child account / Pairing code:** `DEMO-777`
   - Include instructions: *"Log into the parent account to view map and app blocking controls. On child device, use code DEMO-777 to link and test child tracking and app blocking disclosure."*
