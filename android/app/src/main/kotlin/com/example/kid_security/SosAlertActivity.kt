package com.example.kid_security

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.Gravity
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import androidx.activity.ComponentActivity

class SosAlertActivity : ComponentActivity() {
    companion object {
        private const val extraChildName = "child_name"
        private const val extraMessage = "message"

        fun createIntent(
            context: Context,
            childName: String,
            message: String,
        ): Intent {
            return Intent(context, SosAlertActivity::class.java)
                .putExtra(extraChildName, childName)
                .putExtra(extraMessage, message)
                .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var toneGenerator: ToneGenerator? = null
    private var vibrator: Vibrator? = null
    private var sirenStep = 0

    private lateinit var childNameView: TextView
    private lateinit var messageView: TextView

    private val sirenRunnable = object : Runnable {
        override fun run() {
            val tone = if (sirenStep % 2 == 0) {
                ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD
            } else {
                ToneGenerator.TONE_CDMA_EMERGENCY_RINGBACK
            }
            sirenStep += 1
            toneGenerator?.startTone(tone, 700)
            handler.postDelayed(this, 750)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        prepareWindow()
        buildUi()
        updateContent(intent)
        disableBackButton()
    }

    override fun onStart() {
        super.onStart()
        startAlerting()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        updateContent(intent)
        startAlerting()
    }

    override fun onStop() {
        stopAlerting()
        super.onStop()
    }

    override fun onDestroy() {
        stopAlerting()
        super.onDestroy()
    }

    private fun prepareWindow() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val keyguardManager = getSystemService(KeyguardManager::class.java)
            keyguardManager?.requestDismissKeyguard(this, null)
        }
        setFinishOnTouchOutside(false)
    }

    private fun buildUi() {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setBackgroundColor(Color.parseColor("#B91C1C"))
            setPadding(48, 96, 48, 64)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )
        }

        val sosView = TextView(this).apply {
            text = "SOS!"
            gravity = Gravity.CENTER
            textSize = 34f
            setTextColor(Color.WHITE)
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        }

        childNameView = TextView(this).apply {
            gravity = Gravity.CENTER
            textSize = 24f
            setTextColor(Color.WHITE)
            setPadding(0, 32, 0, 20)
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        }

        messageView = TextView(this).apply {
            gravity = Gravity.CENTER
            textSize = 18f
            setTextColor(Color.WHITE)
            setPadding(0, 0, 0, 48)
        }

        val acknowledgeButton = Button(this).apply {
            text = "Open app"
            textSize = 18f
            setBackgroundColor(Color.WHITE)
            setTextColor(Color.parseColor("#B91C1C"))
            setPadding(24, 18, 24, 18)
            setOnClickListener {
                stopAlerting()
                finish()
            }
        }

        val spacerTop = LinearLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                1f,
            )
        }
        val spacerBottom = LinearLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                1f,
            )
        }

        root.addView(spacerTop)
        root.addView(sosView)
        root.addView(childNameView)
        root.addView(messageView)
        root.addView(acknowledgeButton)
        root.addView(spacerBottom)

        setContentView(root)
    }

    private fun updateContent(intent: Intent?) {
        val childName = intent?.getStringExtra(extraChildName)?.ifBlank { "Child" } ?: "Child"
        val message = intent?.getStringExtra(extraMessage)?.ifBlank { "needs help right now!" }
            ?: "needs help right now!"
        childNameView.text = childName
        messageView.text = message
    }

    private fun startAlerting() {
        if (toneGenerator == null) {
            toneGenerator = ToneGenerator(AudioManager.STREAM_ALARM, 100)
        }
        handler.removeCallbacks(sirenRunnable)
        sirenStep = 0
        handler.post(sirenRunnable)
        startVibration()
    }

    private fun stopAlerting() {
        handler.removeCallbacks(sirenRunnable)
        toneGenerator?.stopTone()
        toneGenerator?.release()
        toneGenerator = null
        stopVibration()
    }

    private fun startVibration() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = getSystemService(VibratorManager::class.java)
            vibrator = manager?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val effect = VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 700), 0)
            vibrator?.vibrate(effect)
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(longArrayOf(0, 500, 200, 700), 0)
        }
    }

    private fun stopVibration() {
        vibrator?.cancel()
    }

    private fun disableBackButton() {
        onBackPressedDispatcher.addCallback(
            this,
            object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    // Keep the emergency screen visible until the parent
                    // acknowledges it explicitly.
                }
            },
        )
    }
}
