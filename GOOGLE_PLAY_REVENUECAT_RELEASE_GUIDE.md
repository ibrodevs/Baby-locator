# Google Play + RevenueCat Release Guide

Updated: 2026-05-09

This guide explains exactly what is still required to make Android subscriptions work end-to-end for this project.

Short answer: **no, it is not only "upload to Google Play"**.

The app code is already mostly ready, but before purchases work in production you still need to:

1. prepare the Android app for Play release;
2. configure signing and a real package name;
3. create the subscriptions in Google Play Console;
4. connect Google Play to RevenueCat;
5. configure RevenueCat products, entitlement, offering, and webhook;
6. upload a signed build to a Play testing track;
7. run a real test purchase from Google Play with a tester account.

---

## 1. Current project status

Already implemented in code:

- RevenueCat Flutter SDK integration
- login/logout sync with backend user ID
- paywall and restore purchases
- customer center button
- backend webhook endpoint
- premium gating in Flutter and Django

Important project-specific things still not ready for Play release:

- `android/app/build.gradle.kts` still uses:
  - `applicationId = "com.example.kid_security"`
  - debug signing for release builds
- `pubspec.yaml` is still `version: 1.0.0+1`
- release builds must use a real Android RevenueCat public SDK key, not the test fallback

Relevant files:

- [android/app/build.gradle.kts](/Users/imac5/Desktop/baby_locator/android/app/build.gradle.kts:1)
- [pubspec.yaml](/Users/imac5/Desktop/baby_locator/pubspec.yaml:1)
- [lib/core/subscriptions/subscription_service.dart](/Users/imac5/Desktop/baby_locator/lib/core/subscriptions/subscription_service.dart:1)
- [backend/subscriptions/views.py](/Users/imac5/Desktop/baby_locator/backend/subscriptions/views.py:1)
- [backend/subscriptions/services.py](/Users/imac5/Desktop/baby_locator/backend/subscriptions/services.py:1)

---

## 2. Recommended product model for Google Play

For this app, the cleanest Android setup is:

- one Google Play subscription product:
  - `family_security_pro`
- two base plans under it:
  - `monthly`
  - `yearly`

Recommended prices:

- monthly: **USD 5.99**
- yearly: **USD 29.99**

This works well with the current app because the UI already expects monthly and yearly packages, and RevenueCat can map them into the `default` offering.

Notes:

- In modern Google Play, users buy a **base plan**, not the parent subscription object directly.
- In RevenueCat, imported Google Play subscription products usually appear as:
  - `family_security_pro:monthly`
  - `family_security_pro:yearly`

That is normal.

---

## 3. Step 1: fix Android release configuration in this repo

Before uploading anything to Google Play, fix these items.

### 3.1 Set a real package name

Open [android/app/build.gradle.kts](/Users/imac5/Desktop/baby_locator/android/app/build.gradle.kts:1) and replace:

```kotlin
applicationId = "com.example.kid_security"
```

with your real unique package name, for example:

```kotlin
applicationId = "com.yourcompany.familysecurity"
```

Rules:

- this must be unique in Google Play;
- once published, changing it means publishing a different app;
- the same package name must be used in all Play test and production builds.

### 3.2 Configure release signing

Right now the project signs release builds with the debug key. That is not acceptable for Play production.

Create an upload keystore:

```bash
keytool -genkeypair -v \
  -keystore ~/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/Users/YOUR_USER/upload-keystore.jks
```

Then update `android/app/build.gradle.kts` to use that keystore for release.

Suggested Kotlin DSL pattern:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        load(FileInputStream(keystoreFile))
    }
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 3.3 Bump app version

Open [pubspec.yaml](/Users/imac5/Desktop/baby_locator/pubspec.yaml:4) and update:

```yaml
version: 1.0.0+1
```

Example:

```yaml
version: 1.0.1+2
```

Rules:

- `versionName` is the human version;
- `versionCode` must increase every time you upload a new Android bundle to Play.

### 3.4 Use the real Android RevenueCat SDK key

The app currently supports Android-specific dart defines:

```dart
REVENUECAT_API_KEY_ANDROID
```

For release builds, use your real Android public SDK key from RevenueCat:

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_API_KEY_ANDROID=YOUR_ANDROID_PUBLIC_SDK_KEY
```

Do not ship the test fallback key in production.

---

## 4. Step 2: prepare Google Play Console

Use official Google Play Console flows.

### 4.1 Create the app in Play Console

In Google Play Console:

1. Create the app.
2. Fill app name, default language, app type.
3. Complete the required Play Console setup items.

At minimum, expect to complete:

- App access
- Ads declaration
- Content rating
- Data safety
- Privacy policy
- Target audience if required for your category

### 4.2 Set up your payments profile

Subscriptions require Google Play billing to be active for your developer account.

If your payments profile is not configured, subscriptions will not be available.

### 4.3 Upload the first signed Android App Bundle

Google Play product creation/testing works much more reliably once a real bundle exists for the app.

Build the bundle:

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_API_KEY_ANDROID=YOUR_ANDROID_PUBLIC_SDK_KEY
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Upload it to Google Play Console.

Recommended first track:

- **Internal testing** for the fastest first upload

Google officially recommends internal testing for quick iteration, and it becomes available to testers very quickly.

---

## 5. Step 3: create the subscriptions in Google Play

Open:

- `Monetize with Play` -> `Products` -> `Subscriptions`

Create:

### Subscription product

- Subscription ID: `family_security_pro`
- Name: `Family Security Pro`

### Base plan 1

- Base plan ID: `monthly`
- Auto-renewing
- Price: **USD 5.99**
- Activate it

### Base plan 2

- Base plan ID: `yearly`
- Auto-renewing
- Price: **USD 29.99**
- Activate it

Important:

- the base plans must be **active**;
- the subscription must be available in at least one country;
- if you use offers or trials later, keep the basic monthly/yearly setup working first.

---

## 6. Step 4: connect Google Play to RevenueCat

In RevenueCat:

1. Open your project.
2. Connect the Android app to Google Play.
3. Import products from Google Play.

After import, you should see products similar to:

- `family_security_pro:monthly`
- `family_security_pro:yearly`

Then configure:

### Entitlement

- ID: `family_security_pro`

### Offering

- ID: `default`

### Packages inside `default`

- Monthly package -> map to the monthly Play product/base plan
- Annual package -> map to the yearly Play product/base plan

Important:

- your Flutter app uses the RevenueCat offering and package types;
- yearly should be assigned as the annual package;
- monthly should be assigned as the monthly package.

---

## 7. Step 5: configure the webhook correctly

Your backend endpoint is:

```text
POST /api/revenuecat/webhook/
```

Before testing real purchases:

1. Deploy your backend publicly over HTTPS.
2. Make sure the webhook URL is publicly reachable.
3. Set `REVENUECAT_WEBHOOK_AUTH_HEADER` on the backend.
4. Put the exact same header value into RevenueCat webhook settings.

Example backend env:

```bash
REVENUECAT_WEBHOOK_AUTH_HEADER='Bearer super-secret-revenuecat-webhook-token'
```

Example RevenueCat webhook header:

```text
Authorization: Bearer super-secret-revenuecat-webhook-token
```

Your backend already validates this header.

---

## 8. Step 6: create Google Play test users

For purchases to work in testing, testers must be configured correctly.

### 8.1 Add testers to a test track

In Play Console:

1. Go to `Testing`.
2. Start with `Internal testing`.
3. Add tester email addresses.
4. Publish the internal test release.

### 8.2 Configure license testing

In Play Console:

1. Go to `Settings` -> `License testing`.
2. Add the same tester Gmail accounts.

This is required for proper test purchases.

### 8.3 If you use closed testing

If you use a **closed test** instead of internal testing:

1. add testers to the closed track;
2. publish the closed release;
3. make sure testers open the **opt-in URL** and join the test.

If testers do not opt in, products often do not load.

---

## 9. Step 7: install the app the right way for testing

For the first true end-to-end purchase test, the safest method is:

1. publish the app to an internal or closed test track;
2. on the test Android phone, log into Google Play with the tester Gmail account;
3. install the app from Google Play;
4. log into the app with a real parent account.

Important:

- use a real Android device;
- make sure Google Play is present and working on the device;
- use the same package name as the uploaded Play app;
- the tester account should match both:
  - Play track tester
  - license tester

---

## 10. Step 8: run the first real purchase test

Use this exact sequence.

### 10.1 In the app

1. Log in as a parent.
2. Open the paywall.
3. Buy monthly or yearly.

### 10.2 In RevenueCat dashboard

Verify:

- the customer appears;
- `app_user_id` equals your backend user ID;
- sandbox transaction appears;
- entitlement `family_security_pro` becomes active.

### 10.3 In your backend

Verify:

- webhook hits your backend successfully;
- `user.is_premium = True`;
- premium entitlement fields are updated;
- premium endpoints are accessible.

### 10.4 In the app

Verify:

- one child is still free on main map;
- adding a second child becomes available after purchase;
- multi-child live map works;
- premium features unlock;
- restore purchases works.

---

## 11. Step 9: production rollout checklist

Before production release:

- real package name configured
- release signing configured
- version bumped
- backend deployed publicly over HTTPS
- RevenueCat Android public SDK key used in release build
- Google Play subscription product active
- Google Play monthly base plan active
- Google Play yearly base plan active
- RevenueCat products imported
- entitlement `family_security_pro` configured
- offering `default` configured
- monthly package mapped
- annual package mapped
- webhook configured
- webhook auth header matches backend env
- real test purchase succeeded
- restore purchase succeeded
- cancellation/renewal tested in sandbox

---

## 12. Common failure points for this repo

### Purchases do not load

Usually one of these:

- app installed with the wrong package name
- tester account is not on the Play test track
- tester account is not in License testing
- closed-track tester did not open the opt-in URL
- subscription/base plan is not active

### Purchase dialog opens but RevenueCat does not see the transaction

Usually one of these:

- wrong Android RevenueCat SDK key
- wrong Play app connected in RevenueCat
- product not imported/mapped correctly in RevenueCat

### Purchase succeeds in Google Play but backend does not unlock premium

Usually one of these:

- webhook URL is not public
- webhook auth header mismatch
- backend env is missing
- webhook is not configured in RevenueCat

### Release bundle cannot be uploaded

Usually one of these:

- release is still signed with debug key
- package name conflicts with another app
- versionCode was not incremented

---

## 13. My recommendation for your exact next move

Do these in order:

1. fix `applicationId` and release signing in `android/app/build.gradle.kts`
2. build a signed `.aab`
3. create the app in Play Console
4. upload the `.aab` to Internal testing
5. create the Google Play subscription `family_security_pro`
6. add base plans `monthly` and `yearly`
7. connect Google Play app to RevenueCat
8. import products into RevenueCat
9. map them to entitlement `family_security_pro` and offering `default`
10. deploy backend with webhook auth header
11. add testers + license testers
12. install from Play and perform one real test purchase

If you complete those steps, Android purchases should work.

---

## 14. Official references

Google Play official docs:

- [Create and manage subscriptions](https://support.google.com/googleplay/android-developer/answer/140504?hl=en-EN)
- [Set up an open, closed, or internal test](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en-EN)
- [Prepare and roll out a release](https://support.google.com/googleplay/android-developer/answer/9859348?hl=en-EN)
- [Test in-app billing with application licensing](https://support.google.com/googleplay/android-developer/answer/6062777?hl=en)

RevenueCat official docs:

- [Google Play Store testing](https://www.revenuecat.com/docs/google-play-store)
- [Google Play product setup](https://www.revenuecat.com/docs/getting-started/entitlements/android-products)
- [Products overview](https://www.revenuecat.com/docs/offerings/products-overview)
- [Webhooks](https://www.revenuecat.com/docs/integrations/webhooks)
- [Webhook event fields](https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields)
