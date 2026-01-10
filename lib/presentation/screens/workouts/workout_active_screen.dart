import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout_model.dart';
import '../../../providers/workout_provider.dart';
import '../../../services/pose_detection_service.dart';
import 'workout_complete_screen.dart';

/// Active workout screen with camera preview and real-time feedback
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

class _WorkoutActiveScreenState extends ConsumerState<WorkoutActiveScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;

  // Camera state
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  String? _cameraErrorMessage;

  // Workout state
  bool _isWorkoutStarted = false;
  bool _hasNavigatedToComplete = false;

  // User guidance
  bool _showPositioningGuide = true;
  int _countdownSeconds = 3;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWorkout();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle for camera
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Pause workout when app goes to background
      ref.read(activeWorkoutProvider.notifier).pause();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize camera when app resumes
      _reinitializeCamera();
    }
  }

  Future<void> _initializeWorkout() async {
    // Check camera permission first
    final hasPermission = await _checkCameraPermission();
    if (!hasPermission) {
      setState(() {
        _isCameraError = true;
        _cameraErrorMessage = 'Camera permission denied. Please enable camera access in settings.';
      });
      return;
    }

    // Initialize camera
    await _initializeCamera();

    // Start workout if camera initialized successfully
    if (_isCameraInitialized && mounted) {
      await _startWorkout();
    }
  }

  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    return false;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(
        widget.camera,
        ResolutionPreset.high, // Use high for better pose detection
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      // Lock to portrait orientation for consistent pose detection
      await _cameraController!.lockCaptureOrientation();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isCameraError = false;
          _cameraErrorMessage = null;
        });
      }
    } on CameraException catch (e) {
      _handleCameraError(e);
    } catch (e) {
      setState(() {
        _isCameraError = true;
        _cameraErrorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _reinitializeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    setState(() {
      _isCameraInitialized = false;
    });

    await _initializeCamera();

    // Resume workout if it was paused
    if (_isCameraInitialized && _isWorkoutStarted) {
      ref.read(activeWorkoutProvider.notifier).resume();
    }
  }

  void _handleCameraError(CameraException e) {
    String message;
    switch (e.code) {
      case 'CameraAccessDenied':
        message = 'Camera access denied. Please enable camera permission.';
        break;
      case 'CameraAccessDeniedWithoutPrompt':
        message = 'Camera permission was denied. Enable it in Settings.';
        break;
      case 'CameraAccessRestricted':
        message = 'Camera access is restricted on this device.';
        break;
      case 'AudioAccessDenied':
        message = 'Audio access denied (not required for workout).';
        break;
      default:
        message = 'Camera error: ${e.description}';
    }

    setState(() {
      _isCameraError = true;
      _cameraErrorMessage = message;
    });
  }

  Future<void> _startWorkout() async {
    if (_isWorkoutStarted) return;

    try {
      await ref.read(activeWorkoutProvider.notifier).startWorkout(
        workoutType: widget.workoutType,
        level: widget.level,
        camera: widget.camera,
      );

      setState(() {
        _isWorkoutStarted = true;
      });

      // Start countdown before first rep
      _startCountdown();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start workout: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdownSeconds = 3;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        setState(() {
          _isCountingDown = false;
          _showPositioningGuide = false;
        });
        return false;
      }
      return true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  void _navigateToComplete(WorkoutSession session) {
    if (_hasNavigatedToComplete) return;
    _hasNavigatedToComplete = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutCompleteScreen(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(activeWorkoutProvider);

    // Check if workout completed - navigate safely
    if (workoutState.isWorkoutComplete &&
        !workoutState.isResting &&
        workoutState.session != null &&
        !_hasNavigatedToComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateToComplete(workoutState.session!);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview or Error State
            _buildCameraLayer(),

            // Dark overlay for better UI visibility
            if (_isCameraInitialized)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),

            // Positioning Guide Overlay
            if (_showPositioningGuide && _isCameraInitialized)
              _PositioningGuide(workoutType: widget.workoutType),

            // Countdown Overlay
            if (_isCountingDown)
              _CountdownOverlay(seconds: _countdownSeconds),

            // Top Controls
            if (!_isCountingDown)
              Positioned(
                top: AppSpacing.lg,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: _TopControls(
                  workoutState: workoutState,
                  onDismissGuide: () => setState(() => _showPositioningGuide = false),
                ),
              ),

            // Center - Rep Counter or Rest Timer
            if (!_isCountingDown && !_showPositioningGuide) ...[
              if (workoutState.isResting)
                _RestOverlay(restTime: workoutState.restTimeRemaining)
              else
                _RepCounter(
                  currentRep: workoutState.currentRep,
                  targetRep: workoutState.config?.targetReps ?? 0,
                  formAccuracy: workoutState.currentFormAccuracy,
                ),
            ],

            // Bottom - Form Feedback & Exercise Tips
            if (!_isCountingDown)
              Positioned(
                bottom: AppSpacing.lg,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Exercise-specific tip
                    if (_showPositioningGuide)
                      _ExerciseTip(workoutType: widget.workoutType),

                    if (!_showPositioningGuide) ...[
                      // Form feedback
                      _FormFeedback(
                        feedback: workoutState.realtimeFeedback,
                        formAccuracy: workoutState.currentFormAccuracy,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),

            // Performance indicator (debug)
            if (workoutState.performanceMetrics != null && !_showPositioningGuide)
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

  Widget _buildCameraLayer() {
    if (_isCameraError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.cameraOff,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Camera Error',
                style: AppTypography.headline.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _cameraErrorMessage ?? 'Unknown camera error',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: _initializeWorkout,
                icon: const Icon(LucideIcons.refreshCw),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Initializing camera...',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Positioned.fill(
      child: CameraPreview(_cameraController!),
    );
  }
}

/// Positioning guide overlay showing user how to position themselves
class _PositioningGuide extends StatelessWidget {
  final WorkoutType workoutType;

  const _PositioningGuide({required this.workoutType});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Silhouette guide
              Container(
                width: 200,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.accent,
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                ),
                child: CustomPaint(
                  painter: _SilhouettePainter(workoutType: workoutType),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Position yourself in the frame',
                style: AppTypography.headline.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _getPositioningInstruction(),
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPositioningInstruction() {
    switch (workoutType) {
      case WorkoutType.chinTucks:
        return 'Face the camera\nKeep your head and shoulders visible';
      case WorkoutType.pushUps:
        return 'Position camera to see your side profile\nShow full body from head to feet';
      case WorkoutType.facePulls:
        return 'Face the camera\nKeep arms and shoulders visible';
      case WorkoutType.neckCurls:
        return 'Face the camera\nKeep head and neck visible';
    }
  }
}

/// Simple silhouette painter for positioning guide
class _SilhouettePainter extends CustomPainter {
  final WorkoutType workoutType;

  _SilhouettePainter({required this.workoutType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw simple human silhouette
    final centerX = size.width / 2;

    // Head
    canvas.drawCircle(Offset(centerX, size.height * 0.12), 25, paint);
    canvas.drawCircle(Offset(centerX, size.height * 0.12), 25, strokePaint);

    // Body
    final bodyPath = Path();
    bodyPath.moveTo(centerX - 30, size.height * 0.25);
    bodyPath.lineTo(centerX + 30, size.height * 0.25);
    bodyPath.lineTo(centerX + 25, size.height * 0.55);
    bodyPath.lineTo(centerX - 25, size.height * 0.55);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, strokePaint);

    // Arms
    canvas.drawLine(
      Offset(centerX - 30, size.height * 0.28),
      Offset(centerX - 50, size.height * 0.45),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + 30, size.height * 0.28),
      Offset(centerX + 50, size.height * 0.45),
      strokePaint,
    );

    // Legs
    canvas.drawLine(
      Offset(centerX - 15, size.height * 0.55),
      Offset(centerX - 20, size.height * 0.85),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + 15, size.height * 0.55),
      Offset(centerX + 20, size.height * 0.85),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Countdown overlay before workout starts
class _CountdownOverlay extends StatelessWidget {
  final int seconds;

  const _CountdownOverlay({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get Ready!',
                style: AppTypography.display.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$seconds',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Exercise-specific tips
class _ExerciseTip extends StatelessWidget {
  final WorkoutType workoutType;

  const _ExerciseTip({required this.workoutType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.lightbulb, color: Colors.white, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _getTip(),
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getTip() {
    switch (workoutType) {
      case WorkoutType.chinTucks:
        return 'Pull your chin back like making a double chin. Hold for the specified time.';
      case WorkoutType.pushUps:
        return 'Keep your body in a straight line. Go down until elbows are at 90 degrees.';
      case WorkoutType.facePulls:
        return 'Pull hands toward your face, squeezing shoulder blades together.';
      case WorkoutType.neckCurls:
        return 'Move slowly and controlled. Stop if you feel any pain.';
    }
  }
}

class _TopControls extends ConsumerWidget {
  final ActiveWorkoutState workoutState;
  final VoidCallback onDismissGuide;

  const _TopControls({
    required this.workoutState,
    required this.onDismissGuide,
  });

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
              Expanded(
                child: Text(
                  config.type.displayName,
                  style: AppTypography.title.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Text(
                  'Set ${workoutState.currentSet}/${config.targetSets}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                    ref.read(activeWorkoutProvider.notifier).resume();
                  } else {
                    ref.read(activeWorkoutProvider.notifier).pause();
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
              Navigator.pop(dialogContext);
              await ref.read(activeWorkoutProvider.notifier).endWorkout();
              if (context.mounted) {
                Navigator.pop(context);
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
              boxShadow: [
                BoxShadow(
                  color: _getFormColor().withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
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
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Shake out your muscles',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
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
    if (feedback.isEmpty) {
      // Show default guidance when no specific feedback
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.scan, color: AppColors.accent, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Tracking your movement...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

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
