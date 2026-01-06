import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system matching the original Looksmaxxer design
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'SF Pro Display';

  // Display - 36px, bold, -0.02em tracking
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.72, // -0.02em
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Headline - 24px, semibold
  static const TextStyle headline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // Title - 20px, semibold
  static const TextStyle title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Title Small - 17px, semibold
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.34,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  // Body - 15px, normal
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Body Medium - 15px, medium weight
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Caption - 13px, secondary color
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Caption Medium - 13px, medium weight
  static const TextStyle captionMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.08,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Footnote - 11px, tertiary color
  static const TextStyle footnote = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textTertiary,
    height: 1.35,
  );

  // Button text - 15px, semibold
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Label - 12px, medium weight
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Score Display - Large number display
  static const TextStyle scoreDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // Metric Value - Medium number display
  static const TextStyle metricValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );
}
