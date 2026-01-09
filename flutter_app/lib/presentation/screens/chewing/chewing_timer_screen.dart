import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/chewing_model.dart';
import '../../../providers/chewing_provider.dart';
import '../../widgets/chewing/chewing_timer.dart';

/// Full-screen chewing timer screen
class ChewingTimerScreen extends ConsumerWidget {
  const ChewingTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chewingNotifierProvider);
    final todayStats = ref.watch(todayChewingStatsProvider);
    final weekStats = ref.watch(weekChewingStatsProvider);

    final completedMinutes = todayStats?.totalMinutes ?? 0;
    final targetMinutes = todayStats?.targetMinutes ?? 20;

    // Check if TMJ warning should be shown
    final showTmjWarning = completedMinutes >= AppConstants.chewingTmjWarningMinutes;

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
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('Chewing Timer', style: AppTypography.title),
                  const Spacer(),
                  _buildLevelBadge(ChewingLevel.fromTargetMinutes(targetMinutes)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    // TMJ Warning
                    if (showTmjWarning)
                      TMJWarningBanner(
                        todayMinutes: completedMinutes,
                        warningThreshold: AppConstants.chewingTmjWarningMinutes,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Main timer
                    ChewingTimer(compact: false)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                    const SizedBox(height: AppSpacing.xxl),

                    // Today's progress
                    _buildTodayProgress(completedMinutes, targetMinutes)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Level selector
                    _buildLevelSelector(ref)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Week stats
                    _buildWeekStats(weekStats)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Info card
                    _buildInfoCard()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(ChewingLevel level) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getLevelColor(level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getLevelIcon(level),
            size: 14,
            color: _getLevelColor(level),
          ),
          const SizedBox(width: 4),
          Text(
            level.displayName,
            style: AppTypography.caption.copyWith(
              color: _getLevelColor(level),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(int completedMinutes, int targetMinutes) {
    final progress = (completedMinutes / targetMinutes).clamp(0.0, 1.0);
    final isComplete = completedMinutes >= targetMinutes;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.background,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Complete',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completedMinutes',
                style: AppTypography.title.copyWith(
                  fontSize: 32,
                  color: isComplete ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  ' / $targetMinutes min',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: isComplete ? AppColors.success : AppColors.info,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Target',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: ChewingLevel.values.map((level) {
              final currentTarget = ref.watch(chewingNotifierProvider).targetMinutes;
              final isSelected = currentTarget == level.targetMinutes;

              return Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(chewingNotifierProvider.notifier)
                      .setLevel(level),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: level != ChewingLevel.values.last
                          ? AppSpacing.sm
                          : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getLevelColor(level).withOpacity(0.1)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? _getLevelColor(level)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getLevelIcon(level),
                          size: 20,
                          color: isSelected
                              ? _getLevelColor(level)
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level.displayName,
                          style: AppTypography.footnote.copyWith(
                            color: isSelected
                                ? _getLevelColor(level)
                                : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${level.targetMinutes} min',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStats(ChewingWeekStats? weekStats) {
    final sessions = weekStats?.sessions ?? [];
    final totalMinutes = weekStats?.totalMinutes ?? 0;
    final completedDays = weekStats?.daysWithChewing ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Total Time',
                  '$totalMinutes min',
                  Icons.timer_outlined,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatBox(
                  'Active Days',
                  '$completedDays / 7',
                  Icons.calendar_today,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatBox(
                  'Sessions',
                  '${sessions.length}',
                  Icons.repeat,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTypography.footnote.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.info,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Chewing Benefits',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Consistent chewing exercises can help strengthen jaw muscles and improve facial definition. Start slowly and increase duration gradually.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Stop immediately if you experience jaw pain or discomfort.',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(ChewingLevel level) {
    switch (level) {
      case ChewingLevel.beginner:
        return AppColors.success;
      case ChewingLevel.intermediate:
        return AppColors.info;
      case ChewingLevel.advanced:
        return AppColors.warning;
    }
  }

  IconData _getLevelIcon(ChewingLevel level) {
    switch (level) {
      case ChewingLevel.beginner:
        return Icons.sentiment_satisfied;
      case ChewingLevel.intermediate:
        return Icons.sentiment_very_satisfied;
      case ChewingLevel.advanced:
        return Icons.whatshot;
    }
  }
}
