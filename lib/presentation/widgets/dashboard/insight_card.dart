import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// AI insight display card
class InsightCard extends StatelessWidget {
  final List<Insight> insights;
  final VoidCallback? onViewAll;

  const InsightCard({
    super.key,
    required this.insights,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

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
          // Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Insights',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Insights list
          ...insights.take(3).map((insight) => _InsightItem(
                insight: insight,
              )),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final Insight insight;

  const _InsightItem({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: _buildIcon(),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              insight.message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final color = _getTypeColor();
    final icon = _getTypeIcon();

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 12,
        color: color,
      ),
    );
  }

  Color _getTypeColor() {
    switch (insight.type) {
      case InsightType.improvement:
        return AppColors.success;
      case InsightType.milestone:
        return AppColors.warning;
      case InsightType.suggestion:
        return AppColors.info;
      case InsightType.warning:
        return AppColors.error;
      case InsightType.neutral:
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon() {
    switch (insight.type) {
      case InsightType.improvement:
        return Icons.trending_up;
      case InsightType.milestone:
        return Icons.emoji_events_outlined;
      case InsightType.suggestion:
        return Icons.tips_and_updates_outlined;
      case InsightType.warning:
        return Icons.warning_amber_rounded;
      case InsightType.neutral:
      default:
        return Icons.circle_outlined;
    }
  }
}

/// Single insight with more details
class DetailedInsightCard extends StatelessWidget {
  final Insight insight;
  final VoidCallback? onAction;

  const DetailedInsightCard({
    super.key,
    required this.insight,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  _getTypeIcon(),
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  insight.title ?? _getDefaultTitle(),
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            insight.message,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (insight.actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    insight.actionLabel!,
                    style: AppTypography.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Color _getTypeColor() {
    switch (insight.type) {
      case InsightType.improvement:
        return AppColors.success;
      case InsightType.milestone:
        return AppColors.warning;
      case InsightType.suggestion:
        return AppColors.info;
      case InsightType.warning:
        return AppColors.error;
      case InsightType.neutral:
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon() {
    switch (insight.type) {
      case InsightType.improvement:
        return Icons.trending_up;
      case InsightType.milestone:
        return Icons.emoji_events_outlined;
      case InsightType.suggestion:
        return Icons.tips_and_updates_outlined;
      case InsightType.warning:
        return Icons.warning_amber_rounded;
      case InsightType.neutral:
      default:
        return Icons.info_outline;
    }
  }

  String _getDefaultTitle() {
    switch (insight.type) {
      case InsightType.improvement:
        return 'Progress Update';
      case InsightType.milestone:
        return 'Milestone Reached';
      case InsightType.suggestion:
        return 'Tip for You';
      case InsightType.warning:
        return 'Attention';
      case InsightType.neutral:
      default:
        return 'Insight';
    }
  }
}

/// Insight data model
class Insight {
  final String id;
  final InsightType type;
  final String message;
  final String? title;
  final String? actionLabel;
  final DateTime createdAt;

  const Insight({
    required this.id,
    required this.type,
    required this.message,
    this.title,
    this.actionLabel,
    required this.createdAt,
  });

  factory Insight.improvement(String message, {String? title}) => Insight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: InsightType.improvement,
        message: message,
        title: title,
        createdAt: DateTime.now(),
      );

  factory Insight.milestone(String message, {String? title}) => Insight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: InsightType.milestone,
        message: message,
        title: title,
        createdAt: DateTime.now(),
      );

  factory Insight.suggestion(String message, {String? title, String? actionLabel}) => Insight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: InsightType.suggestion,
        message: message,
        title: title,
        actionLabel: actionLabel,
        createdAt: DateTime.now(),
      );

  factory Insight.warning(String message, {String? title}) => Insight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: InsightType.warning,
        message: message,
        title: title,
        createdAt: DateTime.now(),
      );
}

enum InsightType {
  improvement,
  milestone,
  suggestion,
  warning,
  neutral,
}

/// Generate sample insights based on app data
List<Insight> generateInsights({
  double? symmetryChange,
  int? hydrationStreak,
  int? mewingStreak,
  int? photoCount,
}) {
  final insights = <Insight>[];

  // Symmetry improvement
  if (symmetryChange != null && symmetryChange > 1) {
    insights.add(Insight.improvement(
      'Symmetry +${symmetryChange.toStringAsFixed(1)} this month',
    ));
  }

  // Mewing milestone
  if (mewingStreak != null && mewingStreak > 0) {
    if (mewingStreak == 7 || mewingStreak == 30 || mewingStreak == 90) {
      insights.add(Insight.milestone(
        '$mewingStreak-day mewing streak! Keep it up!',
      ));
    } else if (mewingStreak > 7) {
      insights.add(Insight.improvement(
        '$mewingStreak-day mewing streak going strong',
      ));
    }
  }

  // Hydration streak
  if (hydrationStreak != null && hydrationStreak >= 3) {
    insights.add(Insight.improvement(
      'Hydration goal met $hydrationStreak days in a row',
    ));
  }

  // Photo suggestions
  if (photoCount != null && photoCount < 3) {
    insights.add(Insight.suggestion(
      'Take weekly photos to track progress more accurately',
      actionLabel: 'Take Photo',
    ));
  }

  // Default insight if none generated
  if (insights.isEmpty) {
    insights.add(Insight.suggestion(
      'Complete your daily habits to unlock personalized insights',
    ));
  }

  return insights;
}
