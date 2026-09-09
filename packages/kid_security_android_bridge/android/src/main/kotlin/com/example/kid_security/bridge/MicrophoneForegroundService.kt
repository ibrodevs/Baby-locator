package com.example.kid_security.bridge

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Dedicated foreground service for active Listen Around microphone capture sessions.
 *
 * Requirements:
 * - Shows persistent, transparent notification on child device during capture.
 * - Declares foregroundServiceType="microphone" for Android 14+ compliance.
 * - Stopped immediately when capture ends or times out.
 */
class MicrophoneForegroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        ensureNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopForegroundCompat()
            stopSelf()
            return START_NOT_STICKY
        }

        val notification = buildForegroundNotification()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE,
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (_: Throwable) {
            // Best-effort in background restrictions
        }

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java) ?: return
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Baby Locator — Microphone Activity",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Displays persistent notification when microphone is active for parental safety."
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(): Notification {
        val appIcon = applicationInfo.icon.takeIf { it != 0 } ?: android.R.drawable.ic_btn_speak_now
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Baby Locator")
            .setContentText("Microphone is active. Live audio is being shared with your linked parent.")
            .setSmallIcon(appIcon)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    private fun stopForegroundCompat() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    companion object {
        const val CHANNEL_ID = "baby_locator_microphone_service"
        const val NOTIFICATION_ID = 8901
        const val ACTION_START = "com.example.kid_security.bridge.START_MIC_SERVICE"
        const val ACTION_STOP = "com.example.kid_security.bridge.STOP_MIC_SERVICE"

        fun start(context: Context) {
            val intent = Intent(context, MicrophoneForegroundService::class.java).apply {
                action = ACTION_START
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (_: Throwable) {
                // Background start restriction fallback
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, MicrophoneForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            try {
                context.startService(intent)
            } catch (_: Throwable) {
            }
        }
    }
}
