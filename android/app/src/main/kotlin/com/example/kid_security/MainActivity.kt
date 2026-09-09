package com.example.kid_security

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import org.json.JSONObject

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val payloadExtra = "payload"
        private const val handledAction = "kid_security.intent.SOS_HANDLED"
        private const val flutterPrefs = "FlutterSharedPreferences"
        private const val pendingSosPayloadKey = "flutter.pending_sos_payload"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        maybeLaunchNativeSos(intent)
    }

    override fun onResume() {
        super.onResume()
        maybeLaunchNativeSos(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        maybeLaunchNativeSos(intent)
    }

    private fun maybeLaunchNativeSos(intent: Intent?) {
        val launchIntent = intent
        if (launchIntent?.action == handledAction) return

        var payload = launchIntent?.getStringExtra(payloadExtra)
        if (payload.isNullOrEmpty()) {
            val prefs = getSharedPreferences(flutterPrefs, Context.MODE_PRIVATE)
            payload = prefs.getString(pendingSosPayloadKey, null)
        }
        if (payload.isNullOrEmpty()) return

        val json = runCatching { JSONObject(payload) }.getOrNull() ?: return
        if (json.optString("notification_type") != "sos") return

        launchIntent?.removeExtra(payloadExtra)
        launchIntent?.action = handledAction
        clearPendingSosPayload()

        val childName = json.optString("child_name", "Child")
        val message = json.optString("body", "")

        val sosIntent = SosAlertActivity.createIntent(
            context = this,
            childName = childName,
            message = message,
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(sosIntent)
    }

    private fun clearPendingSosPayload() {
        getSharedPreferences(flutterPrefs, Context.MODE_PRIVATE)
            .edit()
            .remove(pendingSosPayloadKey)
            .apply()
    }
}
