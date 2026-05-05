package com.example.kid_security

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import org.json.JSONObject

class MainActivity : FlutterActivity() {
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        maybeLaunchNativeSos(intent)
    }

    private fun maybeLaunchNativeSos(intent: Intent?) {
        val launchIntent = intent ?: return
        if (launchIntent.action == handledAction) return

        val payload = launchIntent.getStringExtra(payloadExtra) ?: return
        val json = runCatching { JSONObject(payload) }.getOrNull() ?: return
        if (json.optString("notification_type") != "sos") return

        launchIntent.removeExtra(payloadExtra)
        launchIntent.action = handledAction
        clearPendingSosPayload()

        startActivity(
            SosAlertActivity.createIntent(
                context = this,
                childName = json.optString("child_name", "Child"),
                message = json.optString("body", ""),
            ),
        )
    }

    private fun clearPendingSosPayload() {
        getSharedPreferences(flutterPrefs, Context.MODE_PRIVATE)
            .edit()
            .remove(pendingSosPayloadKey)
            .apply()
    }
}
