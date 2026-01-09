import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/mewing_model.dart';
import '../../../providers/mewing_provider.dart';
import '../../widgets/mewing/mewing_check_in.dart';

/// Mewing history screen with calendar and milestones
class MewingHistoryScreen extends ConsumerStatefulWidget {
  const MewingHistoryScreen({super.key});

  @override
  ConsumerState<MewingHistoryScreen> createState() => _MewingHistoryScreenState();
}

class _MewingHistoryScreenState extends ConsumerState<MewingHistoryScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final todaySession = ref.watch(todayMewingProvider);
    final streak = ref.watch(mewingStreakProvider);
    final isCheckedIn = todaySession?.checkedIn ?? false;

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
                  const Text('Mewing', style: AppTypography.title),
                  const Spacer(),
                  if (streak.currentStreak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${streak.currentStreak}',
                            style: AppTypography.body.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Check-in section
                    _buildCheckInSection(isCheckedIn, streak)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Calendar
                    _buildCalendarSection()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Milestones
                    _buildMilestonesSection(streak)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Stats
                    _buildStatsSection(streak)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

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

  Widget _buildCheckInSection(bool isCheckedIn, MewingStreak streak) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isCheckedIn
                ? AppColors.success.withOpacity(0.1)
                : AppColors.surfaceElevated,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isCheckedIn
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          MewingCheckIn(compact: false),
          const SizedBox(height: AppSpacing.lg),
          if (streak.currentStreak > 0)
            Text(
              _getStreakMessage(streak.currentStreak),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
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
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
              ),
              Text(
                _formatMonth(_selectedMonth),
                style: AppTypography.titleSmall,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _selectedMonth.month == DateTime.now().month &&
                        _selectedMonth.year == DateTime.now().year
                    ? null
                    : () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MewingCalendar(month: _selectedMonth),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection(MewingStreak streak) {
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
            'Milestones',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...AppConstants.mewingMilestones.map((days) {
            final isAchieved = streak.longestStreak >= days;
            final isNext = !isAchieved &&
                streak.longestStreak <
                    days &&
                (AppConstants.mewingMilestones
                        .where((d) => d < days && streak.longestStreak >= d)
                        .isEmpty ||
                    days ==
                        AppConstants.mewingMilestones.firstWhere(
                          (d) => streak.longestStreak < d,
                          orElse: () => days,
                        ));

            return _buildMilestoneItem(
              days: days,
              title: _getMilestoneTitle(days),
              isAchieved: isAchieved,
              isNext: isNext,
              currentStreak: streak.currentStreak,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem({
    required int days,
    required String title,
    required bool isAchieved,
    required bool isNext,
    required int currentStreak,
  }) {
    final progress = isAchieved ? 1.0 : (currentStreak / days).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isAchieved
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: isNext
                  ? Border.all(color: AppColors.warning, width: 2)
                  : null,
            ),
            child: Center(
              child: isAchieved
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: AppColors.success,
                    )
                  : Text(
                      '$days',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isAchieved ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$days days',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (!isAchieved && isNext)
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(MewingStreak streak) {
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
            'Stats',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Current',
                  '${streak.currentStreak}',
                  'days',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatItem(
                  'Best',
                  '${streak.longestStreak}',
                  'days',
                  Icons.emoji_events_outlined,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '${streak.totalCheckIns}',
                  'check-ins',
                  Icons.calendar_today,
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
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
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.title.copyWith(
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getMilestoneTitle(int days) {
    switch (days) {
      case 7:
        return 'Week Warrior';
      case 30:
        return 'Month Master';
      case 90:
        return 'Quarter Champion';
      case 180:
        return 'Half-Year Hero';
      case 365:
        return 'Year Legend';
      default:
        return '$days Day Streak';
    }
  }

  String _getStreakMessage(int days) {
    if (days >= 365) return 'Legendary! A full year of consistency!';
    if (days >= 180) return 'Amazing! Half a year of dedication!';
    if (days >= 90) return 'Incredible! 3 months strong!';
    if (days >= 30) return 'Awesome! A whole month completed!';
    if (days >= 7) return 'Great job! One week down!';
    if (days >= 3) return 'Building momentum! Keep going!';
    return 'Every day counts. Stay consistent!';
  }
}
