import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Reusable habit card for dashboard 2x2 grid
class HabitCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget? badge;
  final Widget content;
  final Widget? action;
  final VoidCallback? onTap;
  final bool highlighted;

  const HabitCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.badge,
    required this.content,
    this.action,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.surfaceElevated
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: highlighted
                ? AppColors.textPrimary.withOpacity(0.2)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: iconColor ?? AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (badge != null) badge!,
              ],
            ),
            const Spacer(),
            // Main content
            content,
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
            const Spacer(),
            // Action
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

/// Badge for showing streaks
class StreakBadge extends StatelessWidget {
  final int days;
  final Color? color;

  const StreakBadge({
    super.key,
    required this.days,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (days <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.success).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${days}d',
        style: AppTypography.footnote.copyWith(
          color: color ?? AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Check badge
class CheckBadge extends StatelessWidget {
  final bool checked;
  final Color? color;

  const CheckBadge({
    super.key,
    required this.checked,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!checked) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.success).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.check,
        size: 12,
        color: color ?? AppColors.success,
      ),
    );
  }
}

/// Habit progress bar
class HabitProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;

  const HabitProgressBar({
    super.key,
    required this.progress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: color ?? AppColors.textSecondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

/// Mini action button for habit cards
class HabitActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const HabitActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: isPrimary ? AppColors.textPrimary : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14,
                    color: isPrimary
                        ? AppColors.background
                        : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: AppTypography.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPrimary
                        ? AppColors.background
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Split action buttons (two side-by-side)
class HabitSplitActions extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  const HabitSplitActions({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: InkWell(
              onTap: onLeftTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                child: Text(
                  leftLabel,
                  style: AppTypography.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Material(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: InkWell(
              onTap: onRightTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                child: Text(
                  rightLabel,
                  style: AppTypography.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder habit card for upcoming features
class PlaceholderHabitCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const PlaceholderHabitCard({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.footnote.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Coming Soon',
              style: AppTypography.footnote.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
