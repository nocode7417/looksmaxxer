import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/hydration_model.dart';
import '../../../providers/hydration_provider.dart';
import '../../widgets/hydration/hydration_progress.dart';

/// Full hydration history and detail screen
class HydrationDetailScreen extends ConsumerStatefulWidget {
  const HydrationDetailScreen({super.key});

  @override
  ConsumerState<HydrationDetailScreen> createState() => _HydrationDetailScreenState();
}

class _HydrationDetailScreenState extends ConsumerState<HydrationDetailScreen> {
  int _selectedAmountMl = 250;

  @override
  Widget build(BuildContext context) {
    final todayHydration = ref.watch(todayHydrationProvider);
    final weekLogs = ref.watch(weekHydrationLogsProvider);
    final streak = ref.watch(hydrationStreakProvider);
    final progress = ref.watch(hydrationProgressProvider);

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
                  const Text('Hydration', style: AppTypography.title),
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
                    // Main progress circle
                    Center(
                      child: HydrationProgress(compact: false)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Custom amount adder
                    _buildCustomAmountAdder()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Today's logs
                    _buildTodayLogs(todayHydration)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Week overview
                    _buildWeekOverview(weekLogs)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Stats
                    _buildStats(streak)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms)
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

  Widget _buildCustomAmountAdder() {
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
            'Quick Add',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [100, 200, 250, 350, 500, 750]
                      .map((amount) => _buildAmountChip(amount))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${_selectedAmountMl}ml',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Material(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: InkWell(
                  onTap: _addHydration,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          size: 20,
                          color: AppColors.background,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: AppTypography.body.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(int amount) {
    final isSelected = _selectedAmountMl == amount;

    return GestureDetector(
      onTap: () => setState(() => _selectedAmountMl = amount),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.info.withOpacity(0.1) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.info : Colors.transparent,
          ),
        ),
        child: Text(
          '${amount}ml',
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? AppColors.info : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayLogs(HydrationDay? today) {
    final logs = today?.logs ?? [];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Log',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${logs.length} entries',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (logs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No logs yet today',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...logs.reversed.take(5).map((log) => _buildLogItem(log)),
          if (logs.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Center(
                child: Text(
                  '+ ${logs.length - 5} more entries',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogItem(HydrationLog log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              _getDrinkIcon(log.drinkType),
              size: 16,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+${log.amountMl}ml',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  log.drinkType.displayName,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(log.timestamp),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekOverview(List<HydrationLog> weekLogs) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Group logs by day
    final dailyTotals = <int, int>{};
    for (final log in weekLogs) {
      final dayOffset = log.timestamp.difference(startOfWeek).inDays;
      if (dayOffset >= 0 && dayOffset < 7) {
        dailyTotals[dayOffset] = (dailyTotals[dayOffset] ?? 0) + log.amountMl;
      }
    }

    final maxTotal = dailyTotals.values.fold<int>(0, (a, b) => a > b ? a : b);
    final goalMl = 2500; // Default goal for visualization

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
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final total = dailyTotals[index] ?? 0;
              final isToday = index == now.weekday - 1;
              final height = maxTotal > 0
                  ? (total / goalMl * 60).clamp(4.0, 60.0)
                  : 4.0;
              final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

              return Column(
                children: [
                  Container(
                    width: 28,
                    height: 60,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 28,
                      height: height,
                      decoration: BoxDecoration(
                        color: total >= goalMl
                            ? AppColors.success
                            : (isToday ? AppColors.info : AppColors.surfaceElevated),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    dayLabels[index],
                    style: AppTypography.footnote.copyWith(
                      color: isToday ? AppColors.textPrimary : AppColors.textTertiary,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(HydrationStreak streak) {
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
                  'Current Streak',
                  '${streak.currentStreak}',
                  'days',
                  Icons.local_fire_department,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatItem(
                  'Best Streak',
                  '${streak.longestStreak}',
                  'days',
                  Icons.emoji_events_outlined,
                  AppColors.warning,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.title.copyWith(
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: AppTypography.caption.copyWith(
                    color: color.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
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

  IconData _getDrinkIcon(DrinkType type) {
    switch (type) {
      case DrinkType.water:
        return Icons.water_drop;
      case DrinkType.tea:
        return Icons.local_cafe_outlined;
      case DrinkType.coffee:
        return Icons.coffee;
      case DrinkType.juice:
        return Icons.local_drink;
      case DrinkType.other:
        return Icons.local_bar;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _addHydration() {
    ref.read(hydrationNotifierProvider.notifier).logHydration(_selectedAmountMl);
  }
}
