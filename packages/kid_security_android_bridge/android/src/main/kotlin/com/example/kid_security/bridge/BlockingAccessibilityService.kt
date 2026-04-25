package com.example.kid_security.bridge

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityWindowInfo

class BlockingAccessibilityService : AccessibilityService() {
    private val homePackages by lazy { resolveHomePackages(applicationContext) }
    private val mainHandler = Handler(Looper.getMainLooper())
    private var lastInterceptPackage: String? = null
    private var lastInterceptAtMs: Long = 0L
    private var lastBlockScreenAtMs: Long = 0L
    private val pollRunnable = object : Runnable {
        override fun run() {
            try {
                checkForeground()
            } catch (_: Throwable) {
                // ignore — accessibility service must never crash
            }
            mainHandler.postDelayed(this, POLL_INTERVAL_MS)
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Make sure flags survive runtime — older Android versions sometimes
        // ignore manifest flags when the service is rebound.
        try {
            serviceInfo = serviceInfo?.apply {
                eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                    AccessibilityEvent.TYPE_WINDOWS_CHANGED
                flags = (flags or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS)
                notificationTimeout = 100L
            }
        } catch (_: Throwable) {
            // best effort
        }
        mainHandler.removeCallbacks(pollRunnable)
        mainHandler.postDelayed(pollRunnable, POLL_INTERVAL_MS)
    }

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        mainHandler.removeCallbacks(pollRunnable)
        return super.onUnbind(intent)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOWS_CHANGED -> {
                checkForeground(eventPackage = event.packageName?.toString())
            }
        }
    }

    override fun onInterrupt() {
        // no-op
    }

    private fun checkForeground(eventPackage: String? = null) {
        val pkg = resolveForegroundPackage(eventPackage) ?: return
        if (pkg == packageName) {
            // Our own UI (e.g. AppBlockedActivity) is on top — clear the
            // last-intercept latch so the very next attempt re-fires fast.
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
        // Tiny dedupe window — only suppress duplicate triggers that fire in
        // the same hundred-millisecond burst from multiple events. Long
        // cooldowns let users keep using a blocked app if back/home failed.
        if (lastInterceptPackage == pkg && now - lastInterceptAtMs < INTERCEPT_DEDUPE_MS) {
            return
        }
        lastInterceptPackage = pkg
        lastInterceptAtMs = now

        // Try several escape routes in order — back first (cheapest, less
        // disruptive); if it doesn't take us out within a tick, force home.
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
     * Picks the most reliable "what is the user actually looking at" answer.
     * `event.packageName` lies when an in-app dialog/popup/toast is showing,
     * so we prefer the active window from the live `windows` list and fall
     * back to event-derived data only when nothing else is available.
     */
    private fun resolveForegroundPackage(hintFromEvent: String? = null): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                val windowList: List<AccessibilityWindowInfo> = windows ?: emptyList()
                // Prefer the active+focused application window.
                val candidates = windowList
                    .filter { it.type == AccessibilityWindowInfo.TYPE_APPLICATION }
                    .sortedWith(
                        compareByDescending<AccessibilityWindowInfo> { it.isActive }
                            .thenByDescending { it.isFocused },
                    )
                for (window in candidates) {
                    val root: AccessibilityNodeInfo? = try {
                        window.root
                    } catch (_: Throwable) {
                        null
                    }
                    val pkg = root?.packageName?.toString()
                    if (!pkg.isNullOrBlank()) return pkg
                }
            } catch (_: Throwable) {
                // ignore — fall through to other strategies
            }
        }

        try {
            val rootNode: AccessibilityNodeInfo? = rootInActiveWindow
            val rootPkg = rootNode?.packageName?.toString()
            if (!rootPkg.isNullOrBlank()) return rootPkg
        } catch (_: Throwable) {
            // ignore
        }

        return hintFromEvent?.takeIf { it.isNotBlank() }
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
