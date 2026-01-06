import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../data/models/photo_model.dart';
import '../engine/quality_validator.dart';

/// Camera state
class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final bool isFrontCamera;
  final bool isCapturing;
  final String? error;
  final Uint8List? capturedImage;
  final QualityScore? qualityScore;

  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.isFrontCamera = true,
    this.isCapturing = false,
    this.error,
    this.capturedImage,
    this.qualityScore,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    bool? isFrontCamera,
    bool? isCapturing,
    String? error,
    Uint8List? capturedImage,
    QualityScore? qualityScore,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isCapturing: isCapturing ?? this.isCapturing,
      error: error,
      capturedImage: capturedImage,
      qualityScore: qualityScore,
    );
  }
}

/// Camera notifier
class CameraNotifier extends StateNotifier<CameraState> {
  List<CameraDescription>? _cameras;

  CameraNotifier() : super(const CameraState());

  /// Initialize camera
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        state = state.copyWith(error: 'No cameras available');
        return;
      }

      await _initializeController(state.isFrontCamera);
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize camera: $e');
    }
  }

  Future<void> _initializeController(bool useFrontCamera) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    // Find the appropriate camera
    CameraDescription? selectedCamera;
    for (final camera in _cameras!) {
      if (useFrontCamera && camera.lensDirection == CameraLensDirection.front) {
        selectedCamera = camera;
        break;
      } else if (!useFrontCamera &&
          camera.lensDirection == CameraLensDirection.back) {
        selectedCamera = camera;
        break;
      }
    }

    selectedCamera ??= _cameras!.first;

    // Dispose existing controller
    await state.controller?.dispose();

    // Create new controller
    final controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        isFrontCamera: useFrontCamera,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize camera: $e');
    }
  }

  /// Toggle between front and back camera
  Future<void> toggleCamera() async {
    await _initializeController(!state.isFrontCamera);
  }

  /// Capture photo
  Future<void> capturePhoto() async {
    if (state.controller == null || !state.isInitialized) return;
    if (state.isCapturing) return;

    state = state.copyWith(isCapturing: true);

    try {
      final image = await state.controller!.takePicture();
      final imageBytes = await image.readAsBytes();

      // Analyze quality
      final qualityScore = await QualityValidator.analyzeQuality(imageBytes);

      state = state.copyWith(
        isCapturing: false,
        capturedImage: imageBytes,
        qualityScore: qualityScore,
      );
    } catch (e) {
      state = state.copyWith(
        isCapturing: false,
        error: 'Failed to capture photo: $e',
      );
    }
  }

  /// Clear captured image
  void clearCapture() {
    state = state.copyWith(
      capturedImage: null,
      qualityScore: null,
    );
  }

  /// Dispose camera
  Future<void> dispose() async {
    await state.controller?.dispose();
    state = const CameraState();
  }

  /// Get photo metadata
  PhotoMetadata? getPhotoMetadata() {
    if (state.controller == null) return null;

    final size = state.controller!.value.previewSize;
    return PhotoMetadata(
      width: size?.width.toInt() ?? 0,
      height: size?.height.toInt() ?? 0,
      facingMode: state.isFrontCamera ? 'user' : 'environment',
    );
  }
}

/// Provider
final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier();
});

/// Derived providers
final isCameraInitializedProvider = Provider<bool>((ref) {
  return ref.watch(cameraProvider).isInitialized;
});

final capturedImageProvider = Provider<Uint8List?>((ref) {
  return ref.watch(cameraProvider).capturedImage;
});

final qualityScoreProvider = Provider<QualityScore?>((ref) {
  return ref.watch(cameraProvider).qualityScore;
});
