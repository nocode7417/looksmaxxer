import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/providers.dart';
import '../../../../providers/hydration_provider.dart';
import '../../../../providers/mewing_provider.dart';
import '../../../../providers/chewing_provider.dart';
import '../../../widgets/dashboard/hero_section.dart';
import '../../../widgets/dashboard/habit_card.dart';
import '../../../widgets/dashboard/insight_card.dart';
import '../../../widgets/dashboard/streak_celebration.dart';
import '../../../widgets/hydration/hydration_progress.dart';
import '../../../widgets/mewing/mewing_check_in.dart';
import '../../../widgets/chewing/chewing_timer.dart';
import '../../hydration/hydration_detail_screen.dart';
import '../../mewing/mewing_history_screen.dart';
import '../../chewing/chewing_timer_screen.dart';

class TodayTab extends ConsumerWidget {
  final VoidCallback onCapturePhoto;

  const TodayTab({
    super.key,
    required this.onCapturePhoto,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all the habit streaks
    final hydrationStreak = ref.watch(hydrationStreakProvider);
    final mewingStreak = ref.watch(mewingStreakProvider);
    final chewingStats = ref.watch(weekChewingStatsProvider);

    // Generate insights based on current state
    final insights = generateInsights(
      hydrationStreak: hydrationStreak.currentStreak,
      mewingStreak: mewingStreak.currentStreak,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(ref)
                .animate()
                .fadeIn(duration: 400.ms),

            const SizedBox(height: AppSpacing.xl),

            // Hero Section - Weekly Photo Progress
            HeroSection(
              onCapture: onCapturePhoto,
              onViewProgress: () {
                // Navigate to timeline tab
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // 2x2 Habit Grid
            _buildHabitGrid(context, ref)
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Streaks Section
            StreakCelebration(
              hydrationStreak: hydrationStreak.currentStreak,
              mewingStreak: mewingStreak.currentStreak,
              chewingStreak: chewingStats?.daysWithChewing ?? 0,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Insights Section
            InsightCard(
              insights: insights,
              onViewAll: () {
                // Navigate to insights screen
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            const Text('Today', style: AppTypography.display),
          ],
        ),
        const Spacer(),
        _buildStreakBadge(ref),
      ],
    );
  }

  Widget _buildStreakBadge(WidgetRef ref) {
    final hydrationStreak = ref.watch(hydrationStreakProvider);
    final mewingStreak = ref.watch(mewingStreakProvider);
    final chewingStats = ref.watch(weekChewingStatsProvider);

    // Calculate combined streak
    final streaks = [
      hydrationStreak.currentStreak,
      mewingStreak.currentStreak,
      chewingStats?.daysWithChewing ?? 0,
    ].where((s) => s > 0).toList();

    if (streaks.isEmpty) return const SizedBox.shrink();

    final combinedStreak = streaks.reduce((a, b) => a < b ? a : b);
    if (combinedStreak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '$combinedStreak',
            style: AppTypography.body.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitGrid(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            // Hydration Card
            Expanded(
              child: _buildHydrationCard(context, ref),
            ),
            const SizedBox(width: AppSpacing.md),
            // Mewing Card
            Expanded(
              child: _buildMewingCard(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            // Chewing Card
            Expanded(
              child: _buildChewingCard(context, ref),
            ),
            const SizedBox(width: AppSpacing.md),
            // Workouts Placeholder
            Expanded(
              child: PlaceholderHabitCard(
                title: 'Workouts',
                icon: Icons.fitness_center,
                message: 'Face exercises coming soon',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHydrationCard(BuildContext context, WidgetRef ref) {
    final todayHydration = ref.watch(todayHydrationProvider);
    final progress = ref.watch(hydrationProgressProvider);
    final streak = ref.watch(hydrationStreakProvider);

    final current = todayHydration?.totalMl ?? 0;
    final goal = todayHydration?.goalMl ?? 2500;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const HydrationDetailScreen(),
        ),
      ),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 16,
                      color: _getProgressColor(progress),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hydration',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (streak.currentStreak > 0)
                  StreakBadge(days: streak.currentStreak),
              ],
            ),
            const Spacer(),
            Text(
              _formatMl(current),
              style: AppTypography.title.copyWith(
                color: _getProgressColor(progress),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'of ${_formatMl(goal)}',
              style: AppTypography.footnote.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            HabitProgressBar(
              progress: progress,
              color: _getProgressColor(progress),
            ),
            const Spacer(),
            HabitSplitActions(
              leftLabel: '+250',
              rightLabel: '+500',
              onLeftTap: () => ref
                  .read(hydrationNotifierProvider.notifier)
                  .logHydration(250),
              onRightTap: () => ref
                  .read(hydrationNotifierProvider.notifier)
                  .logHydration(500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMewingCard(BuildContext context, WidgetRef ref) {
    final todaySession = ref.watch(todayMewingProvider);
    final streak = ref.watch(mewingStreakProvider);
    final isCheckedIn = todaySession?.checkedIn ?? false;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const MewingHistoryScreen(),
        ),
      ),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.face_outlined,
                      size: 16,
                      color: isCheckedIn ? AppColors.success : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mewing',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (streak.currentStreak > 0)
                  StreakBadge(days: streak.currentStreak),
              ],
            ),
            const Spacer(),
            if (isCheckedIn)
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Done!',
                    style: AppTypography.body.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Day ${streak.currentStreak + 1}',
                style: AppTypography.title,
              ),
            const SizedBox(height: 2),
            if (!isCheckedIn)
              Text(
                'Tap to check in',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            const Spacer(),
            if (!isCheckedIn)
              HabitActionButton(
                label: 'Check In',
                onTap: () => ref.read(mewingNotifierProvider.notifier).checkIn(),
              )
            else
              _buildWeekDots(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDots(WidgetRef ref) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = _isSameDay(date, now);
        final isPast = date.isBefore(now);
        // For demo, mark today as complete
        final isComplete = isToday;

        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppColors.success
                : (isPast ? AppColors.surfaceElevated : AppColors.border),
            border: isToday
                ? Border.all(color: AppColors.textPrimary, width: 2)
                : null,
          ),
          child: isComplete
              ? const Icon(
                  Icons.check,
                  size: 12,
                  color: AppColors.background,
                )
              : null,
        );
      }),
    );
  }

  Widget _buildChewingCard(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chewingNotifierProvider);
    final todayStats = ref.watch(todayChewingStatsProvider);
    final isRunning = state.isRunning;
    final isPaused = state.isPaused;

    final completedMinutes = todayStats?.totalMinutes ?? 0;
    final targetMinutes = todayStats?.targetMinutes ?? 20;
    final elapsedMinutes = state.elapsedSeconds ~/ 60;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ChewingTimerScreen(),
        ),
      ),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: isRunning ? AppColors.info : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Chewing',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (completedMinutes >= targetMinutes)
                  CheckBadge(checked: true),
              ],
            ),
            const Spacer(),
            if (isRunning)
              Text(
                _formatTime(state.elapsedSeconds),
                style: AppTypography.title.copyWith(
                  color: isPaused ? AppColors.warning : AppColors.info,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              )
            else
              Text(
                '$completedMinutes min',
                style: AppTypography.title,
              ),
            const SizedBox(height: 2),
            Text(
              isRunning
                  ? (isPaused ? 'Paused' : 'In progress...')
                  : 'of $targetMinutes min today',
              style: AppTypography.footnote.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            HabitProgressBar(
              progress: ((completedMinutes + elapsedMinutes) / targetMinutes).clamp(0, 1),
              color: isRunning ? AppColors.info : AppColors.textSecondary,
            ),
            const Spacer(),
            HabitActionButton(
              label: isRunning ? (isPaused ? 'Resume' : 'Pause') : 'Start',
              icon: isRunning ? (isPaused ? Icons.play_arrow : Icons.pause) : Icons.play_arrow,
              onTap: () {
                final notifier = ref.read(chewingNotifierProvider.notifier);
                if (!isRunning) {
                  notifier.startSession();
                } else if (isPaused) {
                  notifier.resumeSession();
                } else {
                  notifier.pauseSession();
                }
              },
              isPrimary: isRunning && isPaused,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.success;
    if (progress >= 0.7) return AppColors.info;
    if (progress >= 0.4) return AppColors.warning;
    return AppColors.textSecondary;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
