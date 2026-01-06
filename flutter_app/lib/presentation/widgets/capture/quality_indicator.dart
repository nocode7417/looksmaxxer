import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/photo_model.dart';
import '../../../engine/quality_validator.dart';

/// Quality indicator widget showing photo quality metrics
class QualityIndicator extends StatelessWidget {
  final QualityScore qualityScore;

  const QualityIndicator({
    super.key,
    required this.qualityScore,
  });

  @override
  Widget build(BuildContext context) {
    final feedback = QualityValidator.getQualityFeedback(qualityScore);
    final isAcceptable = qualityScore.isAcceptable;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: isAcceptable ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAcceptable ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                color: isAcceptable ? AppColors.success : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                qualityScore.qualityLabel,
                style: AppTypography.titleSmall.copyWith(
                  color: isAcceptable ? AppColors.success : AppColors.warning,
                ),
              ),
              const Spacer(),
              Text(
                '${qualityScore.overall.toInt()}%',
                style: AppTypography.title,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Quality metrics
          Row(
            children: [
              _buildMetricChip('Brightness', qualityScore.brightness),
              const SizedBox(width: AppSpacing.sm),
              _buildMetricChip('Contrast', qualityScore.contrast),
              const SizedBox(width: AppSpacing.sm),
              _buildMetricChip('Sharpness', qualityScore.sharpness),
            ],
          ),

          // Feedback messages
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...feedback.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        f.type == QualityFeedbackType.success
                            ? LucideIcons.check
                            : LucideIcons.alertTriangle,
                        size: 14,
                        color: f.type == QualityFeedbackType.success
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          f.message,
                          style: AppTypography.caption,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, double value) {
    final color = value >= 60
        ? AppColors.success
        : value >= 40
            ? AppColors.warning
            : AppColors.error;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Column(
          children: [
            Text(
              '${value.toInt()}',
              style: AppTypography.bodyMedium.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTypography.footnote,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Real-time quality feedback during capture
class LiveQualityFeedback extends StatelessWidget {
  final double brightness;
  final double contrast;
  final double sharpness;

  const LiveQualityFeedback({
    super.key,
    required this.brightness,
    required this.contrast,
    required this.sharpness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(LucideIcons.sun, brightness),
          const SizedBox(width: AppSpacing.md),
          _buildIndicator(LucideIcons.contrast, contrast),
          const SizedBox(width: AppSpacing.md),
          _buildIndicator(LucideIcons.focus, sharpness),
        ],
      ),
    );
  }

  Widget _buildIndicator(IconData icon, double value) {
    final color = value >= 60
        ? AppColors.success
        : value >= 40
            ? AppColors.warning
            : AppColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
