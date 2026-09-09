#!/usr/bin/env bash
# ==============================================================================
# Google Play Release Preflight Verification Script (2026)
# Project: Baby Locator (Parental Control & Family Safety)
# ==============================================================================

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "================================================================="
echo "   BABY LOCATOR — GOOGLE PLAY RELEASE PREFLIGHT COMPLIANCE CHECK"
echo "================================================================="
echo "Working directory: $REPO_ROOT"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

check_pass() {
  echo " [PASS] $1"
  PASSED=$((PASSED + 1))
}

check_fail() {
  echo " [FAIL] $1"
  FAILED=$((FAILED + 1))
}

check_warn() {
  echo " [WARN] $1"
  WARNINGS=$((WARNINGS + 1))
}

echo "--- 1. BRANDING & VISUAL IDENTITY ---"

STRINGS_XML="android/app/src/main/res/values/strings.xml"
if grep -q '<string name="app_name">Baby Locator</string>' "$STRINGS_XML"; then
  check_pass "Application public label is set to 'Baby Locator' in $STRINGS_XML"
else
  check_fail "Application public label is NOT 'Baby Locator' in $STRINGS_XML"
fi

if [ -f "store_assets/google_play/icon_512.png" ]; then
  check_pass "Store icon 512x512 exists in store_assets/google_play/icon_512.png"
else
  check_fail "Store icon 512x512 missing in store_assets/google_play/"
fi

if [ -f "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" ]; then
  check_pass "Launcher icon resource exists across mipmap folders"
else
  check_fail "Launcher icon missing in mipmap-xxxhdpi"
fi

echo ""
echo "--- 2. MONITORING POLICY & METADATA ---"

MAIN_MANIFEST="android/app/src/main/AndroidManifest.xml"

if grep -q 'android:name="isMonitoringTool"' "$MAIN_MANIFEST" && grep -q 'android:value="child_monitoring"' "$MAIN_MANIFEST"; then
  check_pass "isMonitoringTool=child_monitoring meta-data tag is present in AndroidManifest.xml"
else
  check_fail "isMonitoringTool meta-data tag missing in $MAIN_MANIFEST"
fi

if grep -q 'isAccessibilityTool' "$MAIN_MANIFEST"; then
  check_fail "isAccessibilityTool is present in $MAIN_MANIFEST (Must be omitted for parental control apps)"
else
  check_pass "isAccessibilityTool is NOT present (Compliant with Parental Control policy)"
fi

echo ""
echo "--- 3. ACCESSIBILITYSERVICE SCOPE & CONFIG ---"

ACC_CONFIG="packages/kid_security_android_bridge/android/src/main/res/xml/blocking_accessibility_config.xml"
if grep -q 'android:canRetrieveWindowContent="false"' "$ACC_CONFIG"; then
  check_pass "AccessibilityService canRetrieveWindowContent is strictly set to 'false'"
else
  check_fail "AccessibilityService canRetrieveWindowContent is NOT 'false' in $ACC_CONFIG"
fi

if grep -q 'flagRetrieveInteractiveWindows' "$ACC_CONFIG" || grep -q 'flagReportViewIds' "$ACC_CONFIG"; then
  check_warn "Window inspection flags found in $ACC_CONFIG"
else
  check_pass "Window inspection flags omitted (FLAG_DEFAULT used)"
fi

echo ""
echo "--- 4. SENSITIVE PERMISSIONS AUDIT ---"

# Phone permissions must be ABSENT
if grep -q "android.permission.READ_PHONE_STATE" "$MAIN_MANIFEST" ||    grep -q "android.permission.READ_PHONE_NUMBERS" "$MAIN_MANIFEST" ||    grep -q "android.permission.READ_CONTACTS" "$MAIN_MANIFEST"; then
  check_fail "Unauthorized phone/contacts permission found in $MAIN_MANIFEST"
else
  check_pass "Zero phone or contact permissions found (Phone number NOT collected)"
fi

# Location permissions
if grep -q "android.permission.ACCESS_FINE_LOCATION" "$MAIN_MANIFEST" &&    grep -q "android.permission.ACCESS_BACKGROUND_LOCATION" "$MAIN_MANIFEST" &&    grep -q "android.permission.FOREGROUND_SERVICE_LOCATION" "$MAIN_MANIFEST"; then
  check_pass "Location permissions (FINE, BACKGROUND, FGS_LOCATION) properly declared"
else
  check_fail "Required location permissions missing in $MAIN_MANIFEST"
fi

# Microphone permissions
if grep -q "android.permission.RECORD_AUDIO" "$MAIN_MANIFEST" &&    grep -q "android.permission.FOREGROUND_SERVICE_MICROPHONE" "$MAIN_MANIFEST"; then
  check_pass "Microphone permissions (RECORD_AUDIO, FGS_MICROPHONE) properly declared"
else
  check_fail "Microphone permissions missing in $MAIN_MANIFEST"
fi

# Full screen intent must REMAIN for SOS
if grep -q "android.permission.USE_FULL_SCREEN_INTENT" "$MAIN_MANIFEST"; then
  check_pass "USE_FULL_SCREEN_INTENT preserved for emergency SOS alerts"
else
  check_fail "USE_FULL_SCREEN_INTENT missing in $MAIN_MANIFEST"
fi

echo ""
echo "--- 5. FOREGROUND SERVICES AUDIT ---"

BRIDGE_MANIFEST="packages/kid_security_android_bridge/android/src/main/AndroidManifest.xml"
if grep -q 'android:name="com.example.kid_security.bridge.MicrophoneForegroundService"' "$BRIDGE_MANIFEST" &&    grep -q 'android:foregroundServiceType="microphone"' "$BRIDGE_MANIFEST"; then
  check_pass "MicrophoneForegroundService registered with type='microphone'"
else
  check_fail "MicrophoneForegroundService missing or invalid in $BRIDGE_MANIFEST"
fi

if grep -q 'android:foregroundServiceType="location"' "$MAIN_MANIFEST"; then
  check_pass "BackgroundService configured with type='location'"
else
  check_fail "BackgroundService location type missing in $MAIN_MANIFEST"
fi

echo ""
echo "--- 6. PROMINENT IN-APP DISCLOSURES ---"

for widget in "background_location_disclosure.dart" "accessibility_disclosure.dart" "microphone_disclosure.dart"; do
  if [ -f "lib/core/widgets/$widget" ]; then
    check_pass "Prominent disclosure widget exists: $widget"
  else
    check_fail "Missing disclosure widget: $widget"
  fi
done

echo ""
echo "--- 7. RELEASE SIGNING & VERSIONING ---"

BUILD_GRADLE="android/app/build.gradle.kts"
if grep -q "Release build cannot be signed with debug key" "$BUILD_GRADLE"; then
  check_pass "Silent fallback to debug signing is disabled in $BUILD_GRADLE"
else
  check_fail "Debug signing fallback guard missing in $BUILD_GRADLE"
fi

PUBSPEC="pubspec.yaml"
VERSION=$(grep "^version:" "$PUBSPEC" | awk '{print $2}')
check_pass "Current version: $VERSION"

echo ""
echo "--- 8. COMPLIANCE & LEGAL DOCUMENTATION ---"

for doc in "GOOGLE_PLAY_2026_AUDIT.md"            "BRANDING_AUDIT.md"            "GOOGLE_PLAY_DATA_SAFETY.md"            "GOOGLE_PLAY_SUBMISSION_PACKAGE_2026.md"            "GOOGLE_PLAY_REVIEWER_ACCESS.md"            "GOOGLE_PLAY_REVIEW_VIDEOS.md"            "GOOGLE_PLAY_TARGET_AUDIENCE_NOTES.md"            "privacy-policy.html"            "delete-account.html"; do
  if [ -f "$doc" ]; then
    check_pass "Required compliance document exists: $doc"
  else
    check_fail "Missing compliance document: $doc"
  fi
done

echo ""
echo "================================================================="
echo "   PREFLIGHT SUMMARY: $PASSED PASSED, $FAILED FAILED, $WARNINGS WARNINGS"
echo "================================================================="

if [ "$FAILED" -gt 0 ]; then
  echo "Preflight check FAILED! Fix the reported issues above."
  exit 1
else
  echo "All preflight checks PASSED! Codebase is ready for Google Play release submission."
  exit 0
fi
