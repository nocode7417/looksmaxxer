import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:camera/camera.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout_model.dart';
import '../../../providers/workout_provider.dart';
import '../../../services/pose_detection_service.dart';
import 'workout_complete_screen.dart';

class WorkoutActiveScreen extends ConsumerStatefulWidget {
  final WorkoutType workoutType;
  final FitnessLevel level;
  final CameraDescription camera;

  const WorkoutActiveScreen({
    super.key,
    required this.workoutType,
    required this.level,
    required this.camera,
  });

  @override
  ConsumerState<WorkoutActiveScreen> createState() =>
      _WorkoutActiveScreenState();
}

class _WorkoutActiveScreenState extends ConsumerState<WorkoutActiveScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startWorkout();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _startWorkout() async {
    await ref.read(activeWorkoutProvider.notifier).startWorkout(
          workoutType: widget.workoutType,
          level: widget.level,
          camera: widget.camera,
        );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    ref.read(activeWorkoutProvider.notifier).endWorkout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(activeWorkoutProvider);

    // Check if workout completed
    if (workoutState.isWorkoutComplete && !workoutState.isResting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutCompleteScreen(
                session: workoutState.session!,
              ),
            ),
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            if (_isCameraInitialized && _cameraController != null)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              )
            else
              const Center(child: CircularProgressIndicator()),

            // Dark overlay for better UI visibility
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),

            // Top Controls
            Positioned(
              top: AppSpacing.lg,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: _TopControls(workoutState: workoutState),
            ),

            // Center - Rep Counter or Rest Timer
            if (workoutState.isResting)
              _RestOverlay(restTime: workoutState.restTimeRemaining)
            else
              _RepCounter(
                currentRep: workoutState.currentRep,
                targetRep: workoutState.config?.targetReps ?? 0,
                formAccuracy: workoutState.currentFormAccuracy,
              ),

            // Bottom - Form Feedback
            Positioned(
              bottom: AppSpacing.lg,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: _FormFeedback(
                feedback: workoutState.realtimeFeedback,
                formAccuracy: workoutState.currentFormAccuracy,
              ),
            ),

            // Performance indicator (dev mode)
            if (workoutState.performanceMetrics != null)
              Positioned(
                bottom: AppSpacing.xl * 4,
                right: AppSpacing.sm,
                child: _PerformanceIndicator(
                  metrics: workoutState.performanceMetrics!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopControls extends ConsumerWidget {
  final ActiveWorkoutState workoutState;

  const _TopControls({required this.workoutState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = workoutState.config;
    if (config == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        children: [
          // Workout name and set counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                config.type.displayName,
                style: AppTypography.title.copyWith(color: Colors.white),
              ),
              Text(
                'Set ${workoutState.currentSet} / ${config.targetSets}',
                style: AppTypography.title.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            child: LinearProgressIndicator(
              value: workoutState.currentSet / config.targetSets,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Action buttons
          Row(
            children: [
              // Pause/Resume
              IconButton(
                onPressed: () {
                  if (workoutState.isPaused) {
                    ref
                        .read(activeWorkoutProvider.notifier)
                        .resume();
                  } else {
                    ref
                        .read(activeWorkoutProvider.notifier)
                        .pause();
                  }
                },
                icon: Icon(
                  workoutState.isPaused ? LucideIcons.play : LucideIcons.pause,
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.muted,
                ),
              ),
              const Spacer(),
              // End workout
              TextButton.icon(
                onPressed: () => _showEndWorkoutDialog(context, ref),
                icon: const Icon(LucideIcons.x, size: 16),
                label: const Text('End'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEndWorkoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('End Workout?'),
        content: const Text('Are you sure you want to end this workout early?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(activeWorkoutProvider.notifier).endWorkout();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext); // Close dialog
              }
              if (context.mounted) {
                Navigator.pop(context); // Close workout screen
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('End Workout'),
          ),
        ],
      ),
    );
  }
}

class _RepCounter extends StatelessWidget {
  final int currentRep;
  final int targetRep;
  final double formAccuracy;

  const _RepCounter({
    required this.currentRep,
    required this.targetRep,
    required this.formAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rep count
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withOpacity(0.95),
              border: Border.all(
                color: _getFormColor(),
                width: 4,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentRep',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  '/ $targetRep',
                  style: AppTypography.title.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Form quality indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: _getFormColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(
                color: _getFormColor(),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getFormIcon(), color: _getFormColor(), size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _getFormLabel(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: _getFormColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getFormColor() {
    final quality = FormQualityExtension.fromAccuracy(formAccuracy);
    switch (quality) {
      case FormQuality.excellent:
        return AppColors.success;
      case FormQuality.good:
        return AppColors.info;
      case FormQuality.fair:
        return AppColors.warning;
      case FormQuality.poor:
        return AppColors.error;
    }
  }

  IconData _getFormIcon() {
    final quality = FormQualityExtension.fromAccuracy(formAccuracy);
    switch (quality) {
      case FormQuality.excellent:
      case FormQuality.good:
        return LucideIcons.checkCircle2;
      case FormQuality.fair:
        return LucideIcons.alertCircle;
      case FormQuality.poor:
        return LucideIcons.xCircle;
    }
  }

  String _getFormLabel() {
    final quality = FormQualityExtension.fromAccuracy(formAccuracy);
    return '${quality.label} Form';
  }
}

class _RestOverlay extends StatelessWidget {
  final int restTime;

  const _RestOverlay({required this.restTime});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl * 2),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.coffee,
              size: 48,
              color: AppColors.info,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Rest',
              style: AppTypography.headline.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$restTime',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                height: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'seconds',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormFeedback extends StatelessWidget {
  final List<String> feedback;
  final double formAccuracy;

  const _FormFeedback({
    required this.feedback,
    required this.formAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    if (feedback.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _getFeedbackColor().withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: _getFeedbackColor(),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: feedback.map((text) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Icon(
                  _getFeedbackIcon(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getFeedbackColor() {
    if (formAccuracy >= 0.75) return AppColors.success;
    if (formAccuracy >= 0.60) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getFeedbackIcon() {
    if (formAccuracy >= 0.75) return LucideIcons.checkCircle2;
    if (formAccuracy >= 0.60) return LucideIcons.alertTriangle;
    return LucideIcons.xCircle;
  }
}

class _PerformanceIndicator extends StatelessWidget {
  final PerformanceMetrics metrics;

  const _PerformanceIndicator({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: metrics.meetsRequirements
            ? AppColors.success.withOpacity(0.9)
            : AppColors.warning.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${metrics.fps.toStringAsFixed(0)} FPS',
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${metrics.latencyMs.toStringAsFixed(0)}ms',
            style: AppTypography.caption.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
