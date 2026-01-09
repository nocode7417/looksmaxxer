import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/hydration_model.dart';
import '../../../providers/hydration_provider.dart';

/// Circular hydration progress with quick-add buttons
class HydrationProgress extends ConsumerWidget {
  final bool compact;
  final VoidCallback? onTap;

  const HydrationProgress({
    super.key,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHydration = ref.watch(todayHydrationProvider);
    final progress = ref.watch(hydrationProgressProvider);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircularProgress(todayHydration, progress),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.md),
            _buildQuickAddButtons(ref),
          ],
        ],
      ),
    );
  }

  Widget _buildCircularProgress(HydrationDay? today, double progress) {
    final current = today?.totalMl ?? 0;
    final goal = today?.goalMl ?? 2500;

    return SizedBox(
      width: compact ? 80 : 120,
      height: compact ? 80 : 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: compact ? 6 : 8,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(AppColors.surfaceElevated),
            ),
          ),
          // Progress circle
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0, 1)),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: compact ? 6 : 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(_getProgressColor(progress)),
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatMl(current),
                style: compact ? AppTypography.body : AppTypography.title,
              ),
              Text(
                '/ ${_formatMl(goal)}',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButtons(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuickAddButton(
          label: '+250ml',
          onTap: () => _logHydration(ref, 250),
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickAddButton(
          label: '+500ml',
          onTap: () => _logHydration(ref, 500),
        ),
      ],
    );
  }

  void _logHydration(WidgetRef ref, int amountMl) {
    ref.read(hydrationNotifierProvider.notifier).logHydration(amountMl);
  }

  String _formatMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.success;
    if (progress >= 0.7) return AppColors.info;
    if (progress >= 0.4) return AppColors.warning;
    return AppColors.textSecondary;
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact hydration card for dashboard grid
class HydrationCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const HydrationCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHydration = ref.watch(todayHydrationProvider);
    final progress = ref.watch(hydrationProgressProvider);
    final streak = ref.watch(hydrationStreakProvider);

    final current = todayHydration?.totalMl ?? 0;
    final goal = todayHydration?.goalMl ?? 2500;

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
            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getProgressColor(progress),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Quick add buttons
            Row(
              children: [
                Expanded(
                  child: _MiniAddButton(
                    label: '+250',
                    onTap: () => ref
                        .read(hydrationNotifierProvider.notifier)
                        .logHydration(250),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _MiniAddButton(
                    label: '+500',
                    onTap: () => ref
                        .read(hydrationNotifierProvider.notifier)
                        .logHydration(500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.success;
    if (progress >= 0.7) return AppColors.info;
    if (progress >= 0.4) return AppColors.warning;
    return AppColors.textSecondary;
  }
}

class _MiniAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MiniAddButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.footnote.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
