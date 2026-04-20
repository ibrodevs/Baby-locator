package com.example.kid_security

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "kid_security/device_stats"
        private const val VOLUME_CHANNEL = "kid_security/volume"
    }

    private var savedVolume: Int = -1
    private val homePackages by lazy { resolveHomePackages() }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceStats" -> {
                        val days = call.argument<Int>("days") ?: 35
                        result.success(getDeviceStats(days))
                    }

                    "openUsageAccessSettings" -> {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    }

                    "getForegroundPackage" -> {
                        result.success(getForegroundPackage())
                    }

                    "goHome" -> {
                        val intent = Intent(Intent.ACTION_MAIN).apply {
                            addCategory(Intent.CATEGORY_HOME)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOLUME_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "maximizeVolume" -> {
                        result.success(maximizeVolume())
                    }

                    "restoreVolume" -> {
                        restoreVolume()
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun maximizeVolume(): Boolean {
        return try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            // Save current volume to restore later
            savedVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
            // Set to max volume
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            audioManager.setStreamVolume(
                AudioManager.STREAM_MUSIC,
                maxVolume,
                0
            )
            // Also maximize ring/alarm streams for good measure
            val maxAlarm = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxAlarm, 0)
            // Set ringer mode to normal (un-silence the phone)
            audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun restoreVolume() {
        try {
            if (savedVolume >= 0) {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                audioManager.setStreamVolume(
                    AudioManager.STREAM_MUSIC,
                    savedVolume,
                    0
                )
                savedVolume = -1
            }
        } catch (_: Exception) {
        }
    }

    private fun getDeviceStats(days: Int): Map<String, Any?> {
        val usageAccessGranted = hasUsageStatsPermission()
        return mapOf(
            "deviceName" to buildDeviceName(),
            "manufacturer" to Build.MANUFACTURER.orEmpty(),
            "model" to Build.MODEL.orEmpty(),
            "platform" to "android",
            "osVersion" to Build.VERSION.RELEASE.orEmpty(),
            "timezone" to TimeZone.getDefault().id,
            "usageAccessGranted" to usageAccessGranted,
            "days" to if (usageAccessGranted) collectUsageDays(days) else emptyList<Map<String, Any?>>(),
        )
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun collectUsageDays(days: Int): List<Map<String, Any?>> {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val results = mutableListOf<Map<String, Any?>>()
        val today = Calendar.getInstance()

        for (offset in 0 until days) {
            val dayStart = (today.clone() as Calendar).apply {
                add(Calendar.DAY_OF_YEAR, -offset)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val dayEnd = (dayStart.clone() as Calendar).apply {
                add(Calendar.DAY_OF_YEAR, 1)
            }
            val queryEnd = minOf(dayEnd.timeInMillis, System.currentTimeMillis())
            val apps = aggregateAppUsage(usageStatsManager, dayStart.timeInMillis, queryEnd)
            val totalMinutes = apps.sumOf {
                (it["usageMinutes"] as? Int) ?: 0
            }
            results.add(
                mapOf(
                    "date" to formatDate(dayStart.time),
                    "totalMinutes" to totalMinutes,
                    "apps" to apps,
                )
            )
        }

        return results.sortedBy { it["date"] as String }
    }

    private fun aggregateAppUsage(
        usageStatsManager: UsageStatsManager,
        beginTime: Long,
        endTime: Long,
    ): List<Map<String, Any?>> {
        val lastUsedByPackage = linkedMapOf<String, Long>()
        val usageByPackage = linkedMapOf<String, Long>()
        var currentPackage: String? = null
        var currentStart: Long? = null

        fun closeCurrent(atTime: Long) {
            val pkg = currentPackage ?: return
            val startedAt = currentStart ?: return
            val boundedEnd = atTime.coerceAtMost(endTime)
            if (boundedEnd > startedAt) {
                usageByPackage[pkg] = (usageByPackage[pkg] ?: 0L) + (boundedEnd - startedAt)
                lastUsedByPackage[pkg] = maxOf(lastUsedByPackage[pkg] ?: 0L, boundedEnd)
            }
            currentPackage = null
            currentStart = null
        }

        val events = usageStatsManager.queryEvents(beginTime, endTime)
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName ?: continue
            val eventTime = event.timeStamp.coerceIn(beginTime, endTime)
            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED,
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    if (!isTrackablePackage(pkg)) continue
                    if (currentPackage == pkg) continue
                    closeCurrent(eventTime)
                    currentPackage = pkg
                    currentStart = eventTime
                }

                UsageEvents.Event.ACTIVITY_PAUSED,
                UsageEvents.Event.ACTIVITY_STOPPED,
                UsageEvents.Event.MOVE_TO_BACKGROUND -> {
                    if (pkg == currentPackage) {
                        closeCurrent(eventTime)
                    }
                }
            }
        }

        closeCurrent(endTime)

        if (usageByPackage.isEmpty()) {
            return aggregateUsageFallback(usageStatsManager, beginTime, endTime)
        }

        return usageByPackage.entries
            .mapNotNull { (pkg, totalMs) ->
                val usageMinutes = TimeUnit.MILLISECONDS.toMinutes(totalMs).toInt()
                if (usageMinutes <= 0) return@mapNotNull null

                mapOf(
                    "packageName" to pkg,
                    "appName" to appLabelFor(pkg),
                    "usageMinutes" to usageMinutes,
                    "lastUsedAt" to lastUsedByPackage[pkg]?.let { formatDateTime(it) },
                )
            }
            .sortedByDescending { (it["usageMinutes"] as? Int) ?: 0 }
            .take(16)
    }

    private fun aggregateUsageFallback(
        usageStatsManager: UsageStatsManager,
        beginTime: Long,
        endTime: Long,
    ): List<Map<String, Any?>> {
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            beginTime,
            endTime,
        )
        val usageByPackage = linkedMapOf<String, Long>()
        val lastUsedByPackage = linkedMapOf<String, Long>()

        for (stat in stats) {
            val pkg = stat.packageName ?: continue
            if (!isTrackablePackage(pkg)) continue
            val totalMs = stat.totalTimeInForeground
            if (totalMs <= 0L) continue
            usageByPackage[pkg] = maxOf(usageByPackage[pkg] ?: 0L, totalMs)
            if (stat.lastTimeUsed > 0L) {
                lastUsedByPackage[pkg] = maxOf(lastUsedByPackage[pkg] ?: 0L, stat.lastTimeUsed)
            }
        }

        return usageByPackage.entries
            .mapNotNull { (pkg, totalMs) ->
                val usageMinutes = TimeUnit.MILLISECONDS.toMinutes(totalMs).toInt()
                if (usageMinutes <= 0) return@mapNotNull null

                mapOf(
                    "packageName" to pkg,
                    "appName" to appLabelFor(pkg),
                    "usageMinutes" to usageMinutes,
                    "lastUsedAt" to lastUsedByPackage[pkg]?.let { formatDateTime(it) },
                )
            }
            .sortedByDescending { (it["usageMinutes"] as? Int) ?: 0 }
            .take(16)
    }

    private fun appLabelFor(packageName: String): String {
        return try {
            val info = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(info).toString()
        } catch (_: Exception) {
            packageName
        }
    }

    private fun buildDeviceName(): String {
        val manufacturer = Build.MANUFACTURER.orEmpty().trim()
        val model = Build.MODEL.orEmpty().trim()
        return when {
            manufacturer.isEmpty() -> model
            model.startsWith(manufacturer, ignoreCase = true) -> model
            else -> "$manufacturer $model"
        }
    }

    private fun formatDate(date: Date): String {
        return SimpleDateFormat("yyyy-MM-dd", Locale.US).format(date)
    }

    private fun formatDateTime(timestamp: Long): String {
        val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
        format.timeZone = TimeZone.getTimeZone("UTC")
        return format.format(Date(timestamp))
    }

    private fun getForegroundPackage(): String? {
        if (!hasUsageStatsPermission()) return null
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = usageStatsManager.queryEvents(now - 120_000, now)
        val event = UsageEvents.Event()
        var currentPackage: String? = null

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName ?: continue
            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED,
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    currentPackage = if (isTrackablePackage(pkg)) pkg else null
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

        if (currentPackage != null) return currentPackage

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            now - 60_000,
            now,
        )
        if (stats.isNullOrEmpty()) return null
        return stats
            .asSequence()
            .filter { isTrackablePackage(it.packageName ?: return@filter false) }
            .maxByOrNull { it.lastTimeUsed }
            ?.packageName
    }

    private fun isTrackablePackage(packageName: String): Boolean {
        if (packageName == this.packageName) return false
        if (homePackages.contains(packageName)) return false
        return packageManager.getLaunchIntentForPackage(packageName) != null
    }

    private fun resolveHomePackages(): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        return packageManager
            .queryIntentActivities(intent, 0)
            .mapNotNull { it.activityInfo?.packageName }
            .toSet()
    }
}
