package com.example.kid_security.bridge

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Build
import android.os.Process
import android.util.Log
import java.io.OutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Native PCM capture + a SINGLE long-lived streaming POST upload.
 *
 * Why one long POST and not many short ones:
 *   - The reverse-proxy (nginx) on this deployment is already configured
 *     with `proxy_request_buffering off`, so a long-lived POST forwards
 *     each flushed HTTP-chunk to the WSGI worker in real time.
 *   - One TCP connection means there's no per-batch handshake cost. With
 *     a 250 ms batched POST design, every batch had to wait its turn for
 *     the connection to finish the previous request — that's exactly
 *     the kind of variability a real-time audio pipeline can't tolerate.
 *
 * The capture side keeps a small ring buffer in front of the upload thread
 * so that a brief network stall doesn't immediately back up `AudioRecord`
 * (which would drop samples natively at the OS level).
 */
class AroundAudioRecorder(private val applicationContext: Context) {

    companion object {
        private const val TAG = "AroundAudioRecorder"
        private const val SAMPLE_RATE = 16000
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
        private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
        // 100 ms per AudioRecord read (3200 bytes at 16 kHz s16le mono).
        // Smaller reads = lower latency on the wire, more flushes per
        // second; bigger reads = more efficient but more end-to-end lag.
        private const val CAPTURE_BUFFER_BYTES = 3200
        // Maximum size of the capture-thread → upload-thread ring buffer.
        // 32 KB ≈ 1 s. If the network can't drain that, we'd rather drop
        // old audio than block the AudioRecord callback (which would let
        // the OS-level mic queue overflow and produce far worse glitches).
        private const val PIPE_MAX_BYTES = 32 * 1024
    }

    private val running = AtomicBoolean(false)
    private var captureThread: Thread? = null
    private var uploadThread: Thread? = null
    private var audioRecord: AudioRecord? = null
    private var connection: HttpURLConnection? = null
    private var outputStream: OutputStream? = null

    private var activeSessionToken: String? = null

    @Synchronized
    fun isRunning(): Boolean = running.get()

    @Synchronized
    fun start(
        sessionToken: String,
        baseUrl: String,
        authHeaderValue: String?,
    ) {
        if (sessionToken.isEmpty()) {
            throw IllegalArgumentException("sessionToken is required")
        }
        if (baseUrl.isEmpty()) {
            throw IllegalArgumentException("baseUrl is required")
        }
        if (running.get() && activeSessionToken == sessionToken) {
            return
        }
        stopInternal()

        if (!hasMicrophonePermission()) {
            throw SecurityException("RECORD_AUDIO permission not granted")
        }

        val minBufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            CHANNEL_CONFIG,
            AUDIO_FORMAT,
        )
        if (minBufferSize <= 0) {
            throw IllegalStateException(
                "AudioRecord.getMinBufferSize returned $minBufferSize",
            )
        }
        val recordBufferSize = minBufferSize.coerceAtLeast(CAPTURE_BUFFER_BYTES * 4)

        val record = try {
            AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE,
                CHANNEL_CONFIG,
                AUDIO_FORMAT,
                recordBufferSize,
            )
        } catch (e: Exception) {
            throw IllegalStateException("Failed to instantiate AudioRecord: ${e.message}", e)
        }

        if (record.state != AudioRecord.STATE_INITIALIZED) {
            try {
                record.release()
            } catch (_: Exception) {
            }
            throw IllegalStateException("AudioRecord failed to initialize")
        }

        val pipe = ByteRing(maxBufferedBytes = PIPE_MAX_BYTES)
        val uploadUrl = buildUploadUrl(baseUrl, sessionToken)

        running.set(true)
        activeSessionToken = sessionToken
        audioRecord = record

        try {
            record.startRecording()
        } catch (e: Exception) {
            running.set(false)
            activeSessionToken = null
            try {
                record.release()
            } catch (_: Exception) {
            }
            audioRecord = null
            throw IllegalStateException("AudioRecord.startRecording failed", e)
        }

        Log.i(TAG, "around capture started, session=$sessionToken")

        val capture = Thread({
            Process.setThreadPriority(Process.THREAD_PRIORITY_AUDIO)
            val buffer = ByteArray(CAPTURE_BUFFER_BYTES)
            try {
                while (running.get()) {
                    val read = record.read(buffer, 0, buffer.size)
                    if (read > 0) {
                        pipe.write(buffer, read)
                    } else if (read < 0) {
                        Log.w(TAG, "AudioRecord.read returned $read; stopping capture")
                        break
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "Capture loop crashed: ${e.message}")
            } finally {
                pipe.close()
            }
        }, "around-audio-capture")
        capture.isDaemon = true

        val upload = Thread({
            // The upload loop reconnects automatically if the long POST
            // is dropped (NAT timeout, mobile handoff, server restart),
            // until the recorder is told to stop.
            while (running.get()) {
                try {
                    runUploadConnection(uploadUrl, authHeaderValue, pipe)
                } catch (e: Exception) {
                    Log.w(TAG, "Upload connection ended: ${e.message}; will reconnect")
                }
                if (!running.get()) break
                // Brief backoff so we don't hot-loop if the server is
                // refusing connections.
                try {
                    Thread.sleep(500)
                } catch (e: InterruptedException) {
                    Thread.currentThread().interrupt()
                    break
                }
            }
            if (running.compareAndSet(true, false)) {
                pipe.close()
            }
        }, "around-audio-upload")
        upload.isDaemon = true

        captureThread = capture
        uploadThread = upload
        capture.start()
        upload.start()
    }

    @Synchronized
    fun stop(expectedSessionToken: String? = null) {
        if (!running.get()) return
        if (!expectedSessionToken.isNullOrEmpty() &&
            activeSessionToken != expectedSessionToken
        ) {
            return
        }
        stopInternal()
    }

    private fun stopInternal() {
        running.set(false)
        activeSessionToken = null

        try {
            audioRecord?.stop()
        } catch (_: Exception) {
        }
        try {
            audioRecord?.release()
        } catch (_: Exception) {
        }
        audioRecord = null

        try {
            outputStream?.flush()
        } catch (_: Exception) {
        }
        try {
            outputStream?.close()
        } catch (_: Exception) {
        }
        outputStream = null

        try {
            connection?.disconnect()
        } catch (_: Exception) {
        }
        connection = null

        captureThread?.let { thread ->
            try {
                thread.join(750)
            } catch (_: InterruptedException) {
            }
        }
        captureThread = null

        uploadThread?.let { thread ->
            try {
                thread.join(1500)
            } catch (_: InterruptedException) {
            }
        }
        uploadThread = null
    }

    private fun hasMicrophonePermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return applicationContext.checkSelfPermission(
            Manifest.permission.RECORD_AUDIO,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun buildUploadUrl(baseUrl: String, sessionToken: String): URL {
        val cleanBase = baseUrl.trimEnd('/')
        val encodedToken = java.net.URLEncoder.encode(sessionToken, "UTF-8")
        return URL("$cleanBase/api/around-audio/live/upload/?session_token=$encodedToken")
    }

    /**
     * Open one long-lived chunked POST and pump the ring-buffer into it
     * until either the recorder is stopped or the connection drops.
     */
    private fun runUploadConnection(
        uploadUrl: URL,
        authHeaderValue: String?,
        pipe: ByteRing,
    ) {
        val conn = (uploadUrl.openConnection() as HttpURLConnection).apply {
            doOutput = true
            requestMethod = "POST"
            useCaches = false
            connectTimeout = 15_000
            readTimeout = 0 // long-lived; never read-timeout
            instanceFollowRedirects = false
            // Chunked transfer encoding so the server sees data as it
            // arrives (no Content-Length pre-buffer). 0 = use default
            // chunk size, which the JDK then honors per `flush()`.
            setChunkedStreamingMode(0)
            setRequestProperty("Connection", "keep-alive")
            setRequestProperty("Content-Type", "application/octet-stream")
            setRequestProperty("X-Audio-Sample-Rate", SAMPLE_RATE.toString())
            setRequestProperty("X-Audio-Channels", "1")
            setRequestProperty("X-Audio-Format", "pcm_s16le")
            if (!authHeaderValue.isNullOrEmpty()) {
                setRequestProperty("Authorization", authHeaderValue)
            }
        }
        connection = conn
        val out = conn.outputStream
        outputStream = out

        try {
            while (running.get()) {
                // Block up to 500 ms waiting for new audio. If nothing
                // shows up that quickly, the loop iterates and re-checks
                // `running`. We never write zero-length frames.
                val chunk = pipe.read(500) ?: continue
                out.write(chunk)
                // Force the chunk onto the wire immediately. Without this
                // the JDK can buffer several seconds of audio inside its
                // chunked-encoding writer before flushing the first byte.
                out.flush()
            }
        } finally {
            try {
                out.flush()
            } catch (_: Exception) {
            }
            try {
                out.close()
            } catch (_: Exception) {
            }
            try {
                val code = conn.responseCode
                if (code !in 200..299) {
                    Log.w(TAG, "Streaming upload finished with HTTP $code")
                }
            } catch (_: Exception) {
                // server already disconnected, ignore
            }
            try {
                conn.disconnect()
            } catch (_: Exception) {
            }
            if (connection === conn) {
                connection = null
                outputStream = null
            }
        }
    }

    /**
     * Bounded byte ring buffer. The capture thread writes; the upload
     * thread reads with a timeout so it can poll `running` between
     * AudioRecord callbacks even when the mic is silent.
     */
    private class ByteRing(private val maxBufferedBytes: Int) {
        private val lock = Object()
        private val queue = ArrayDeque<ByteArray>()
        private var bufferedBytes = 0
        private var closed = false

        fun write(source: ByteArray, length: Int) {
            if (length <= 0) return
            val copy = ByteArray(length)
            System.arraycopy(source, 0, copy, 0, length)
            synchronized(lock) {
                if (closed) return
                queue.addLast(copy)
                bufferedBytes += copy.size
                while (bufferedBytes > maxBufferedBytes && queue.isNotEmpty()) {
                    val dropped = queue.removeFirst()
                    bufferedBytes -= dropped.size
                }
                lock.notifyAll()
            }
        }

        fun read(timeoutMs: Long): ByteArray? {
            synchronized(lock) {
                if (queue.isEmpty()) {
                    if (closed) return null
                    try {
                        lock.wait(timeoutMs)
                    } catch (e: InterruptedException) {
                        Thread.currentThread().interrupt()
                        return null
                    }
                }
                if (queue.isEmpty()) return null
                val chunk = queue.removeFirst()
                bufferedBytes -= chunk.size
                return chunk
            }
        }

        fun close() {
            synchronized(lock) {
                closed = true
                lock.notifyAll()
            }
        }
    }
}
