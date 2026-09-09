package com.example.kid_security.bridge

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.os.SystemClock
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityEvent

/**
 * Privacy-hardened AccessibilityService for parental app blocking.
 *
 * Scope minimization:
 * - canRetrieveWindowContent is set to false in XML configuration.
 * - FLAG_DEFAULT is used; interactive window inspection and view ID reporting are omitted.
 * - Detection relies strictly on AccessibilityEvent.packageName from TYPE_WINDOW_STATE_CHANGED.
 * - Safe fallback to UsageStatsManager queryEvents when event delivery is delayed.
 * - No screen text, node hierarchy, messages, passwords, addresses, or keystrokes are accessed.
 */
class BlockingAccessibilityService : AccessibilityService() {
    private val homePackages by lazy { resolveHomePackages(applicationContext) }
    private val mainHandler = Handler(Looper.getMainLooper())
    @Volatile
    private var lastObservedPackage: String? = null
    private var lastInterceptPackage: String? = null
    private var lastInterceptAtMs: Long = 0L
    private var lastBlockScreenAtMs: Long = 0L

    private val pollRunnable = object : Runnable {
        override fun run() {
            try {
                checkForeground()
            } catch (_: Throwable) {
                // Best effort — accessibility service must never crash
            }
            mainHandler.postDelayed(this, POLL_INTERVAL_MS)
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        try {
            serviceInfo = serviceInfo?.apply {
                eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
                flags = AccessibilityServiceInfo.DEFAULT
                notificationTimeout = 100L
            }
        } catch (_: Throwable) {
            // best effort
        }
        mainHandler.removeCallbacks(pollRunnable)
        mainHandler.postDelayed(pollRunnable, POLL_INTERVAL_MS)
    }

    override fun onUnbind(intent: Intent?): Boolean {
        mainHandler.removeCallbacks(pollRunnable)
        return super.onUnbind(intent)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val pkg = event.packageName?.toString()
            if (!pkg.isNullOrBlank()) {
                lastObservedPackage = pkg
                checkForeground(eventPackage = pkg)
            }
        }
    }

    override fun onInterrupt() {
        // no-op
    }

    private fun checkForeground(eventPackage: String? = null) {
        val pkg = resolveForegroundPackage(eventPackage) ?: return
        if (pkg == packageName) {
            // Our own UI (e.g. AppBlockedActivity) is on top — clear intercept latch
            lastInterceptPackage = null
            return
        }
        if (isProtectedPackage(applicationContext, pkg, homePackages)) {
            lastInterceptPackage = null
            return
        }
        if (!isBlocked(applicationContext, pkg)) {
            lastInterceptPackage = null
            return
        }

        val now = SystemClock.elapsedRealtime()
        if (lastInterceptPackage == pkg && now - lastInterceptAtMs < INTERCEPT_DEDUPE_MS) {
            return
        }
        lastInterceptPackage = pkg
        lastInterceptAtMs = now

        val movedBack = performGlobalAction(GLOBAL_ACTION_BACK)
        mainHandler.postDelayed({
            val current = resolveForegroundPackage()
            if (current == pkg && isBlocked(applicationContext, pkg)) {
                performGlobalAction(GLOBAL_ACTION_HOME)
            }
        }, BACK_VERIFY_DELAY_MS)
        if (!movedBack) {
            performGlobalAction(GLOBAL_ACTION_HOME)
        }

        if (now - lastBlockScreenAtMs < BLOCK_SCREEN_COOLDOWN_MS) {
            return
        }
        lastBlockScreenAtMs = now

        val appName = appLabelFor(pkg)
        mainHandler.postDelayed(
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

    /**
     * Resolves the foreground package identifier without traversing window content.
     * 1. Uses event package hint if provided.
     * 2. Falls back to last observed package from TYPE_WINDOW_STATE_CHANGED.
     * 3. Falls back to UsageStatsManager queryEvents if available.
     */
    private fun resolveForegroundPackage(hintFromEvent: String? = null): String? {
        val direct = hintFromEvent?.takeIf { it.isNotBlank() }
        if (direct != null) return direct

        val cached = lastObservedPackage?.takeIf { it.isNotBlank() }
        if (cached != null) return cached

        return getForegroundPackageFromUsageStats()
    }

    private fun getForegroundPackageFromUsageStats(): String? {
        if (!hasUsageStatsPermission()) return null
        return try {
            val usageStatsManager =
                applicationContext.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                    ?: return null
            val now = System.currentTimeMillis()
            val events = usageStatsManager.queryEvents(now - 15_000, now)
            val event = UsageEvents.Event()
            var currentPackage: String? = null

            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                val pkg = event.packageName ?: continue
                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED,
                    UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                        currentPackage = pkg
                    }
                    UsageEvents.Event.ACTIVITY_PAUSED,
                    UsageEvents.Event.ACTIVITY_STOPPED,
                    UsageEvents.Event.MOVE_TO_BACKGROUND -> {
                        if (pkg == currentPackage) {
                            currentPackage = null
                        }
                    }
                }
            }
            currentPackage
        } catch (_: Throwable) {
            null
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = applicationContext.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
            ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                applicationContext.packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                applicationContext.packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
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
        private const val INTERCEPT_DEDUPE_MS = 250L
        private const val BLOCK_SCREEN_COOLDOWN_MS = 1_500L
        private const val BLOCK_SCREEN_DELAY_MS = 80L
        private const val BACK_VERIFY_DELAY_MS = 220L
        private const val POLL_INTERVAL_MS = 700L
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
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
            }
            return context.packageManager
                .queryIntentActivities(intent, 0)
                .mapNotNull { it.activityInfo?.packageName }
                .toSet()
        }
    }
}
