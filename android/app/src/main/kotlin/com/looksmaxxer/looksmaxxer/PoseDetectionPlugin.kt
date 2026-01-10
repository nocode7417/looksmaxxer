package com.looksmaxxer.looksmaxxer

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Pose Detection Plugin for Flutter
 *
 * This is a stub implementation that provides the platform channel interface.
 * Actual pose detection is handled by the Flutter-side MockPoseDetectionService
 * until google_mlkit_pose_detection Flutter package is integrated.
 *
 * Features:
 * - Haptic feedback on rep completion
 * - Sensor data for movement validation
 * - Performance monitoring stubs
 */
class PoseDetectionPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler, SensorEventListener {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    private var eventSink: EventChannel.EventSink? = null
    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var gyroscope: Sensor? = null

    private var isInitialized = false
    private var hapticEnabled = true

    // Performance tracking
    private var frameCount = 0
    private var droppedFrames = 0
    private var lastFpsTime = System.currentTimeMillis()
    private var currentFps = 0.0
    private var lastLatency = 0.0

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, "com.looksmaxxer/pose_detection")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "com.looksmaxxer/pose_stream")
        eventChannel.setStreamHandler(this)

        // Initialize sensor manager for movement validation
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        gyroscope = sensorManager?.getDefaultSensor(Sensor.TYPE_GYROSCOPE)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        cleanup()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                initialize(result)
            }
            "stop" -> {
                cleanup()
                result.success(true)
            }
            "getPerformanceMetrics" -> {
                result.success(getPerformanceMetrics())
            }
            "setHapticFeedback" -> {
                hapticEnabled = call.argument<Boolean>("enabled") ?: true
                result.success(true)
            }
            "triggerHaptic" -> {
                val type = call.argument<String>("type") ?: "light"
                triggerHaptic(type)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun initialize(result: MethodChannel.Result) {
        try {
            // Start sensor listening for movement validation
            accelerometer?.let {
                sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
            }
            gyroscope?.let {
                sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
            }

            isInitialized = true

            // Note: Actual pose detection will be handled by Flutter-side mock
            // until google_mlkit_pose_detection package is integrated
            result.success(true)

        } catch (e: Exception) {
            result.error("INIT_ERROR", "Failed to initialize: ${e.message}", null)
        }
    }

    /**
     * Get performance metrics for monitoring
     */
    private fun getPerformanceMetrics(): Map<String, Any> {
        // Estimate memory usage
        val runtime = Runtime.getRuntime()
        val usedMemory = (runtime.totalMemory() - runtime.freeMemory()) / (1024 * 1024)

        return mapOf(
            "fps" to currentFps,
            "latencyMs" to lastLatency,
            "batteryDrainPercent" to 2.0,
            "memoryUsageMb" to usedMemory,
            "droppedFrames" to droppedFrames
        )
    }

    /**
     * Trigger haptic feedback for rep completion
     */
    private fun triggerHaptic(type: String) {
        if (!hapticEnabled) return

        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val effect = when (type) {
                "light" -> VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE)
                "medium" -> VibrationEffect.createOneShot(100, VibrationEffect.DEFAULT_AMPLITUDE)
                "heavy" -> VibrationEffect.createOneShot(200, VibrationEffect.DEFAULT_AMPLITUDE)
                "success" -> VibrationEffect.createWaveform(longArrayOf(0, 50, 50, 100), -1)
                "warning" -> VibrationEffect.createWaveform(longArrayOf(0, 100, 50, 100), -1)
                "error" -> VibrationEffect.createWaveform(longArrayOf(0, 150, 50, 150, 50, 150), -1)
                else -> VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE)
            }
            vibrator.vibrate(effect)
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(100)
        }
    }

    /**
     * Sensor event handling for movement validation
     */
    override fun onSensorChanged(event: SensorEvent?) {
        // Used for movement validation - detecting sudden movements
        event?.let {
            when (it.sensor.type) {
                Sensor.TYPE_ACCELEROMETER -> {
                    // Can be used to validate movement speed
                }
                Sensor.TYPE_GYROSCOPE -> {
                    // Can be used to validate rotation/orientation
                }
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not needed for our use case
    }

    // EventChannel StreamHandler methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    /**
     * Clean up resources
     */
    private fun cleanup() {
        isInitialized = false
        sensorManager?.unregisterListener(this)
        eventSink = null
    }
}
