package com.example.kid_security.bridge

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.util.Log
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Real-time PCM playback for the parent's "Around" feature.
 *
 * Audio comes off the network in bursts (the child uploads 250 ms
 * batches; cellular jitter often delays a batch by another 100-300 ms).
 * AudioTrack drains at exactly the configured sample rate, so any gap
 * between bursts that exceeds the buffer size produces an audible
 * underrun (a click / dropout).
 *
 * Two safeguards make playback smooth:
 *   1. The track buffer is sized to ~1.5 seconds of audio so we can
 *      absorb network jitter without underrunning.
 *   2. Playback is held in PAUSED state at start until ~500 ms of audio
 *      has been queued. This warmup gives the track a cushion before it
 *      starts consuming, so the very first network gap doesn't already
 *      drain the buffer to empty.
 */
class LiveAudioPlayer {

    companion object {
        private const val TAG = "LiveAudioPlayer"
        // 3 s of audio. Mobile networks can stall for 1-2 s during a
        // cell handoff or congestion spike; we'd rather pay 3 s of
        // latency once than have the audio click/drop every minute. The
        // user has explicitly said "smooth uninterrupted is more
        // important than live", which is what this value buys.
        private const val TRACK_BUFFER_SECONDS = 3.0
        // Warmup we accumulate before flipping the track to PLAYING.
        // 1 s of pre-buffer means the first network stall has 1 s of
        // headroom before it reaches the playback head, on top of the
        // ongoing buffer fill from later batches.
        private const val WARMUP_SECONDS = 1.0
    }

    private var sampleRate: Int = 16000
    private var channels: Int = 1
    private var audioTrack: AudioTrack? = null
    private var writerExecutor: ExecutorService? = null

    @Volatile private var bytesPerSecond: Int = 32000
    @Volatile private var warmupRequiredBytes: Int = 16000
    @Volatile private var bytesQueued: Long = 0
    @Volatile private var playingStarted: Boolean = false

    fun initialize(sampleRate: Int, channels: Int) {
        this.sampleRate = sampleRate
        this.channels = channels
        // s16le → 2 bytes per sample.
        bytesPerSecond = sampleRate * channels * 2
        warmupRequiredBytes = (bytesPerSecond * WARMUP_SECONDS).toInt()
        recreateTrack()
    }

    fun start() {
        val track = audioTrack ?: return
        if (writerExecutor == null || writerExecutor?.isShutdown == true) {
            writerExecutor = Executors.newSingleThreadExecutor()
        }
        // Do NOT call track.play() yet — we hold playback until the
        // warmup buffer is accumulated. Otherwise the track starts with
        // ~0 ms of cushion, the first jittery batch underruns, and the
        // user hears a glitch/silence inside the first second.
        bytesQueued = 0
        playingStarted = false
    }

    fun appendPcm(bytes: ByteArray) {
        val track = audioTrack ?: return
        val executor = writerExecutor ?: return
        if (bytes.isEmpty()) return
        executor.execute {
            try {
                track.write(bytes, 0, bytes.size, AudioTrack.WRITE_BLOCKING)
                bytesQueued += bytes.size
                if (!playingStarted && bytesQueued >= warmupRequiredBytes) {
                    try {
                        track.play()
                        playingStarted = true
                    } catch (e: Exception) {
                        Log.w(TAG, "AudioTrack.play() failed: ${e.message}")
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "AudioTrack.write failed: ${e.message}")
            }
        }
    }

    fun stop() {
        writerExecutor?.shutdownNow()
        writerExecutor = null
        bytesQueued = 0
        playingStarted = false
        try {
            audioTrack?.pause()
        } catch (_: Exception) {
        }
        try {
            audioTrack?.flush()
        } catch (_: Exception) {
        }
    }

    fun release() {
        stop()
        try {
            audioTrack?.release()
        } catch (_: Exception) {
        }
        audioTrack = null
    }

    private fun recreateTrack() {
        release()

        val channelConfig = if (channels > 1) {
            AudioFormat.CHANNEL_OUT_STEREO
        } else {
            AudioFormat.CHANNEL_OUT_MONO
        }
        val minBufferSize = AudioTrack.getMinBufferSize(
            sampleRate,
            channelConfig,
            AudioFormat.ENCODING_PCM_16BIT,
        )
        // Size for our jitter target, but never go below the system min.
        val targetBufferBytes = (bytesPerSecond * TRACK_BUFFER_SECONDS).toInt()
        val bufferSize = targetBufferBytes.coerceAtLeast(minBufferSize)

        audioTrack = AudioTrack(
            AudioAttributes.Builder()
                // Use MEDIA / MUSIC so the parent's media volume controls
                // the listening volume, and so the track plays through
                // the speaker by default at full quality.
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build(),
            AudioFormat.Builder()
                .setSampleRate(sampleRate)
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setChannelMask(channelConfig)
                .build(),
            bufferSize,
            AudioTrack.MODE_STREAM,
            AudioManager.AUDIO_SESSION_ID_GENERATE,
        )
        Log.i(
            TAG,
            "AudioTrack initialized: sampleRate=$sampleRate channels=$channels " +
                "bufferBytes=$bufferSize warmupBytes=$warmupRequiredBytes",
        )
    }
}
