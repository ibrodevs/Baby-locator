# Baby Locator — Branding Audit & Mapping (2026)

This document establishes the single source of truth for public branding and distinguishes public user-facing strings from intentionally retained internal technical identifiers.

---

## 1. Core Brand Principle

- **Official Public Product Name:** **Baby Locator**
- **Disallowed Public Brand Names:**
  - ❌ `Family Security` (previous name — causes Play Store mismatch rejection)
  - ❌ `Kid Security` / `KidSecurity`
  - ❌ `Baby-locator` (hyphenated)
  - ❌ `Kid Security App`

---

## 2. Branding Mapping Table

| Old Identifier / Value | Location / Component | Classification | New Value / Policy Decision | Rationale |
| :--- | :--- | :--- | :--- | :--- |
| `Family Security` | `android/app/.../res/values/strings.xml` (`app_name`) | **Public-Facing** | `Baby Locator` | Eliminates Google Play Store listing vs launcher name mismatch. |
| `Family Security — App Blocking` | `packages/kid_security_android_bridge/.../blocking_strings.xml` | **Public-Facing** | `Baby Locator — App Blocking` | Displayed in Android Accessibility Settings. |
| `Open Family Security` | `blocking_strings.xml` (`blocking_screen_open_app_button`) | **Public-Facing** | `Open Baby Locator` | Displayed on blocked app overlay. |
| `Family Security Pro` | `lib/l10n/app_*.arb`, `app_localizations_extras.dart` | **Public-Facing** | `Baby Locator Pro` | Paywall and subscription product display name. |
| `Family Security` | `lib/core/services/background_command_service.dart` | **Public-Facing** | `Baby Locator` | Foreground monitoring notification title. |
| `Family Security` | `lib/core/services/fcm_service.dart` | **Public-Facing** | `Baby Locator` | Push notification channel names and titles. |
| `Family Security` | `lib/core/widgets/accessibility_disclosure.dart` | **Public-Facing** | `Baby Locator` | Prominent in-app accessibility disclosure dialog. |
| `Family Security` | `lib/core/widgets/background_location_disclosure.dart` | **Public-Facing** | `Baby Locator` | Prominent background location disclosure dialog. |
| `Family Security` | `Baby-locator-web/index.html` | **Public-Facing** | `Baby Locator` | Public landing page title, meta, headers. |
| `Family Security` | `Baby-locator-web/privacy-policy.html` | **Public-Facing** | `Baby Locator` | Public Privacy Policy title and content. |
| `Family Security` | `Baby-locator-web/delete-account.html` | **Public-Facing** | `Baby Locator` | Public Account Deletion page. |
| Default Flutter Logo | `android/app/src/main/res/mipmap-*/ic_launcher.png` | **Public-Facing** | Baby Locator Shield Artwork (`assets/1212.png`) | Eliminates launcher icon mismatch with Play Store asset. |
| `com.example.kid_security` | `android/app/build.gradle.kts` (`applicationId`) | **Internal Technical** | **Retained Unchanged** | Changing applicationId breaks existing Play Console app entity and updates. |
| `com.example.kid_security` | Android packages, manifests, Activities | **Internal Technical** | **Retained Unchanged** | Internal Android namespace; zero user visibility. |
| `kid_security` | `pubspec.yaml` (`name: kid_security`), Dart imports | **Internal Technical** | **Retained Unchanged** | Dart package name; renaming would cause breaking import refactor without compliance benefit. |
| `kid_security_android_bridge` | Plugin package name and folder | **Internal Technical** | **Retained Unchanged** | Local path dependency; zero user visibility. |
| `AIzaSyD4gQl...` | Google Maps API key in Android & Dart | **Internal Technical** | **Retained Unchanged** | Explicit project owner constraint: DO NOT rotate or remove. |
| `baby-locator.online` | API and Web domain | **Internal Technical / Domain** | **Retained Unchanged** | Production server domain. |
