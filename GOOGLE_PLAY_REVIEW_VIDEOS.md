# Baby Locator — Google Play Review Video Demonstration Scripts (2026)

This document contains step-by-step recording scripts for video demonstrations required during Google Play Console policy declaration reviews.

---

## Video 1: AccessibilityService & App Blocking (Duration: ~45–60 seconds)
- **Goal:** Prove prominent disclosure appears before system settings, demonstrates negative consent, and verifies App Blocking functionality.
- **Recording Steps:**
  1. Open Baby Locator on child device.
  2. Navigate to Child Permissions → "App Blocking (Accessibility)".
  3. Show the prominent disclosure modal completely visible on screen. Highlight the text stating it only reads package names and NEVER reads screen text, messages, passwords, or keystrokes.
  4. Tap "Not now". Show that system settings are NOT opened and permission is not granted.
  5. Tap the flow again.
  6. Tap "Continue" → Android Accessibility Settings open automatically.
  7. Locate and toggle "Baby Locator — App Blocking" to ON.
  8. Return to device home screen.
  9. Launch an app previously designated as blocked by the parent (e.g. browser).
  10. Demonstrate that the app is immediately exited/blocked and Baby Locator blocking screen appears.

---

## Video 2: Background Location (Duration: ~30–40 seconds)
- **Goal:** Demonstrate prominent disclosure on child device followed by affirmative consent and live tracking on parent map.
- **Recording Steps:**
  1. Open Baby Locator on child device.
  2. Trigger location permission setup.
  3. Show the Background Location prominent disclosure modal explaining continuous location and physical address sharing with the linked parent.
  4. Tap "Agree & Enable Location".
  5. On Android system dialog, select "Allow all the time".
  6. Switch view to Parent device/dashboard showing child location updated on the map with reverse-geocoded address.

---

## Video 3: Foreground Service Location & Monitoring (Duration: ~30 seconds)
- **Goal:** Demonstrate persistent user-visible notification during background monitoring.
- **Recording Steps:**
  1. Start child monitoring session on child device.
  2. Pull down Android notification shade.
  3. Show persistent notification:
     - Icon: Baby Locator official icon
     - Title: `Baby Locator`
     - Content: `Location and parental safety features are active.`
  4. Minimize the app and lock the device screen.
  5. Unlock screen and pull down notification shade to show persistent notification remained uninterrupted.
  6. Show parent device receiving updated location timestamp.

---

## Video 4: Microphone / Listen Around (Duration: ~35–45 seconds)
- **Goal:** Demonstrate user-visible ongoing notification during microphone capture and return to normal state upon termination.
- **Recording Steps:**
  1. On child device, show microphone permission disclosure and grant permission.
  2. On parent device, open child details and tap "Live audio around child".
  3. On child device, show the persistent notification immediately updating:
     - Title: `Baby Locator`
     - Content: `Microphone is active. Live audio is being shared with your linked parent.`
  4. On parent device, show live audio indicator active.
  5. Tap "Stop" on parent device.
  6. On child device, show the notification immediately restoring to normal monitoring mode (`Location and parental safety features are active.`).

---

## Video 5: Full Screen Intent & Emergency SOS (Duration: ~30–40 seconds)
- **Goal:** Demonstrate urgent SOS alert delivery to parent device.
- **Recording Steps:**
  1. Lock parent device screen.
  2. On child device, press the red "SOS Emergency" button.
  3. On parent device, show screen turning on with full-screen emergency alert overlay and siren audio.
  4. Demonstrate tapping the alert opens emergency coordinates on the map.
