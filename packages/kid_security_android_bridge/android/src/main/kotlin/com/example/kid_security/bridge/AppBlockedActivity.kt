package com.example.kid_security.bridge

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class AppBlockedActivity : Activity() {
    private lateinit var titleView: TextView
    private lateinit var subtitleView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(buildContent())
        render()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (::titleView.isInitialized && ::subtitleView.isInitialized) {
            render()
        }
    }

    @Deprecated("Uses Activity.onBackPressed for cross-version compatibility.")
    @Suppress("DEPRECATION")
    override fun onBackPressed() {
        navigateHome()
    }

    private fun render() {
        val appName = intent.getStringExtra(EXTRA_APP_NAME)
            ?.takeIf { it.isNotBlank() }
            ?: getString(R.string.blocking_screen_default_app_name)
        titleView.text = getString(R.string.blocking_screen_title, appName)
        subtitleView.text = getString(R.string.blocking_screen_subtitle)
    }

    private fun buildContent(): View {
        val density = resources.displayMetrics.density
        val outerPadding = (24 * density).toInt()
        val innerPadding = (20 * density).toInt()
        val cardCornerRadius = 28f * density

        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#F6F7FB"))
            setPadding(outerPadding, outerPadding, outerPadding, outerPadding)

            addView(
                LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    setPadding(innerPadding, innerPadding, innerPadding, innerPadding)
                    background = GradientDrawable().apply {
                        shape = GradientDrawable.RECTANGLE
                        cornerRadius = cardCornerRadius
                        colors = intArrayOf(
                            Color.parseColor("#18243D"),
                            Color.parseColor("#2B3B5E"),
                        )
                        orientation = GradientDrawable.Orientation.TOP_BOTTOM
                    }

                    addView(
                        TextView(context).apply {
                            text = "BLOCKED"
                            gravity = Gravity.CENTER
                            setTypeface(typeface, Typeface.BOLD)
                            textSize = 20f
                            setTextColor(Color.WHITE)
                        },
                    )

                    addView(spacer(heightDp = 14))

                    titleView = TextView(context).apply {
                        gravity = Gravity.CENTER
                        setTextColor(Color.WHITE)
                        setTypeface(typeface, Typeface.BOLD)
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f)
                    }
                    addView(titleView)

                    addView(spacer(heightDp = 10))

                    subtitleView = TextView(context).apply {
                        gravity = Gravity.CENTER
                        setTextColor(Color.parseColor("#DCE6FF"))
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                    }
                    addView(subtitleView)

                    addView(spacer(heightDp = 18))

                    addView(
                        TextView(context).apply {
                            text = getString(R.string.blocking_screen_hint)
                            gravity = Gravity.CENTER
                            setTextColor(Color.parseColor("#B7C4E5"))
                            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                        },
                    )

                    addView(spacer(heightDp = 22))

                    addView(
                        Button(context).apply {
                            text = getString(R.string.blocking_screen_home_button)
                            isAllCaps = false
                            setOnClickListener { navigateHome() }
                        },
                    )

                    addView(spacer(heightDp = 10))

                    addView(
                        Button(context).apply {
                            text = getString(R.string.blocking_screen_open_app_button)
                            isAllCaps = false
                            setOnClickListener { openKidSecurity() }
                        },
                    )
                },
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ),
            )
        }
    }

    private fun spacer(heightDp: Int): View {
        return View(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                (heightDp * resources.displayMetrics.density).toInt(),
            )
        }
    }

    private fun navigateHome() {
        startActivity(
            Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
        finish()
    }

    private fun openKidSecurity() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
        if (launchIntent != null) {
            startActivity(launchIntent)
        } else {
            navigateHome()
        }
        finish()
    }

    companion object {
        private const val EXTRA_BLOCKED_PACKAGE = "blocked_package"
        private const val EXTRA_APP_NAME = "app_name"

        fun launch(
            context: Context,
            blockedPackage: String,
            appName: String,
        ) {
            val intent = Intent(context, AppBlockedActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS or
                        Intent.FLAG_ACTIVITY_NO_HISTORY,
                )
                putExtra(EXTRA_BLOCKED_PACKAGE, blockedPackage)
                putExtra(EXTRA_APP_NAME, appName)
            }
            context.startActivity(intent)
        }
    }
}
