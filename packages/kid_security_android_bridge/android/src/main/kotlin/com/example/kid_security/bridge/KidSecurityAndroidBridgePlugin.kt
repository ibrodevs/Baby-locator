package com.example.kid_security.bridge

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.TimeUnit

class KidSecurityAndroidBridgePlugin : FlutterPlugin {
    companion object {
        private const val DEVICE_STATS_CHANNEL = "kid_security/device_stats"
        private const val VOLUME_CHANNEL = "kid_security/volume"
        private var savedVolume: Int = -1
    }

    private lateinit var applicationContext: Context
    private lateinit var deviceStatsChannel: MethodChannel
    private lateinit var volumeChannel: MethodChannel
    private val homePackages by lazy { resolveHomePackages() }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        deviceStatsChannel = MethodChannel(
            binding.binaryMessenger,
            DEVICE_STATS_CHANNEL,
        )
        volumeChannel = MethodChannel(
            binding.binaryMessenger,
            VOLUME_CHANNEL,
        )

        deviceStatsChannel.setMethodCallHandler(::handleDeviceStatsMethod)
        volumeChannel.setMethodCallHandler(::handleVolumeMethod)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        deviceStatsChannel.setMethodCallHandler(null)
        volumeChannel.setMethodCallHandler(null)
    }

    private fun handleDeviceStatsMethod(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "getDeviceStats" -> {
                    val days = call.argument<Int>("days") ?: 35
                    result.success(getDeviceStats(days))
                }

                "openUsageAccessSettings" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    applicationContext.startActivity(intent)
                    result.success(true)
                }

                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }

                "openBatteryOptimizationSettings" -> {
                    openBatteryOptimizationSettings()
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
                    applicationContext.startActivity(intent)
                    result.success(true)
                }

                "isAccessibilityBlockingEnabled" -> {
                    result.success(BlockingAccessibilityService.isEnabled(applicationContext))
                }

                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    applicationContext.startActivity(intent)
                    result.success(true)
                }

                "setBlockedPackages" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    BlockingAccessibilityService.updatePackages(applicationContext, packages)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("bridge_error", error.message, null)
        }
    }

    private fun handleVolumeMethod(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "maximizeVolume" -> result.success(maximizeVolume())
                "restoreVolume" -> {
                    restoreVolume()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("bridge_error", error.message, null)
        }
    }

    private fun maximizeVolume(): Boolean {
        return try {
            val audioManager =
                applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            savedVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
            val maxMusicVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxMusicVolume, 0)

            val maxAlarmVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxAlarmVolume, 0)
            audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun restoreVolume() {
        try {
            if (savedVolume < 0) return
            val audioManager =
                applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, savedVolume, 0)
            savedVolume = -1
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
        val appOps =
            applicationContext.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            applicationContext.packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager =
            applicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(applicationContext.packageName)
    }

    private fun openBatteryOptimizationSettings() {
        val intent =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                !isIgnoringBatteryOptimizations()
            ) {
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = android.net.Uri.parse("package:${applicationContext.packageName}")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            } else {
                Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            }
        applicationContext.startActivity(intent)
    }

    private fun collectUsageDays(days: Int): List<Map<String, Any?>> {
        val usageStatsManager =
            applicationContext.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
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
            val appUsage = aggregateAppUsage(
                usageStatsManager = usageStatsManager,
                beginTime = dayStart.timeInMillis,
                endTime = queryEnd,
            )
            val totalMinutes = TimeUnit.MILLISECONDS.toMinutes(
                appUsage.values.sumOf { it.totalForegroundMs },
            ).toInt()

            results.add(
                mapOf(
                    "date" to formatDate(dayStart.time),
                    "totalMinutes" to totalMinutes,
                    "apps" to appUsage.values
                        .mapNotNull { stat ->
                            val usageMinutes = TimeUnit.MILLISECONDS.toMinutes(
                                stat.totalForegroundMs,
                            ).toInt()
                            if (usageMinutes <= 0) {
                                return@mapNotNull null
                            }

                            mapOf(
                                "packageName" to stat.packageName,
                                "appName" to stat.appName,
                                "usageMinutes" to usageMinutes,
                                "lastUsedAt" to stat.lastUsedAt?.let(::formatDateTime),
                            )
                        }
                        .sortedByDescending { (it["usageMinutes"] as? Int) ?: 0 },
                )
            )
        }

        return results.sortedBy { it["date"] as String }
    }

    private fun aggregateAppUsage(
        usageStatsManager: UsageStatsManager,
        beginTime: Long,
        endTime: Long,
    ): Map<String, AppUsageStat> {
        val statsByPackage = linkedMapOf<String, AppUsageStat>()
        var currentPackage: String? = null
        var currentStart: Long? = null

        fun appendUsage(packageName: String, startedAt: Long, endedAt: Long) {
            val boundedEnd = endedAt.coerceAtMost(endTime)
            if (boundedEnd <= startedAt) return

            val existing = statsByPackage[packageName]
            val updated = if (existing == null) {
                AppUsageStat(
                    packageName = packageName,
                    appName = appLabelFor(packageName),
                    totalForegroundMs = boundedEnd - startedAt,
                    lastUsedAt = boundedEnd,
                )
            } else {
                existing.copy(
                    totalForegroundMs = existing.totalForegroundMs + (boundedEnd - startedAt),
                    lastUsedAt = maxOf(existing.lastUsedAt ?: 0L, boundedEnd),
                )
            }

            statsByPackage[packageName] = updated
        }

        fun closeCurrent(atTime: Long) {
            val pkg = currentPackage ?: return
            val startedAt = currentStart ?: return
            appendUsage(pkg, startedAt, atTime)
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

        if (statsByPackage.isNotEmpty()) {
            return statsByPackage
        }

        return aggregateUsageFallback(
            usageStatsManager = usageStatsManager,
            beginTime = beginTime,
            endTime = endTime,
        )
    }

    private fun aggregateUsageFallback(
        usageStatsManager: UsageStatsManager,
        beginTime: Long,
        endTime: Long,
    ): Map<String, AppUsageStat> {
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            beginTime,
            endTime,
        )
        val usageByPackage = linkedMapOf<String, AppUsageStat>()

        for (stat in stats) {
            val pkg = stat.packageName ?: continue
            if (!isTrackablePackage(pkg)) continue
            val totalMs = stat.totalTimeInForeground
            if (totalMs <= 0L) continue

            val existing = usageByPackage[pkg]
            usageByPackage[pkg] = if (existing == null || totalMs > existing.totalForegroundMs) {
                AppUsageStat(
                    packageName = pkg,
                    appName = appLabelFor(pkg),
                    totalForegroundMs = totalMs,
                    lastUsedAt = stat.lastTimeUsed.takeIf { it > 0L },
                )
            } else {
                existing.copy(
                    lastUsedAt = maxOf(existing.lastUsedAt ?: 0L, stat.lastTimeUsed),
                )
            }
        }

        return usageByPackage
    }

    private fun getForegroundPackage(): String? {
        if (!hasUsageStatsPermission()) return null

        val usageStatsManager =
            applicationContext.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
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

        if (currentPackage != null) {
            return currentPackage
        }

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            now - 15_000,
            now,
        )
        if (stats.isNullOrEmpty()) return null

        return stats.asSequence()
            .filter { stat ->
                val pkg = stat.packageName ?: return@filter false
                isTrackablePackage(pkg) && stat.lastTimeUsed >= now - 15_000
            }
            .maxByOrNull { it.lastTimeUsed }
            ?.packageName
    }

    private fun appLabelFor(packageName: String): String {
        return try {
            val info = applicationContext.packageManager.getApplicationInfo(packageName, 0)
            applicationContext.packageManager.getApplicationLabel(info).toString()
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

    private fun isTrackablePackage(packageName: String): Boolean {
        if (packageName == applicationContext.packageName) return false
        if (homePackages.contains(packageName)) return false
        return applicationContext.packageManager.getLaunchIntentForPackage(packageName) != null
    }

    private fun resolveHomePackages(): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        return applicationContext.packageManager
            .queryIntentActivities(intent, 0)
            .mapNotNull { it.activityInfo?.packageName }
            .toSet()
    }

    private data class AppUsageStat(
        val packageName: String,
        val appName: String,
        val totalForegroundMs: Long,
        val lastUsedAt: Long?,
    )
}
