import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/workout_model.dart';
import '../../../providers/workout_provider.dart';

class WorkoutCompleteScreen extends ConsumerWidget {
  final WorkoutSession session;

  const WorkoutCompleteScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Success icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.success,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  LucideIcons.checkCircle2,
                  size: 64,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                'Workout Complete!',
                style: AppTypography.display.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                session.config.type.displayName,
                style: AppTypography.headline.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Stats Cards
              _StatCard(
                icon: LucideIcons.repeat,
                label: 'Total Reps',
                value: '${session.totalReps}',
                color: AppColors.accent,
              ),

              const SizedBox(height: AppSpacing.md),

              _StatCard(
                icon: LucideIcons.layers,
                label: 'Sets Completed',
                value: '${session.totalSets} / ${session.config.targetSets}',
                color: AppColors.info,
              ),

              const SizedBox(height: AppSpacing.md),

              _StatCard(
                icon: LucideIcons.award,
                label: 'Form Quality',
                value: session.overallQuality.label,
                subtitle: '${(session.averageFormAccuracy * 100).toStringAsFixed(0)}% accuracy',
                color: _getQualityColor(session.overallQuality),
              ),

              const SizedBox(height: AppSpacing.md),

              _StatCard(
                icon: LucideIcons.clock,
                label: 'Duration',
                value: _formatDuration(session.durationSeconds),
                color: AppColors.muted,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Personal Record check
              if (_isPersonalRecord(ref))
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    border: Border.all(
                      color: AppColors.success,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.trophy,
                        color: AppColors.success,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Record!',
                              style: AppTypography.title.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'You beat your previous best!',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.xl),

              // Set Breakdown
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Breakdown',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...session.sets.map((set) => _SetRow(set: set)),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Save session to program
                    await ref
                        .read(workoutProgramProvider.notifier)
                        .saveSession(session);

                    if (context.mounted) {
                      // Return to dashboard
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    backgroundColor: AppColors.success,
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              OutlinedButton(
                onPressed: () {
                  // Return to workout selection for another workout
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('Start Another Workout'),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPersonalRecord(WidgetRef ref) {
    final program = ref.read(workoutProgramProvider).program;
    if (program == null) return false;

    final currentPR = program.personalRecords[session.workoutType];
    if (currentPR == null) return true;

    return session.totalReps > currentPR.totalReps;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  Color _getQualityColor(FormQuality quality) {
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.headline.copyWith(
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final SetData set;

  const _SetRow({required this.set});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          // Set number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getQualityColor().withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${set.setNumber}',
                style: AppTypography.bodyMedium.copyWith(
                  color: _getQualityColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Reps
          Expanded(
            child: Text(
              '${set.validReps} / ${set.targetReps} reps',
              style: AppTypography.body,
            ),
          ),
          // Form quality
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getQualityColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              set.overallQuality.label,
              style: AppTypography.caption.copyWith(
                color: _getQualityColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor() {
    switch (set.overallQuality) {
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
}
