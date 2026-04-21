package com.example.kid_security.bridge

import android.accessibilityservice.AccessibilityService
import android.content.ComponentName
import android.content.Context
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityEvent

class BlockingAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return
        if (!isBlocked(applicationContext, pkg)) return
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    override fun onInterrupt() {
        // no-op
    }

    companion object {
        internal const val PREFS_NAME = "kid_security_blocking"
        internal const val KEY_PACKAGES = "blocked_packages"

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

        private fun isBlocked(context: Context, pkg: String): Boolean {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val blocked = prefs.getStringSet(KEY_PACKAGES, emptySet()) ?: return false
            return blocked.contains(pkg)
        }
    }
}
