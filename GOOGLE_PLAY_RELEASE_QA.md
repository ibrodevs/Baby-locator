# Google Play Release QA Matrix & Test Cases

**Application:** Family Security (`com.company.familysecurity`)  
**Target Release:** Production Google Play Track  
**Environment:** Android 11 (API 30), Android 12 (API 31), Android 13 (API 33), Android 14 (API 34), Android 15 (API 35)

---

## QA Test Matrix

| ID | Test Scenario | Steps | Expected Result | Result |
| :--- | :--- | :--- | :--- | :--- |
| **TC-A** | **Cold App Launch (Fresh Install)** | 1. Clean install app.<br>2. Launch app on Android 14/15.<br>3. Observe startup. | App opens smoothly without any crashes. Onboarding/Auth screen displays. Zero unhandled exceptions or foreground service crashes. | **PASS** |
| **TC-B** | **Cold Boot with Saved Child Session** | 1. Log in as child.<br>2. Kill app.<br>3. Relaunch app. | App boots cleanly into Child Home. No unprompted runtime permission dialogs appear on initial frame. | **PASS** |
| **TC-C** | **Offline App Launch** | 1. Enable Airplane mode.<br>2. Open app. | App launches without crashing. Shows offline friendly status or cached state gracefully without throwing unhandled network exceptions. | **PASS** |
| **TC-D** | **Parent Login & Child Linking** | 1. Register parent account.<br>2. Generate invite code.<br>3. Enter invite code on child device. | Parent-child link established. Backend confirms association. Child device appears in parent dashboard. | **PASS** |
| **TC-E** | **Foreground Location Flow** | 1. In child mode, tap map or start tracking.<br>2. Grant system "While using app" location permission. | Location icon updates. Current coordinates render on child map. | **PASS** |
| **TC-F** | **Background Location Prominent Disclosure** | 1. On child device, navigate to Permissions > Background Location.<br>2. Observe screen. | Dedicated prominent disclosure modal appears BEFORE system prompt, explaining 24/7 tracking, safe zones, and parent visibility. | **PASS** |
| **TC-G** | **Background Location System Grant** | 1. Tap "Agree & Continue" on disclosure.<br>2. Select "Allow all the time" in Android settings. | Background permission marked Granted. Location service continues tracking when screen is turned off or app is closed. | **PASS** |
| **TC-H** | **Background Location Disclosure Dismissal** | 1. Open Background Location disclosure.<br>2. Tap "Not now" or dismiss. | Modal closes cleanly. App does NOT crash. Foreground tracking continues if previously granted. | **PASS** |
| **TC-I** | **AccessibilityService Prominent Disclosure** | 1. Navigate to App Blocking or Child Permissions > Accessibility.<br>2. Tap Enable. | Dedicated prominent disclosure modal appears explaining package name detection for app blocking and explicit privacy guarantees (no text or keystroke logging). | **PASS** |
| **TC-J** | **AccessibilityService System Activation** | 1. Tap "Continue to Settings" on disclosure.<br>2. Enable "Family Security — App Blocking" in Accessibility Settings.<br>3. Return to app. | Accessibility status updates to Granted. Bridge service active. | **PASS** |
| **TC-K** | **App Blocking in Action** | 1. In parent app, mark YouTube or a target app as Blocked.<br>2. On child device, launch the blocked app. | Child device immediately detects the blocked app, brings up the Family Security blocking overlay, and redirects to Home launcher. | **PASS** |
| **TC-L** | **Emergency SOS Alert** | 1. On child screen, press and hold SOS button.<br>2. Verify parent device. | SOS event dispatched with immediate accurate GPS coordinates. Parent receives high-priority SOS alert notification. | **PASS** |
| **TC-M** | **Safe Zone Geofencing** | 1. Parent sets Home safe zone.<br>2. Child device coordinates move outside radius. | Exit event triggered. Parent receives push notification: "Child left Home". | **PASS** |
| **TC-Loud** | **Loud Siren / Alarm Command** | 1. Parent triggers Loud Signal from dashboard.<br>2. Observe child device. | Child device plays loud siren sound at max volume even if phone was muted. Parent can stop siren remotely. | **PASS** |
| **TC-Audio** | **On-Demand Ambient Audio** | 1. Parent requests Live Audio Around Child.<br>2. Verify child device and parent audio stream. | Child device captures ambient audio stream during active request. Zero continuous background recording when idle. | **PASS** |
| **TC-Usage** | **App Usage Statistics** | 1. Grant Usage Access on child device.<br>2. Open several apps.<br>3. Refresh stats in parent app. | Daily screen time and application usage times render accurately. | **PASS** |
| **TC-Del** | **In-App Account Deletion** | 1. Go to Settings > Account > Delete Account.<br>2. Confirm deletion. | Account deleted on backend. Session cleared. User redirected to onboarding screen. | **PASS** |
| **TC-WebDel**| **Web Account Deletion Portal** | 1. Open `https://baby-locator-web.vercel.app/delete-account.html`.<br>2. Verify instructions and support email. | Clean, working page explaining self-service and email deletion procedures. | **PASS** |
| **TC-Policy**| **Privacy Policy In-App & Web Link** | 1. Tap Privacy Policy in app settings.<br>2. Open web browser. | Direct URL `https://baby-locator-web.vercel.app/privacy-policy.html` loads without redirects or errors. Shows bilingual RU/EN text. | **PASS** |
| **TC-Rel** | **Release AAB Verification** | 1. Build release appbundle (`flutter build appbundle --release`).<br>2. Inspect bundle metadata. | AAB builds with 0 errors. TargetSdk = 35. Permissions verified. Merged manifest contains `isMonitoringTool="child_monitoring"`. | **PASS** |

---

## Verification Sign-Off
- **QA Lead:** Verified & Ready for Google Play Production Submission
- **Release Package:** Ready for Play Console Upload
