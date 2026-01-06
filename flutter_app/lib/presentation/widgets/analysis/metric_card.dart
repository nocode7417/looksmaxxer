import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/photo_model.dart';
import '../common/common_widgets.dart';

class MetricCard extends StatefulWidget {
  final MetricConfig config;
  final MetricValue value;
  final MetricValue? baselineValue;
  final bool showTrend;

  const MetricCard({
    super.key,
    required this.config,
    required this.value,
    this.baselineValue,
    this.showTrend = false,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final formattedValue = _formatValue();
    final scoreColor = _getScoreColor();

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: AppConstants.animationNormal,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.config.name,
                          style: AppTypography.titleSmall,
                        ),
                      ),
                      Text(
                        formattedValue,
                        style: AppTypography.title.copyWith(
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Progress bar
                  _buildProgressBar(),

                  const SizedBox(height: AppSpacing.md),

                  // Confidence row
                  Row(
                    children: [
                      ConfidenceBand(confidence: widget.value.confidence),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${widget.value.confidence.toInt()}% confidence',
                        style: AppTypography.footnote,
                      ),
                      const Spacer(),
                      Icon(
                        _isExpanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded content
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.config.description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Factors that affect this metric:',
                      style: AppTypography.captionMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: widget.config.factors.map((factor) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Text(
                            factor,
                            style: AppTypography.footnote,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    // For metrics with different ranges
    double progress;
    if (widget.config.id == 'proportionalHarmony') {
      // -15 to +15 range, 0 is ideal
      final absValue = widget.value.value.abs();
      progress = 1 - (absValue / 15);
    } else if (widget.config.id == 'canthalTilt') {
      // -10 to +15 range
      final normalized =
          (widget.value.value - widget.config.minValue) /
          (widget.config.maxValue - widget.config.minValue);
      progress = normalized;
    } else {
      // 0-100 range
      progress = widget.value.value / 100;
    }

    return AppProgressBar(
      value: progress * 100,
      height: 6,
      color: _getScoreColor(),
    );
  }

  String _formatValue() {
    final value = widget.value.value;

    if (widget.config.id == 'proportionalHarmony') {
      final sign = value >= 0 ? '+' : '';
      return '$sign${value.toStringAsFixed(1)}';
    } else if (widget.config.id == 'canthalTilt') {
      final sign = value >= 0 ? '+' : '';
      return '$sign${value.toStringAsFixed(1)}${widget.config.unit}';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Color _getScoreColor() {
    if (widget.config.id == 'proportionalHarmony') {
      // Closer to 0 is better
      final absValue = widget.value.value.abs();
      if (absValue <= 3) return AppColors.success;
      if (absValue <= 7) return AppColors.warning;
      return AppColors.error;
    }

    return AppColors.getScoreColor(
      widget.value.value,
      max: widget.config.maxValue,
    );
  }
}

/// Compact metric display for lists
class CompactMetricCard extends StatelessWidget {
  final MetricConfig config;
  final MetricValue value;

  const CompactMetricCard({
    super.key,
    required this.config,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.name,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            _formatValue(),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          ConfidenceDot(confidence: value.confidence),
        ],
      ),
    );
  }

  String _formatValue() {
    final v = value.value;
    if (config.id == 'proportionalHarmony' || config.id == 'canthalTilt') {
      final sign = v >= 0 ? '+' : '';
      return '$sign${v.toStringAsFixed(1)}${config.unit}';
    }
    return v.toStringAsFixed(0);
  }
}
