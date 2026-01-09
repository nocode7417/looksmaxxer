import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/mewing_model.dart';
import '../../../providers/mewing_provider.dart';

/// Single-tap mewing check-in button with streak display
class MewingCheckIn extends ConsumerWidget {
  final bool compact;
  final VoidCallback? onTap;

  const MewingCheckIn({
    super.key,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySession = ref.watch(todayMewingProvider);
    final streak = ref.watch(mewingStreakProvider);
    final isCheckedIn = todaySession?.checkedIn ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCheckInButton(ref, isCheckedIn, streak),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.md),
            _buildStreakDisplay(streak),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckInButton(WidgetRef ref, bool isCheckedIn, MewingStreak streak) {
    return GestureDetector(
      onTap: isCheckedIn
          ? null
          : () => ref.read(mewingNotifierProvider.notifier).checkIn(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: compact ? 80 : 100,
        height: compact ? 80 : 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCheckedIn ? AppColors.success : AppColors.surfaceElevated,
          border: Border.all(
            color: isCheckedIn ? AppColors.success : AppColors.border,
            width: 2,
          ),
          boxShadow: isCheckedIn
              ? [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isCheckedIn
              ? Icon(
                  Icons.check_rounded,
                  size: compact ? 32 : 40,
                  color: AppColors.background,
                ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: compact ? 24 : 32,
                      color: AppColors.textSecondary,
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Check In',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStreakDisplay(MewingStreak streak) {
    return Column(
      children: [
        Text(
          'Day ${streak.currentStreak}',
          style: AppTypography.title,
        ),
        const SizedBox(height: 4),
        Text(
          streak.currentStreak == 0
              ? 'Start your streak!'
              : 'Keep it going!',
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Compact mewing card for dashboard grid
class MewingCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const MewingCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySession = ref.watch(todayMewingProvider);
    final streak = ref.watch(mewingStreakProvider);
    final isCheckedIn = todaySession?.checkedIn ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${streak.currentStreak}d',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (isCheckedIn)
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
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
            // Check-in button or calendar preview
            if (!isCheckedIn)
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: InkWell(
                    onTap: () => ref.read(mewingNotifierProvider.notifier).checkIn(),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: Text(
                        'Check In',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
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
        // For demo, mark today and a few past days as complete
        final isComplete = isToday || (isPast && index > now.weekday - 4);

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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Calendar view showing mewing check-in history
class MewingCalendar extends ConsumerWidget {
  final DateTime month;

  const MewingCalendar({
    super.key,
    required this.month,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthDataAsync = ref.watch(mewingMonthProvider(month));

    return monthDataAsync.when(
      data: (monthData) => _buildCalendarContent(monthData),
      loading: () => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => _buildCalendarContent(null),
    );
  }

  Widget _buildCalendarContent(MewingMonth? monthData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text(
            _formatMonth(month),
            style: AppTypography.titleSmall,
          ),
        ),
        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((day) => SizedBox(
                    width: 36,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Calendar grid
        _buildCalendarGrid(monthData, month),
      ],
    );
  }

  Widget _buildCalendarGrid(MewingMonth? monthData, DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startPadding = firstDay.weekday - 1;
    final totalDays = lastDay.day;
    final today = DateTime.now();

    final checkedInDates = monthData?.sessions
            .where((s) => s.checkedIn)
            .map((s) => s.date.day)
            .toSet() ??
        {};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: startPadding + totalDays,
      itemBuilder: (context, index) {
        if (index < startPadding) {
          return const SizedBox.shrink();
        }

        final day = index - startPadding + 1;
        final date = DateTime(month.year, month.month, day);
        final isToday = _isSameDay(date, today);
        final isCheckedIn = checkedInDates.contains(day);
        final isFuture = date.isAfter(today);

        return Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCheckedIn
                  ? AppColors.success
                  : (isFuture ? Colors.transparent : AppColors.surfaceElevated),
              border: isToday
                  ? Border.all(color: AppColors.textPrimary, width: 2)
                  : null,
            ),
            child: Center(
              child: isCheckedIn
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.background,
                    )
                  : Text(
                      '$day',
                      style: AppTypography.footnote.copyWith(
                        color: isFuture
                            ? AppColors.textTertiary
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
