import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../widgets/analysis/metric_card.dart';

class BaselineTab extends ConsumerWidget {
  const BaselineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final metrics = appState.metrics;
    final hasBaseline = metrics.isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text('Baseline', style: AppTypography.display)
                .animate()
                .fadeIn(duration: 400.ms),

            const SizedBox(height: AppSpacing.xxl),

            if (!hasBaseline)
              _buildEmptyState()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
            else ...[
              // Baseline info card
              _buildBaselineInfoCard(appState)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.lg),

              // Confidence progress
              _buildConfidenceProgress(appState)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.xxl),

              // Metrics section
              const Text('Current Metrics', style: AppTypography.headline)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: AppSpacing.lg),

              // Metric cards
              ...MetricConfig.allMetrics.asMap().entries.map((entry) {
                final index = entry.key;
                final config = entry.value;
                final metricValue = metrics[config.id];

                if (metricValue == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: MetricCard(
                    config: config,
                    value: metricValue,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (350 + index * 80).ms)
                      .slideY(begin: 0.1, end: 0),
                );
              }),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.target,
              size: 28,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No Baseline Yet',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete the onboarding process to establish your baseline metrics.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBaselineInfoCard(AppStateModel appState) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final baselineDate = appState.baselineDate;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: const Icon(
              LucideIcons.checkCircle,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Baseline Established', style: AppTypography.titleSmall),
                const SizedBox(height: 4),
                Text(
                  baselineDate != null
                      ? dateFormat.format(baselineDate)
                      : 'Date unknown',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Text(
              'Active',
              style: AppTypography.footnote.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceProgress(AppStateModel appState) {
    final avgConfidence = appState.averageConfidence;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Average Confidence', style: AppTypography.titleSmall),
              const Spacer(),
              Text(
                '${avgConfidence.toStringAsFixed(0)}%',
                style: AppTypography.title.copyWith(
                  color: AppColors.getConfidenceColor(avgConfidence),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressBar(
            value: avgConfidence,
            height: 8,
            color: AppColors.getConfidenceColor(avgConfidence),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _getConfidenceMessage(avgConfidence),
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  String _getConfidenceMessage(double confidence) {
    if (confidence >= 80) {
      return 'Excellent confidence level. Your metrics are highly reliable.';
    } else if (confidence >= 60) {
      return 'Good confidence. Continue consistent captures for better accuracy.';
    } else {
      return 'Building confidence. More consistent photos will improve accuracy.';
    }
  }
}
