import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/orthotropic_exercise_model.dart';
import '../../../../providers/providers.dart';

class ExercisesTab extends ConsumerWidget {
  const ExercisesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(exerciseProgramProvider);
    final activeExercises = ref.watch(activeExercisesProvider);
    final todayCompletion = ref.watch(todayCompletionProvider);
    final adherenceStats = ref.watch(adherenceStatsProvider);

    if (programState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (programState.error != null) {
      return Center(
        child: Text(
          'Error: ${programState.error}',
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orthotropic Exercises',
                  style: AppTypography.display,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Evidence-based exercises for facial development',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Adherence Stats Card
        if (programState.program != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _AdherenceCard(stats: adherenceStats),
            ),
          ),

        // Active Exercises Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Your Active Exercises',
              style: AppTypography.title,
            ),
          ),
        ),

        // Active Exercises List
        if (activeExercises.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _EmptyState(
                onAddExercises: () => _showExerciseLibrary(context, ref),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = activeExercises[index];
                final isCompletedToday = todayCompletion[exercise.id] ?? false;
                return Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.md,
                  ),
                  child: _ExerciseCard(
                    exercise: exercise,
                    isCompletedToday: isCompletedToday,
                    onTap: () => _showExerciseDetail(context, ref, exercise),
                  ),
                );
              },
              childCount: activeExercises.length,
            ),
          ),

        // Add Exercise Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: OutlinedButton.icon(
              onPressed: () => _showExerciseLibrary(context, ref),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add More Exercises'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ),
        ),

        // Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xl),
        ),
      ],
    );
  }

  void _showExerciseLibrary(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => _ExerciseLibrarySheet(),
    );
  }

  void _showExerciseDetail(
    BuildContext context,
    WidgetRef ref,
    OrthotropicExercise exercise,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _AdherenceCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final adherenceRate = stats['overallRate'] as double;
    final totalSessions = stats['totalSessions'] as int;
    final completedSessions = stats['completedSessions'] as int;
    final longestStreak = stats['longestStreak'] as int;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.trendingUp,
                size: 20,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Last 30 Days',
                style: AppTypography.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Adherence',
                  value: '${adherenceRate.toStringAsFixed(0)}%',
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Completed',
                  value: '$completedSessions/$totalSessions',
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Streak',
                  value: '$longestStreak days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.title.copyWith(
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final OrthotropicExercise exercise;
  final bool isCompletedToday;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.isCompletedToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(
            color: isCompletedToday ? AppColors.success : AppColors.border,
            width: isCompletedToday ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Evidence Badge
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _getEvidenceColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Icon(
                _getExerciseIcon(),
                color: _getEvidenceColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Exercise Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    exercise.evidenceLevel.label,
                    style: AppTypography.caption.copyWith(
                      color: _getEvidenceColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${exercise.recommendedSetsPerDay}x per day • ${exercise.durationSeconds ~/ 60} min',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Completion Status
            if (isCompletedToday)
              const Icon(
                LucideIcons.checkCircle2,
                color: AppColors.success,
                size: 24,
              )
            else
              Icon(
                LucideIcons.circle,
                color: AppColors.textTertiary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Color _getEvidenceColor() {
    switch (exercise.evidenceLevel) {
      case OrthotropicEvidenceLevel.strong:
        return AppColors.success;
      case OrthotropicEvidenceLevel.moderate:
        return AppColors.info;
      case OrthotropicEvidenceLevel.emerging:
        return AppColors.warning;
      case OrthotropicEvidenceLevel.anecdotal:
        return AppColors.error;
    }
  }

  IconData _getExerciseIcon() {
    switch (exercise.type) {
      case ExerciseType.tonguePosture:
        return LucideIcons.smile;
      case ExerciseType.breathing:
        return LucideIcons.wind;
      case ExerciseType.chewing:
        return LucideIcons.apple;
      case ExerciseType.swallowing:
        return LucideIcons.droplet;
      case ExerciseType.facePulling:
        return LucideIcons.alertTriangle;
      case ExerciseType.jawExpansion:
        return LucideIcons.expand;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddExercises;

  const _EmptyState({required this.onAddExercises});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.dumbbell,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No exercises yet',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add evidence-based exercises to your routine',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: onAddExercises,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Browse Exercises'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseLibrarySheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableExercises = ref
        .read(exerciseProgramProvider.notifier)
        .getAvailableExercises();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.lg),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      'Exercise Library',
                      style: AppTypography.headline,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Exercise List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: availableExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = availableExercises[index];
                    return _LibraryExerciseCard(
                      exercise: exercise,
                      onAdd: () {
                        ref
                            .read(exerciseProgramProvider.notifier)
                            .addExercise(exercise.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LibraryExerciseCard extends StatelessWidget {
  final OrthotropicExercise exercise;
  final VoidCallback onAdd;

  const _LibraryExerciseCard({
    required this.exercise,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getEvidenceColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                      ),
                      child: Text(
                        exercise.evidenceLevel.label,
                        style: AppTypography.caption.copyWith(
                          color: _getEvidenceColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plus),
                onPressed: onAdd,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            exercise.description,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (exercise.warningMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertTriangle,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      exercise.warningMessage!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getEvidenceColor() {
    switch (exercise.evidenceLevel) {
      case OrthotropicEvidenceLevel.strong:
        return AppColors.success;
      case OrthotropicEvidenceLevel.moderate:
        return AppColors.info;
      case OrthotropicEvidenceLevel.emerging:
        return AppColors.warning;
      case OrthotropicEvidenceLevel.anecdotal:
        return AppColors.error;
    }
  }
}

class _ExerciseDetailScreen extends ConsumerStatefulWidget {
  final OrthotropicExercise exercise;

  const _ExerciseDetailScreen({required this.exercise});

  @override
  ConsumerState<_ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<_ExerciseDetailScreen> {
  bool _isSessionActive = false;
  int _completedReps = 0;

  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(exerciseProgramProvider).activeSession;
    final isThisExerciseActive =
        activeSession?.exerciseId == widget.exercise.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Evidence Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _getEvidenceColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                widget.exercise.evidenceLevel.label,
                style: AppTypography.bodyMedium.copyWith(
                  color: _getEvidenceColor(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Description
            Text(
              widget.exercise.description,
              style: AppTypography.body,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Warning
            if (widget.exercise.warningMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.alertTriangle,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.exercise.warningMessage!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Instructions
            Text(
              'Instructions',
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            ...widget.exercise.instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppSpacing.lg),

            // Expected Benefits
            Text(
              'Expected Benefits',
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            ...widget.exercise.expectedBenefits.map((benefit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.checkCircle2,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        benefit,
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            // Start Exercise Button
            if (!isThisExerciseActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(exerciseProgramProvider.notifier)
                        .startSession(widget.exercise.id);
                    setState(() => _isSessionActive = true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  child: const Text('Start Exercise'),
                ),
              )
            else ...[
              // Session Controls
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(color: AppColors.accent),
                ),
                child: Column(
                  children: [
                    Text(
                      'Reps: $_completedReps / ${widget.exercise.recommendedReps}',
                      style: AppTypography.headline,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(exerciseProgramProvider.notifier)
                                  .cancelSession();
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(exerciseProgramProvider.notifier)
                                  .completeSession();
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Complete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEvidenceColor() {
    switch (widget.exercise.evidenceLevel) {
      case OrthotropicEvidenceLevel.strong:
        return AppColors.success;
      case OrthotropicEvidenceLevel.moderate:
        return AppColors.info;
      case OrthotropicEvidenceLevel.emerging:
        return AppColors.warning;
      case OrthotropicEvidenceLevel.anecdotal:
        return AppColors.error;
    }
  }
}
