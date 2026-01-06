import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/photo_model.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/analysis/metric_card.dart';

class ReportScreen extends StatelessWidget {
  final Map<String, MetricValue> metrics;
  final VoidCallback onContinue;

  const ReportScreen({
    super.key,
    required this.metrics,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(width: 48),
                  const Expanded(
                    child: Text(
                      'Analysis Complete',
                      style: AppTypography.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      color: AppColors.success,
                      size: 24,
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
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppSpacing.borderRadiusLg,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.info,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'This establishes your baseline. Track changes over time with consistent photos.',
                              style: AppTypography.caption,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xxl),

                    // Section title
                    const Text(
                      'Your Baseline Metrics',
                      style: AppTypography.headline,
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

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
                            .fadeIn(duration: 400.ms, delay: (150 + index * 80).ms)
                            .slideY(begin: 0.1, end: 0),
                      );
                    }),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: 'Start Tracking',
                isFullWidth: true,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
