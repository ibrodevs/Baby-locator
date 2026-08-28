#!/usr/bin/env bash
# ==============================================================================
# Google Play Release Preflight Verification Script
# Project: Family Security (Baby Locator)
# ==============================================================================

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "================================================================="
echo "   FAMILY SECURITY — GOOGLE PLAY RELEASE PREFLIGHT CHECK"
echo "================================================================="
echo "Working directory: $REPO_ROOT"
echo ""

PASSED=0
FAILED=0

check_pass() {
  echo " [PASS] $1"
  PASSED=$((PASSED + 1))
}

check_fail() {
  echo " [FAIL] $1"
  FAILED=$((FAILED + 1))
}

echo "--- 1. ANDROID MANIFEST & PERMISSIONS AUDIT ---"

MANIFEST="android/app/src/main/AndroidManifest.xml"

# 1.1 Check QUERY_ALL_PACKAGES is removed
if grep -q "android.permission.QUERY_ALL_PACKAGES" "$MANIFEST"; then
  check_fail "QUERY_ALL_PACKAGES permission found in $MANIFEST (MUST BE REMOVED)"
else
  check_pass "QUERY_ALL_PACKAGES is NOT present in Manifest"
fi

# 1.2 Check isMonitoringTool meta-data exists
if grep -q 'android:name="isMonitoringTool"' "$MANIFEST" && grep -q 'android:value="child_monitoring"' "$MANIFEST"; then
  check_pass "Child monitoring flag <meta-data android:name=\"isMonitoringTool\" android:value=\"child_monitoring\" /> is present"
else
  check_fail "isMonitoringTool meta-data tag missing in $MANIFEST"
fi

# 1.3 Check isAccessibilityTool is NOT set to true
if grep -q 'android:name="isAccessibilityTool"' "$MANIFEST" || grep -q 'isAccessibilityTool="true"' "$MANIFEST"; then
  check_fail "isAccessibilityTool is present in $MANIFEST (MUST NOT BE PRESENT)"
else
  check_pass "isAccessibilityTool is NOT present (Compliant with Parental Control policy)"
fi

# 1.4 Check BackgroundService foregroundServiceType is strictly location
if grep -A 5 'id.flutter.flutter_background_service.BackgroundService' "$MANIFEST" | grep -q 'android:foregroundServiceType="location"'; then
  check_pass "BackgroundService foregroundServiceType is set to 'location'"
else
  check_fail "BackgroundService foregroundServiceType in $MANIFEST is not set to 'location'"
fi

# 1.5 Check <queries> launcher intent exists
if grep -q 'android.intent.category.LAUNCHER' "$MANIFEST"; then
  check_pass "Package visibility <queries> for launcher apps is configured"
else
  check_fail "<queries> for launcher apps missing in $MANIFEST"
fi

echo ""
echo "--- 2. GRADLE & TARGET SDK AUDIT ---"

BUILD_GRADLE="android/app/build.gradle.kts"

# 2.1 Check targetSdk is 34 or 35
if grep -q 'targetSdk = 35' "$BUILD_GRADLE" || grep -q 'targetSdk = 34' "$BUILD_GRADLE"; then
  check_pass "targetSdk is set to 35 (Android 15) in $BUILD_GRADLE"
else
  check_fail "targetSdk is not 34/35 in $BUILD_GRADLE"
fi

# 2.2 Check compileSdk is 35 or 36
if grep -q 'compileSdk = 36' "$BUILD_GRADLE" || grep -q 'compileSdk = 35' "$BUILD_GRADLE"; then
  check_pass "compileSdk is set to 36/35 in $BUILD_GRADLE"
else
  check_fail "compileSdk is not 36/35 in $BUILD_GRADLE"
fi

echo ""
echo "--- 3. PROMINENT DISCLOSURES CODE AUDIT ---"

# 3.1 Check BackgroundLocationDisclosureDialog
if [ -f "lib/core/widgets/background_location_disclosure.dart" ]; then
  check_pass "BackgroundLocationDisclosureDialog component exists"
else
  check_fail "BackgroundLocationDisclosureDialog component missing in lib/core/widgets/"
fi

# 3.2 Check AccessibilityDisclosureDialog
if [ -f "lib/core/widgets/accessibility_disclosure.dart" ]; then
  check_pass "AccessibilityDisclosureDialog component exists"
else
  check_fail "AccessibilityDisclosureDialog component missing in lib/core/widgets/"
fi

# 3.3 Check BackgroundCommandService configuration
if grep -q "AndroidForegroundType.location" "lib/core/services/background_command_service.dart"; then
  check_pass "background_command_service.dart uses AndroidForegroundType.location"
else
  check_fail "background_command_service.dart does not specify AndroidForegroundType.location"
fi

echo ""
echo "--- 4. PRIVACY POLICY & COMPLIANCE URLS ---"

# 4.1 Check Privacy policy file exists
if [ -f "privacy-policy.html" ] && [ -f "../Baby-locator-web/privacy-policy.html" ]; then
  check_pass "privacy-policy.html exists in app and web repositories"
else
  check_fail "privacy-policy.html missing in app or web repo"
fi

# 4.2 Check delete-account.html exists
if [ -f "delete-account.html" ] && [ -f "../Baby-locator-web/delete-account.html" ]; then
  check_pass "delete-account.html exists for Data Safety deletion requirements"
else
  check_fail "delete-account.html missing"
fi

echo ""
echo "================================================================="
echo "   PREFLIGHT SUMMARY: $PASSED PASSED, $FAILED FAILED"
echo "================================================================="

if [ "$FAILED" -gt 0 ]; then
  echo "Preflight check FAILED! Please fix the errors above before releasing."
  exit 1
else
  echo "All preflight checks PASSED! Codebase is ready for release build verification."
  exit 0
fi
