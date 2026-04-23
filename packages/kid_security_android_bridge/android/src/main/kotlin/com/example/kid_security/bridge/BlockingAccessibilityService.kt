package com.example.kid_security.bridge

import android.accessibilityservice.AccessibilityService
import android.content.ComponentName
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityEvent

class BlockingAccessibilityService : AccessibilityService() {
    private val homePackages by lazy { resolveHomePackages(applicationContext) }
    private var lastBlockedPackage: String? = null
    private var lastBlockedAtMs: Long = 0L
    private var lastBlockScreenAtMs: Long = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return
        if (isProtectedPackage(applicationContext, pkg, homePackages)) return
        if (!isBlocked(applicationContext, pkg)) return

        val now = SystemClock.elapsedRealtime()
        if (lastBlockedPackage == pkg && now - lastBlockedAtMs < INTERCEPT_COOLDOWN_MS) {
            return
        }

        lastBlockedPackage = pkg
        lastBlockedAtMs = now

        val movedBack = performGlobalAction(GLOBAL_ACTION_BACK)
        if (!movedBack) {
            performGlobalAction(GLOBAL_ACTION_HOME)
        }

        if (now - lastBlockScreenAtMs < BLOCK_SCREEN_COOLDOWN_MS) {
            return
        }

        lastBlockScreenAtMs = now
        val appName = appLabelFor(pkg)
        Handler(Looper.getMainLooper()).postDelayed(
            {
                AppBlockedActivity.launch(
                    context = this,
                    blockedPackage = pkg,
                    appName = appName,
                )
            },
            BLOCK_SCREEN_DELAY_MS,
        )
    }

    override fun onInterrupt() {
        // no-op
    }

    private fun appLabelFor(packageName: String): String {
        return try {
            val info = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(info).toString()
        } catch (_: Exception) {
            packageName
        }
    }

    companion object {
        internal const val PREFS_NAME = "kid_security_blocking"
        internal const val KEY_PACKAGES = "blocked_packages"
        private const val INTERCEPT_COOLDOWN_MS = 900L
        private const val BLOCK_SCREEN_COOLDOWN_MS = 1_250L
        private const val BLOCK_SCREEN_DELAY_MS = 120L
        private val ESSENTIAL_PACKAGES = setOf(
            "android",
            "com.android.systemui",
            "com.android.settings",
            "com.android.permissioncontroller",
            "com.google.android.permissioncontroller",
            "com.android.packageinstaller",
            "com.google.android.packageinstaller",
        )

        fun isEnabled(context: Context): Boolean {
            val flatName = ComponentName(
                context,
                BlockingAccessibilityService::class.java,
            ).flattenToString()
            val enabled = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
            ) ?: return false
            val splitter = TextUtils.SimpleStringSplitter(':')
            splitter.setString(enabled)
            while (splitter.hasNext()) {
                if (splitter.next().equals(flatName, ignoreCase = true)) return true
            }
            return false
        }

        fun updatePackages(context: Context, packages: Collection<String>) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit()
                .putStringSet(KEY_PACKAGES, packages.toSet())
                .apply()
        }

        fun getBlockedPackages(context: Context): Set<String> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            return prefs.getStringSet(KEY_PACKAGES, emptySet()) ?: emptySet()
        }

        internal fun isProtectedPackage(
            context: Context,
            pkg: String,
            homePackages: Set<String> = resolveHomePackages(context),
        ): Boolean {
            if (pkg == context.packageName) return true
            if (pkg in ESSENTIAL_PACKAGES) return true
            if (pkg in homePackages) return true
            return false
        }

        private fun isBlocked(context: Context, pkg: String): Boolean {
            val blocked = getBlockedPackages(context)
            return blocked.contains(pkg)
        }

        private fun resolveHomePackages(context: Context): Set<String> {
            val intent = android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
                addCategory(android.content.Intent.CATEGORY_HOME)
            }
            return context.packageManager
                .queryIntentActivities(intent, 0)
                .mapNotNull { it.activityInfo?.packageName }
                .toSet()
        }
    }
}
