import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Animated streak display for dashboard
class StreakCelebration extends StatelessWidget {
  final int hydrationStreak;
  final int mewingStreak;
  final int chewingStreak;
  final VoidCallback? onTap;

  const StreakCelebration({
    super.key,
    required this.hydrationStreak,
    required this.mewingStreak,
    required this.chewingStreak,
    this.onTap,
  });

  int get combinedStreak {
    // Combined streak = minimum of all active streaks
    final activeStreaks = [hydrationStreak, mewingStreak, chewingStreak]
        .where((s) => s > 0)
        .toList();
    if (activeStreaks.isEmpty) return 0;
    return activeStreaks.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
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
            // Individual streaks row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StreakItem(
                  emoji: '\ud83d\udca7',
                  count: hydrationStreak,
                  label: 'Hydration',
                  color: AppColors.info,
                ),
                _StreakItem(
                  emoji: '\ud83d\udde3\ufe0f',
                  count: mewingStreak,
                  label: 'Mewing',
                  color: AppColors.success,
                ),
                _StreakItem(
                  emoji: '\ud83e\uddb7',
                  count: chewingStreak,
                  label: 'Chewing',
                  color: AppColors.warning,
                ),
              ],
            ),
            if (combinedStreak > 0) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              // Combined streak
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FireIcon(days: combinedStreak),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$combinedStreak-day streak',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (combinedStreak >= 7) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getMilestoneLabel(combinedStreak),
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMilestoneLabel(int days) {
    if (days >= 365) return 'Legend';
    if (days >= 180) return 'Hero';
    if (days >= 90) return 'Champion';
    if (days >= 30) return 'Master';
    if (days >= 7) return 'Warrior';
    return '';
  }
}

class _StreakItem extends StatelessWidget {
  final String emoji;
  final int count;
  final String label;
  final Color color;

  const _StreakItem({
    required this.emoji,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = count > 0;

    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(
            fontSize: 20,
            color: isActive ? null : AppColors.textTertiary,
          ),
        )
            .animate(target: isActive ? 1 : 0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 300.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1, 1),
              duration: 200.ms,
            ),
        const SizedBox(height: 4),
        Text(
          isActive ? '$count' : '-',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? color : AppColors.textTertiary,
          ),
        ),
        Text(
          label,
          style: AppTypography.footnote.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _FireIcon extends StatelessWidget {
  final int days;

  const _FireIcon({required this.days});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (days >= 30) {
      color = AppColors.error;
    } else if (days >= 7) {
      color = AppColors.warning;
    } else {
      color = AppColors.textSecondary;
    }

    return Icon(
      Icons.local_fire_department,
      size: 20,
      color: color,
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 2.seconds,
          color: color.withOpacity(0.3),
        );
  }
}

/// Milestone celebration overlay
class MilestoneCelebration extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback onDismiss;

  const MilestoneCelebration({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.warning.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated emoji
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 64),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .shake(hz: 2, duration: 500.ms),
                const SizedBox(height: AppSpacing.lg),
                // Title
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: AppColors.warning,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 200.ms,
                      duration: 300.ms,
                    ),
                const SizedBox(height: AppSpacing.sm),
                // Subtitle
                Text(
                  subtitle,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms).slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 400.ms,
                      duration: 300.ms,
                    ),
                const SizedBox(height: AppSpacing.xl),
                // Dismiss button
                Material(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: InkWell(
                    onTap: onDismiss,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        'Awesome!',
                        style: AppTypography.body.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      delay: 600.ms,
                      duration: 300.ms,
                    ),
              ],
            ),
          ).animate().fadeIn().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
        ),
      ),
    );
  }
}

/// Shows a milestone celebration
Future<void> showMilestoneCelebration(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String emoji,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => MilestoneCelebration(
      title: title,
      subtitle: subtitle,
      emoji: emoji,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}

/// Compact streak row for inline display
class StreakRow extends StatelessWidget {
  final int hydrationStreak;
  final int mewingStreak;
  final int chewingStreak;

  const StreakRow({
    super.key,
    required this.hydrationStreak,
    required this.mewingStreak,
    required this.chewingStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hydrationStreak > 0) ...[
          _MiniStreak(emoji: '\ud83d\udca7', count: hydrationStreak),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (mewingStreak > 0) ...[
          _MiniStreak(emoji: '\ud83d\udde3\ufe0f', count: mewingStreak),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (chewingStreak > 0)
          _MiniStreak(emoji: '\ud83e\uddb7', count: chewingStreak),
      ],
    );
  }
}

class _MiniStreak extends StatelessWidget {
  final String emoji;
  final int count;

  const _MiniStreak({
    required this.emoji,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 2),
        Text(
          '$count',
          style: AppTypography.footnote.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
