# Baby Locator — Google Play Submission Package (2026)

This document contains complete, ready-to-use submission texts, policy declarations, and console responses for submitting **Baby Locator** to Google Play.

---

## A. App Name
```text
Baby Locator
```

---

## B. Short Description (80 characters max)
```text
GPS child tracker, safe zones, screen time control, and emergency SOS alerts.
```

---

## C. Full Description
```text
Baby Locator is a comprehensive parental safety and child protection application designed exclusively for parents and legal guardians to safeguard their linked children.

KEY SAFETY FEATURES:

📍 Real-Time GPS Location Tracking:
View your child's live location on an interactive map at any time. Stay confident knowing where your child is when walking to school, playing outside, or returning home.

🕒 Movement History & Physical Addresses:
Review where your child has traveled throughout the day with precise route history and automatically reverse-geocoded physical street addresses.

🛡️ Safe Zones & Geofencing:
Set up custom virtual safety zones such as "Home", "School", or "Sports Club". Receive automatic push notifications whenever your child arrives at or leaves a designated safe zone.

⏳ Screen Time & App Blocking:
Protect your child from digital distractions. Monitor daily application usage and set healthy limits. Remotely block inappropriate or distracting games and social apps during homework or bedtime.

🔊 Listen Around (Ambient Audio):
When you are unable to reach your child by call, listen to live ambient surroundings to ensure your child is safe. A visible, persistent notification is always shown on the child device while audio is streaming.

🚨 Instant SOS Emergency Button:
In moments of danger, your child can press the SOS button to instantly alert you. Your device receives a critical full-screen emergency alert with siren and exact live GPS coordinates.

💬 Family Chat:
Stay connected through a secure, encrypted messaging channel within the app.

TRANSPARENT MONITORING & SAFETY:
• Baby Locator is exclusively intended for parents and legal guardians to monitor devices used by their children with mutual consent.
• The app cannot be installed secretly. A persistent, non-dismissible notification is prominently displayed on the child device whenever monitoring or location features are active.
• Audio capture is on-demand and clearly signaled to the child via an ongoing notification.
• All data transmission is encrypted via HTTPS/TLS, accessible strictly by authenticated parent accounts, and never sold to third parties.
```

---

## D. AccessibilityService Store Listing Disclosure (Copy/Paste)
```text
ACCESSIBILITY SERVICE USAGE DISCLOSURE:
Baby Locator uses the Android AccessibilityService API on child devices exclusively for the parental control "App Blocking" and "Screen Time" features.

How AccessibilityService is used:
• Detects the package name of the active application currently displayed on the screen.
• When a parent-restricted application is opened, Baby Locator immediately closes it and displays the blocking overlay.
• Helps parents enforce healthy device limits during school hours and sleep time.

Privacy & Data Protection Guarantee:
• Baby Locator is strictly configured with canRetrieveWindowContent="false".
• The service NEVER reads, accesses, logs, or stores on-screen text, personal messages, passwords, phone numbers, addresses, payment details, photos, or keystrokes.
• The service does not modify system settings without parental instruction and is not an accessibility tool for individuals with disabilities (isAccessibilityTool=false).
```

---

## E. Background Location Declaration (Google Play Declaration Form)

### 1. What is the core feature that requires background location access?
```text
Continuous child location sharing with the linked parent.
```

### 2. Detailed explanation of why background location is required:
```text
Baby Locator is a dedicated child safety and parental control solution. The primary safety value of the application is enabling parents to verify their child's physical safety even when the child's phone is locked, in a pocket, or when the Baby Locator application is closed.

Continuous background location access is strictly required to:
1. Deliver real-time GPS coordinates to the authenticated parent's map while the child travels between home and school.
2. Trigger automated entry and exit alerts for designated Safe Zones (geofences around home, school, and activities).
3. Immediately capture and transmit emergency coordinates when the child triggers an SOS alert.

Without background location, parental geofencing and real-time safety tracking cannot function when the child is not actively looking at the screen. A prominent disclosure modal is displayed before the system permission request, requiring affirmative parental consent.
```

---

## F. Foreground Service (FGS) Declarations

### 1. FOREGROUND_SERVICE_LOCATION
- **User-facing feature:** Continuous child safety tracking and Safe Zone geofence monitoring.
- **Why immediate/continuous execution is required:** Parents rely on timely alerts when a child arrives at or departs from safe zones. If background location is deferred or throttled, arrival/departure alerts can be delayed by 15–30 minutes, undermining child safety.
- **User notification:** Ongoing persistent notification: `Baby Locator — Location and parental safety features are active.`
- **Reviewer testing steps:** Launch child app with active parent link. Notice persistent monitoring notification. Put app in background or lock device. Parent map updates child location continuously.

### 2. FOREGROUND_SERVICE_MICROPHONE
- **User-facing feature:** On-demand Listen Around ambient audio streaming.
- **Why immediate/continuous execution is required:** When a parent requests Listen Around to check child surroundings, the child device must maintain an uninterrupted live audio stream to the authenticated parent without being killed by Android low-memory killer.
- **User notification:** Dedicated persistent notification: `Baby Locator — Microphone is active. Live audio is being shared with your linked parent.`
- **Reviewer testing steps:** From parent dashboard, tap "Listen Around". Child device immediately displays the persistent microphone notification and begins live streaming. Tap "Stop" on parent device; child notification restores to normal monitoring state.

---

## G. Full Screen Intent Declaration (USE_FULL_SCREEN_INTENT)

### 1. Feature description:
```text
Critical emergency SOS alert.
```

### 2. Justification:
```text
When a child is in distress, they activate the emergency SOS button. The linked parent's device must immediately receive an urgent, high-priority alert that wakes the screen and displays emergency GPS coordinates with sound and vibration, even if the parent's device is locked or screen is off. This capability is used exclusively for emergency child SOS events and is never used for advertising, marketing, or non-emergency tasks.
```

---

## H. Monitoring Tool Policy Declaration

- **Metadata in Manifest:** `<meta-data android:name="isMonitoringTool" android:value="child_monitoring" />`
- **Declaration Statement:**
```text
Baby Locator is exclusively designed and marketed for parents and legal guardians to monitor devices used by their children for family safety and parental control purposes.

Compliance checklist:
1. Target use case: Parent/guardian monitoring linked child.
2. Persistent notification: When child monitoring is active, a persistent, non-dismissible notification is continuously displayed with the official Baby Locator icon.
3. No covert operation: The application is never positioned or marketed as a spy, hidden surveillance, or spouse/employee monitoring tool.
4. Data minimization: AccessibilityService is restricted to package name inspection with canRetrieveWindowContent=false.
```

---

## I. Reviewer Access & Verification Notes

- **Parent credentials:** `play_reviewer_parent` / `ParentReviewerPass2026!`
- **Child credentials:** `play_reviewer_child` / `ChildReviewerPass2026!`
- **Linked status:** Pre-linked and configured with active subscription entitlement.
- **Detailed instructions:** See `GOOGLE_PLAY_REVIEWER_ACCESS.md`.
