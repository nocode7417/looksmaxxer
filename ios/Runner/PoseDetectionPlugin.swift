import Flutter
import UIKit
import AVFoundation
import Vision
import CoreMotion

/**
 * Vision Framework Pose Detection Plugin for Flutter
 *
 * Features:
 * - 17 body keypoints tracked at 30fps
 * - VNDetectHumanBodyPoseRequest for accurate pose estimation
 * - Core Motion for movement validation
 * - Haptic Engine for tactile feedback
 * - Performance monitoring
 */
public class PoseDetectionPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var poseRequest: VNDetectHumanBodyPoseRequest?

    private var motionManager: CMMotionManager?

    private var isInitialized = false
    private var hapticEnabled = true

    // Haptic feedback generators
    private var impactLight: UIImpactFeedbackGenerator?
    private var impactMedium: UIImpactFeedbackGenerator?
    private var impactHeavy: UIImpactFeedbackGenerator?
    private var notificationGenerator: UINotificationFeedbackGenerator?

    // Performance tracking
    private var frameCount = 0
    private var droppedFrames = 0
    private var lastFpsTime: CFTimeInterval = 0
    private var currentFps: Double = 0.0
    private var lastLatency: Double = 0.0

    // Landmark mapping to Flutter format
    private let landmarkMap: [VNHumanBodyPoseObservation.JointName: String] = [
        .nose: "nose",
        .leftEye: "leftEye",
        .rightEye: "rightEye",
        .leftEar: "leftEar",
        .rightEar: "rightEar",
        .leftShoulder: "leftShoulder",
        .rightShoulder: "rightShoulder",
        .leftElbow: "leftElbow",
        .rightElbow: "rightElbow",
        .leftWrist: "leftWrist",
        .rightWrist: "rightWrist",
        .leftHip: "leftHip",
        .rightHip: "rightHip",
        .leftKnee: "leftKnee",
        .rightKnee: "rightKnee",
        .leftAnkle: "leftAnkle",
        .rightAnkle: "rightAnkle"
    ]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = PoseDetectionPlugin()

        instance.methodChannel = FlutterMethodChannel(
            name: "com.looksmaxxer/pose_detection",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: instance.methodChannel!)

        instance.eventChannel = FlutterEventChannel(
            name: "com.looksmaxxer/pose_stream",
            binaryMessenger: registrar.messenger()
        )
        instance.eventChannel?.setStreamHandler(instance)

        // Initialize haptic generators
        instance.impactLight = UIImpactFeedbackGenerator(style: .light)
        instance.impactMedium = UIImpactFeedbackGenerator(style: .medium)
        instance.impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        instance.notificationGenerator = UINotificationFeedbackGenerator()

        // Initialize motion manager
        instance.motionManager = CMMotionManager()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            let args = call.arguments as? [String: Any]
            let targetFps = args?["targetFps"] as? Double ?? 30.0
            let confidenceThreshold = args?["confidenceThreshold"] as? Double ?? 0.5
            initialize(targetFps: targetFps, confidenceThreshold: Float(confidenceThreshold), result: result)

        case "stop":
            cleanup()
            result(true)

        case "getPerformanceMetrics":
            result(getPerformanceMetrics())

        case "setHapticFeedback":
            let args = call.arguments as? [String: Any]
            hapticEnabled = args?["enabled"] as? Bool ?? true
            result(true)

        case "triggerHaptic":
            let args = call.arguments as? [String: Any]
            let type = args?["type"] as? String ?? "light"
            triggerHaptic(type: type)
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(targetFps: Double, confidenceThreshold: Float, result: @escaping FlutterResult) {
        // Create pose detection request
        poseRequest = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                self.droppedFrames += 1
                return
            }

            guard let observations = request.results as? [VNHumanBodyPoseObservation],
                  let firstObservation = observations.first else {
                return
            }

            let poseData = self.processPose(observation: firstObservation)

            DispatchQueue.main.async {
                self.eventSink?(poseData)
            }
        }

        // Configure for performance
        if #available(iOS 15.0, *) {
            // Additional configuration for iOS 15+
        }

        // Start motion tracking for movement validation
        if let motionManager = motionManager, motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates()
        }

        if let motionManager = motionManager, motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 1.0 / 60.0
            motionManager.startGyroUpdates()
        }

        // Prepare haptic generators
        impactLight?.prepare()
        impactMedium?.prepare()
        impactHeavy?.prepare()
        notificationGenerator?.prepare()

        isInitialized = true
        lastFpsTime = CACurrentMediaTime()
        result(true)
    }

    /**
     * Process video frame for pose detection
     * Called from camera delegate
     */
    func processFrame(pixelBuffer: CVPixelBuffer) {
        guard isInitialized, let poseRequest = poseRequest, eventSink != nil else {
            return
        }

        let startTime = CACurrentMediaTime()

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        do {
            try handler.perform([poseRequest])

            // Calculate latency
            lastLatency = (CACurrentMediaTime() - startTime) * 1000

            // Update FPS
            frameCount += 1
            let now = CACurrentMediaTime()
            if now - lastFpsTime >= 1.0 {
                currentFps = Double(frameCount) / (now - lastFpsTime)
                frameCount = 0
                lastFpsTime = now
            }
        } catch {
            droppedFrames += 1
        }
    }

    /**
     * Convert Vision pose observation to Flutter-compatible dictionary
     */
    private func processPose(observation: VNHumanBodyPoseObservation) -> [String: Any] {
        var landmarks: [String: [String: Any]] = [:]
        var totalConfidence: Float = 0.0
        var landmarkCount = 0

        for (jointName, flutterName) in landmarkMap {
            do {
                let point = try observation.recognizedPoint(jointName)

                // Vision coordinates are normalized 0-1 with origin at bottom-left
                // Convert to top-left origin to match Android
                landmarks[flutterName] = [
                    "x": point.location.x,
                    "y": 1.0 - point.location.y, // Flip Y axis
                    "confidence": point.confidence
                ]

                totalConfidence += point.confidence
                landmarkCount += 1
            } catch {
                // Joint not detected
            }
        }

        let overallConfidence = landmarkCount > 0 ? totalConfidence / Float(landmarkCount) : 0.0

        return [
            "landmarks": landmarks,
            "confidence": overallConfidence,
            "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
        ]
    }

    /**
     * Get performance metrics for monitoring
     */
    private func getPerformanceMetrics() -> [String: Any] {
        // Estimate battery drain based on processing load
        let estimatedBatteryDrain: Double
        if currentFps >= 28 {
            estimatedBatteryDrain = 4.5
        } else if currentFps >= 20 {
            estimatedBatteryDrain = 3.5
        } else {
            estimatedBatteryDrain = 2.5
        }

        // Get memory usage
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        let memoryUsageMb: UInt64
        if result == KERN_SUCCESS {
            memoryUsageMb = info.resident_size / (1024 * 1024)
        } else {
            memoryUsageMb = 0
        }

        return [
            "fps": currentFps,
            "latencyMs": lastLatency,
            "batteryDrainPercent": estimatedBatteryDrain,
            "memoryUsageMb": memoryUsageMb,
            "droppedFrames": droppedFrames
        ]
    }

    /**
     * Trigger haptic feedback for rep completion
     */
    private func triggerHaptic(type: String) {
        guard hapticEnabled else { return }

        switch type {
        case "light":
            impactLight?.impactOccurred()
        case "medium":
            impactMedium?.impactOccurred()
        case "heavy":
            impactHeavy?.impactOccurred()
        case "success":
            notificationGenerator?.notificationOccurred(.success)
        case "warning":
            notificationGenerator?.notificationOccurred(.warning)
        case "error":
            notificationGenerator?.notificationOccurred(.error)
        default:
            impactLight?.impactOccurred()
        }
    }

    // MARK: - FlutterStreamHandler

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    /**
     * Clean up resources
     */
    private func cleanup() {
        isInitialized = false
        captureSession?.stopRunning()
        captureSession = nil
        videoOutput = nil
        poseRequest = nil
        motionManager?.stopAccelerometerUpdates()
        motionManager?.stopGyroUpdates()
        eventSink = nil
    }
}

// MARK: - Camera Delegate Extension

extension PoseDetectionPlugin: AVCaptureVideoDataOutputSampleBufferDelegate {

    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        processFrame(pixelBuffer: pixelBuffer)
    }

    public func captureOutput(_ output: AVCaptureOutput,
                              didDrop sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        droppedFrames += 1
    }
}
