import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:camera/camera.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout_model.dart';
import '../../../providers/workout_provider.dart';
import 'workout_active_screen.dart';

class WorkoutSelectionScreen extends ConsumerStatefulWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  ConsumerState<WorkoutSelectionScreen> createState() =>
      _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState
    extends ConsumerState<WorkoutSelectionScreen> {
  WorkoutType? _selectedWorkout;
  FitnessLevel _selectedLevel = FitnessLevel.beginner;

  @override
  Widget build(BuildContext context) {
    final programState = ref.watch(workoutProgramProvider);

    if (programState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Workout'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose Your Workout',
              style: AppTypography.display,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Select a workout and difficulty level to begin',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Workout Cards
            _WorkoutCard(
              workoutType: WorkoutType.chinTucks,
              isSelected: _selectedWorkout == WorkoutType.chinTucks,
              onTap: () => setState(() => _selectedWorkout = WorkoutType.chinTucks),
              isPriority: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _WorkoutCard(
              workoutType: WorkoutType.pushUps,
              isSelected: _selectedWorkout == WorkoutType.pushUps,
              onTap: () => setState(() => _selectedWorkout = WorkoutType.pushUps),
            ),
            const SizedBox(height: AppSpacing.md),
            _WorkoutCard(
              workoutType: WorkoutType.facePulls,
              isSelected: _selectedWorkout == WorkoutType.facePulls,
              onTap: () => setState(() => _selectedWorkout = WorkoutType.facePulls),
            ),
            const SizedBox(height: AppSpacing.md),
            _WorkoutCard(
              workoutType: WorkoutType.neckCurls,
              isSelected: _selectedWorkout == WorkoutType.neckCurls,
              onTap: () => setState(() => _selectedWorkout = WorkoutType.neckCurls),
            ),

            if (_selectedWorkout != null) ...[
              const SizedBox(height: AppSpacing.xl),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.xl),

              // Level Selection
              Text(
                'Select Difficulty',
                style: AppTypography.headline,
              ),
              const SizedBox(height: AppSpacing.md),
              _LevelSelector(
                selectedLevel: _selectedLevel,
                onLevelChanged: (level) => setState(() => _selectedLevel = level),
                workoutType: _selectedWorkout!,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startWorkout(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    backgroundColor: AppColors.success,
                  ),
                  child: const Text(
                    'Start Workout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _startWorkout() async {
    if (_selectedWorkout == null) return;

    // Get available cameras
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera available')),
        );
      }
      return;
    }

    // Use front camera
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutActiveScreen(
            workoutType: _selectedWorkout!,
            level: _selectedLevel,
            camera: camera,
          ),
        ),
      );
    }
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutType workoutType;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isPriority;

  const _WorkoutCard({
    required this.workoutType,
    required this.isSelected,
    required this.onTap,
    this.isPriority = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _getIconColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            workoutType.displayName,
                            style: AppTypography.title,
                          ),
                          if (isPriority) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppSpacing.xs),
                              ),
                              child: Text(
                                'PRIORITY',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        workoutType.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    LucideIcons.checkCircle2,
                    color: AppColors.success,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Looksmaxxing benefit
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.sparkles,
                    color: AppColors.accent,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      workoutType.looksmaxxingBenefit,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
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

  IconData _getIcon() {
    switch (workoutType) {
      case WorkoutType.chinTucks:
        return LucideIcons.moveVertical;
      case WorkoutType.pushUps:
        return LucideIcons.arrowUpDown;
      case WorkoutType.facePulls:
        return LucideIcons.arrowLeftRight;
      case WorkoutType.neckCurls:
        return LucideIcons.arrowDown;
    }
  }

  Color _getIconColor() {
    if (isPriority) return AppColors.success;
    return AppColors.info;
  }
}

class _LevelSelector extends StatelessWidget {
  final FitnessLevel selectedLevel;
  final Function(FitnessLevel) onLevelChanged;
  final WorkoutType workoutType;

  const _LevelSelector({
    required this.selectedLevel,
    required this.onLevelChanged,
    required this.workoutType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LevelOption(
          level: FitnessLevel.beginner,
          isSelected: selectedLevel == FitnessLevel.beginner,
          onTap: () => onLevelChanged(FitnessLevel.beginner),
          workoutType: workoutType,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LevelOption(
          level: FitnessLevel.intermediate,
          isSelected: selectedLevel == FitnessLevel.intermediate,
          onTap: () => onLevelChanged(FitnessLevel.intermediate),
          workoutType: workoutType,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LevelOption(
          level: FitnessLevel.advanced,
          isSelected: selectedLevel == FitnessLevel.advanced,
          onTap: () => onLevelChanged(FitnessLevel.advanced),
          workoutType: workoutType,
        ),
      ],
    );
  }
}

class _LevelOption extends StatelessWidget {
  final FitnessLevel level;
  final bool isSelected;
  final VoidCallback onTap;
  final WorkoutType workoutType;

  const _LevelOption({
    required this.level,
    required this.isSelected,
    required this.onTap,
    required this.workoutType,
  });

  @override
  Widget build(BuildContext context) {
    final config = WorkoutConfig.getConfig(workoutType, level);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.accent
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        LucideIcons.check,
                        size: 12,
                        color: AppColors.background,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.label,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${config.targetReps} reps × ${config.targetSets} sets${config.holdDurationSeconds > 0 ? ' (${config.holdDurationSeconds}s holds)' : ''}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
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
