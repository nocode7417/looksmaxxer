import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../providers/workout_provider.dart';
import '../../workouts/workout_selection_screen.dart';

class WorkoutsTab extends ConsumerWidget {
  const WorkoutsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(workoutProgramProvider);

    if (programState.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                  'Looksmaxxing Workouts',
                  style: AppTypography.display,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Motion-tracked exercises for facial aesthetics',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick Stats
        if (programState.program != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _QuickStats(program: programState.program!),
            ),
          ),

        // Quick Start Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Start',
                  style: AppTypography.headline,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Jump into a workout with AI-powered form tracking',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Workout Cards Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildListDelegate([
              _QuickWorkoutCard(
                workoutType: WorkoutType.chinTucks,
                isPriority: true,
                onTap: () => _navigateToWorkout(context),
              ),
              _QuickWorkoutCard(
                workoutType: WorkoutType.pushUps,
                onTap: () => _navigateToWorkout(context),
              ),
              _QuickWorkoutCard(
                workoutType: WorkoutType.facePulls,
                onTap: () => _navigateToWorkout(context),
              ),
              _QuickWorkoutCard(
                workoutType: WorkoutType.neckCurls,
                onTap: () => _navigateToWorkout(context),
              ),
            ]),
          ),
        ),

        // Start Full Workout Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToWorkout(context),
                icon: const Icon(LucideIcons.play),
                label: const Text('Start Workout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  backgroundColor: AppColors.success,
                ),
              ),
            ),
          ),
        ),

        // Recent Activity Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'This Week',
              style: AppTypography.headline,
            ),
          ),
        ),

        // Weekly Calendar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _WeeklyCalendar(program: programState.program),
          ),
        ),

        // Personal Records
        if (programState.program != null &&
            programState.program!.personalRecords.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Records',
                    style: AppTypography.headline,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PersonalRecords(records: programState.program!.personalRecords),
                ],
              ),
            ),
          ),

        // Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xl * 2),
        ),
      ],
    );
  }

  void _navigateToWorkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutSelectionScreen(),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final WorkoutProgram program;

  const _QuickStats({required this.program});

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
          Expanded(
            child: _StatColumn(
              icon: LucideIcons.flame,
              label: 'Streak',
              value: '${_getMaxStreak()} days',
              color: AppColors.warning,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppColors.border,
          ),
          Expanded(
            child: _StatColumn(
              icon: LucideIcons.repeat,
              label: 'This Week',
              value: '${program.getWeeklyVolume()} reps',
              color: AppColors.info,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppColors.border,
          ),
          Expanded(
            child: _StatColumn(
              icon: LucideIcons.trendingUp,
              label: 'Consistency',
              value: '${program.getConsistencyRate().toStringAsFixed(0)}%',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  int _getMaxStreak() {
    if (program.workoutStreaks.isEmpty) return 0;
    return program.workoutStreaks.values.reduce((a, b) => a > b ? a : b);
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _QuickWorkoutCard extends StatelessWidget {
  final WorkoutType workoutType;
  final bool isPriority;
  final VoidCallback onTap;

  const _QuickWorkoutCard({
    required this.workoutType,
    this.isPriority = false,
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
            color: isPriority ? AppColors.success : AppColors.border,
            width: isPriority ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and priority badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _getColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getColor(),
                    size: 24,
                  ),
                ),
                const Spacer(),
                if (isPriority)
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
                      '#1',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // Name
            Text(
              workoutType.displayName,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Short benefit
            Text(
              _getShortBenefit(),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

  Color _getColor() {
    if (isPriority) return AppColors.success;
    return AppColors.accent;
  }

  String _getShortBenefit() {
    switch (workoutType) {
      case WorkoutType.chinTucks:
        return 'Jawline definition';
      case WorkoutType.pushUps:
        return 'Overall posture';
      case WorkoutType.facePulls:
        return 'Shoulder alignment';
      case WorkoutType.neckCurls:
        return 'Neck thickness';
    }
  }
}

class _WeeklyCalendar extends StatelessWidget {
  final WorkoutProgram? program;

  const _WeeklyCalendar({this.program});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekSessions = program?.getThisWeekSessions() ?? [];

    // Get workout days
    final workoutDays = thisWeekSessions
        .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final day = weekStart.add(Duration(days: index));
          final isToday = day.day == now.day &&
              day.month == now.month &&
              day.year == now.year;
          final hasWorkout = workoutDays.contains(
            DateTime(day.year, day.month, day.day),
          );

          return _DayCircle(
            dayName: _getDayName(index),
            isToday: isToday,
            hasWorkout: hasWorkout,
          );
        }),
      ),
    );
  }

  String _getDayName(int index) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[index];
  }
}

class _DayCircle extends StatelessWidget {
  final String dayName;
  final bool isToday;
  final bool hasWorkout;

  const _DayCircle({
    required this.dayName,
    required this.isToday,
    required this.hasWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dayName,
          style: AppTypography.caption.copyWith(
            color: isToday ? AppColors.accent : AppColors.textTertiary,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasWorkout
                ? AppColors.success
                : (isToday
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.background),
            border: Border.all(
              color: isToday ? AppColors.accent : AppColors.border,
              width: isToday ? 2 : 1,
            ),
          ),
          child: hasWorkout
              ? const Center(
                  child: Icon(
                    LucideIcons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _PersonalRecords extends StatelessWidget {
  final Map<WorkoutType, WorkoutSession> records;

  const _PersonalRecords({required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: records.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.trophy,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  entry.key.displayName,
                  style: AppTypography.body,
                ),
              ),
              Text(
                '${entry.value.totalReps} reps',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
