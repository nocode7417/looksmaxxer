import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/capture/alignment_guide.dart';
import '../../widgets/capture/quality_indicator.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final VoidCallback onCapture;
  final VoidCallback onCancel;

  const CameraScreen({
    super.key,
    required this.onCapture,
    required this.onCancel,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cameraProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    ref.read(cameraProvider.notifier).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final capturedImage = cameraState.capturedImage;

    if (capturedImage != null) {
      return _buildPreviewScreen(cameraState);
    }

    return _buildCameraScreen(cameraState);
  }

  Widget _buildCameraScreen(CameraState cameraState) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(
                      LucideIcons.x,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Capture Photo',
                      style: AppTypography.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(cameraProvider.notifier).toggleCamera();
                    },
                    icon: const Icon(
                      LucideIcons.switchCamera,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Camera preview
            Expanded(
              child: cameraState.isInitialized && cameraState.controller != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: AppSpacing.borderRadiusLg,
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: CameraPreview(cameraState.controller!),
                          ),
                        ),
                        const AlignmentGuide(),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),

            // Error message
            if (cameraState.error != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  cameraState.error!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),

            // Capture button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: GestureDetector(
                onTap: cameraState.isCapturing
                    ? null
                    : () {
                        ref.read(cameraProvider.notifier).capturePhoto();
                      },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textPrimary,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: cameraState.isCapturing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.textPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textPrimary,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewScreen(CameraState cameraState) {
    final qualityScore = cameraState.qualityScore;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(cameraProvider.notifier).clearCapture();
                    },
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Review Photo',
                      style: AppTypography.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Preview image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ClipRRect(
                  borderRadius: AppSpacing.borderRadiusLg,
                  child: Image.memory(
                    cameraState.capturedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Quality indicator
            if (qualityScore != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: QualityIndicator(qualityScore: qualityScore),
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Retake',
                      variant: AppButtonVariant.outline,
                      onPressed: () {
                        ref.read(cameraProvider.notifier).clearCapture();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Use Photo',
                      variant: AppButtonVariant.primary,
                      onPressed: qualityScore?.isAcceptable == true
                          ? widget.onCapture
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
