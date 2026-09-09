# Baby Locator — Google Play Reviewer Access Guide (2026)

This guide provides test credentials and step-by-step verification instructions for Google Play policy review teams.

---

## 1. Test Credentials

| Account Role | Username / Identifier | Password | Status |
| :--- | :--- | :--- | :--- |
| **Parent Account** | `play_reviewer_parent` | `ParentReviewerPass2026!` | Pre-authenticated, PRO subscription active |
| **Child Account** | `play_reviewer_child` | `ChildReviewerPass2026!` | Linked to reviewer parent |

*(Note: If credentials need regeneration on backend, administrator executes:  
`python3 manage.py create_play_review_accounts`)*

---

## 2. Step-by-Step Reviewer Testing Walkthrough

### Scenario A: Parent Dashboard & Live Tracking
1. Launch **Baby Locator** on Device 1 (or emulator).
2. Select **Parent** mode and log in with:
   - Username: `play_reviewer_parent`
   - Password: `ParentReviewerPass2026!`
3. Verify the main dashboard displays the linked child **Reviewer Child**.
4. Tap on the child avatar to view the live GPS map, battery percentage, and reverse-geocoded physical street address.

### Scenario B: Child Mode & Monitoring Notification
1. Launch **Baby Locator** on Device 2 (or second emulator/instance).
2. Select **Child** mode and log in with:
   - Username: `play_reviewer_child`
   - Password: `ChildReviewerPass2026!`
3. Notice the persistent system notification appearing in the Android notification shade:
   - **Title:** `Baby Locator`
   - **Body:** `Location and parental safety features are active.`
4. Minimize the app or lock the device; verify the notification remains visible.

### Scenario C: AccessibilityService Prominent Disclosure & App Blocking
1. On Device 2 (Child), open **Child Settings** → **Permissions** → **App Blocking (Accessibility)**.
2. Verify the **Prominent Disclosure Modal** appears before launching Android Settings:
   - Explains package name detection for blocking parent-restricted apps.
   - States explicitly that screen text, keystrokes, messages, and passwords are never read or collected.
   - Offers affirmative **Continue** and **Not now** options.
3. Tap **Not now** → verify permission is not requested.
4. Open the modal again and tap **Continue** → Android Accessibility Settings open.
5. Enable **Baby Locator — App Blocking**.
6. On Device 1 (Parent), navigate to **App Blocking** and mark a test app (e.g. YouTube or Chrome) as blocked.
7. On Device 2 (Child), attempt to open the blocked app.
8. Verify the blocked app is immediately exited/closed and the Baby Locator blocking screen appears.

### Scenario D: Microphone / Listen Around Live Audio
1. On Device 2 (Child), verify microphone permission disclosure has been granted.
2. On Device 1 (Parent), navigate to child details and tap **Live audio around child** (Listen Around).
3. On Device 2 (Child), observe the persistent notification updating immediately to:
   - **Title:** `Baby Locator`
   - **Body:** `Microphone is active. Live audio is being shared with your linked parent.`
4. On Device 1 (Parent), audio streaming plays in real-time.
5. Tap **Stop** on Device 1.
6. Verify Device 2 (Child) immediately restores its notification to normal monitoring mode.

### Scenario E: Emergency SOS
1. On Device 2 (Child), press the red **SOS Emergency** button.
2. On Device 1 (Parent), an immediate high-priority alert is delivered:
   - Full-screen alert opens if special access is granted on Android 14+.
   - Heads-up alarm notification with siren sound opens if FSI access is pending.
3. Tap the alert to view the emergency map with current GPS coordinates.

### Scenario F: Account Deletion
1. On Device 1 (Parent), navigate to **Settings** → **Delete Account**.
2. Tap **Delete Account** and confirm.
3. Verify account session terminates immediately and user is logged out.
