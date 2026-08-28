# Google Play Console: AccessibilityService Declaration Guide

**Application:** Family Security (`com.company.familysecurity`)  
**Purpose:** Official copy-paste responses and guidance for submitting the Google Play Accessibility Declaration.

---

## 1. Google Play Console Declaration Form Answers

### Question 1: Is your app an accessibility tool?
> **Answer:** **No**  
> *(The app is a Parental Control and Child Monitoring application, not an assistive tool specifically for people with disabilities).*

---

### Question 2: Which API(s) does your app use?
> **Selection:** Check **AccessibilityService API**

---

### Question 3: For what purpose does your app use the AccessibilityService API?
> **Selection:** Check **Parental control** / **App blocking / Screen time management**

---

### Question 4: Describe the app feature(s) that require the AccessibilityService API:
> **Paste the following text into the description field:**
>
> ```text
> Family Security uses the Android AccessibilityService API solely to provide the parental control "App Blocking" and screen time management feature on the child device.
> 
> When enabled by a parent with explicit in-app consent:
> 1. The service detects window transition events (TYPE_WINDOW_STATE_CHANGED and TYPE_WINDOWS_CHANGED) to resolve the package name of the active foreground application.
> 2. If the opened application matches an app restricted by parents in Family Security parental controls, the service displays a blocking screen overlay and brings the child back to the home launcher to enforce parental rules.
> 3. The service does NOT inspect, read, collect, or transmit screen text, personal chats, photos, keystrokes, passwords, or financial information.
> 4. The package name detection operates locally on the device to enforce blocking rules and does not transmit keystrokes or accessibility logs to remote servers.
> ```

---

### Question 5: What data does your app collect or share using the AccessibilityService API?
> **Paste the following text:**
>
> ```text
> None. The AccessibilityService API is used exclusively on-device to identify the package name of the active foreground app for the purpose of parental app blocking. 
> No personal information, user input, keystrokes, messages, passwords, or accessibility event details are collected, stored on external servers, sold, or shared with third parties.
> ```

---

### Question 6: Prominent Disclosure & Consent confirmation
> **Selection:** Check **Yes, the app displays a prominent disclosure before requesting the permission in the app.**
>
> **Details to provide if requested:**
> ```text
> Before the user is navigated to the system Accessibility Settings screen, Family Security displays a dedicated modal prominent disclosure dialog detailing:
> 1. Why AccessibilityService is needed (Parental App Blocking).
> 2. What data is processed (Active foreground package name only).
> 3. What data is NOT processed (No screen text, no keystrokes, no private messages, no passwords).
> 4. Clear options: "Continue to Settings" or "Cancel".
> ```

---

### Question 7: Link to Demonstration Video
> **Provide a direct YouTube / Google Drive link to the demonstration video.**  
> *(See Scenario 1 below for the exact video walkthrough script).*

---

## 2. Demonstration Video Script: AccessibilityService (App Blocking)

**Video Target Duration:** 45–60 seconds  
**Video Requirements:** Uncut video showing user flow from inside the app to Settings and back, with voiceover or English subtitles.

### Video Flow:
1. **0:00 - 0:10 | Launch Child App & Navigate to App Blocking**
   - Show device screen running Family Security in Child mode.
   - Tap on **App Blocking** or **Child Permissions**.
2. **0:10 - 0:25 | Prominent In-App Disclosure Dialog**
   - Tap "Enable App Blocking / Accessibility".
   - Show the prominent disclosure bottom sheet:
     - Clear title: *Parental App Blocking*
     - Clear subtitle: *Prominent Disclosure: AccessibilityService API Usage*
     - Highlights: Explains package name detection for parental limits, with explicit privacy guarantees (no text or keystroke logging).
   - Tap the primary button: **"Continue to Settings"**.
3. **0:25 - 0:38 | Android System Accessibility Settings**
   - The app navigates to Android Settings > Accessibility.
   - Show list of Installed Services.
   - Tap **"Family Security — App Blocking"**.
   - Show service description text.
   - Toggle switch to **ON** and accept the system permission dialog.
4. **0:38 - 0:55 | Demonstration of Feature in Action**
   - Return to the device Home screen.
   - Attempt to open a restricted application (e.g. YouTube or a game selected by parent).
   - Show the Family Security blocking overlay appearing immediately with message: *"[App] is blocked by parental controls"*.
   - Tap *"Back to Home"* or *"Open Family Security"*.
   - Conclude showing parental control enforcement working smoothly and safely.
