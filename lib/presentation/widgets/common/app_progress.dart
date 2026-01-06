import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

/// Linear progress bar with optional label
class AppProgressBar extends StatelessWidget {
  final double value;
  final double? maxValue;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;
  final bool showLabel;
  final String? label;

  const AppProgressBar({
    super.key,
    required this.value,
    this.maxValue,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
    this.showLabel = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final max = maxValue ?? 100;
    final progress = (value / max).clamp(0.0, 1.0);
    final radius = borderRadius ?? AppSpacing.borderRadiusFull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel || label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(label!, style: AppTypography.caption),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surfaceElevated,
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: AppConstants.animationNormal,
                curve: Curves.easeOut,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color ?? AppColors.textPrimary,
                  borderRadius: radius,
                ),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: color ?? AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Confidence band indicator
class ConfidenceBand extends StatelessWidget {
  final double confidence;
  final double width;
  final double height;

  const ConfidenceBand({
    super.key,
    required this.confidence,
    this.width = 60,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getConfidenceColor(confidence);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: confidence / 100,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
        ),
      ),
    );
  }
}

/// Circular progress indicator with value display
class CircularScoreIndicator extends StatelessWidget {
  final double value;
  final double maxValue;
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? label;
  final TextStyle? valueStyle;

  const CircularScoreIndicator({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.size = 80,
    this.strokeWidth = 6,
    this.color,
    this.label,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    final progressColor = color ?? AppColors.getScoreColor(value, max: maxValue);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(AppColors.surfaceElevated),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(progressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Value display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
                style: valueStyle ?? AppTypography.title,
              ),
              if (label != null)
                Text(
                  label!,
                  style: AppTypography.footnote,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Confidence dot indicator (small colored dot)
class ConfidenceDot extends StatelessWidget {
  final double confidence;
  final double size;

  const ConfidenceDot({
    super.key,
    required this.confidence,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.getConfidenceColor(confidence),
        shape: BoxShape.circle,
      ),
    );
  }
}
