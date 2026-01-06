import 'package:flutter/material.dart';

/// App color palette matching the original Looksmaxxer design system
class AppColors {
  AppColors._();

  // Background colors
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceElevated = Color(0xFF1A1A1A);

  // Border colors
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderSubtle = Color(0xFF1F1F1F);

  // Text colors
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1A1);
  static const Color textTertiary = Color(0xFF666666);

  // Accent colors
  static const Color accent = Color(0xFFE5E5E5);
  static const Color muted = Color(0xFF404040);

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
  );

  // Confidence level colors
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 70) return success;
    if (confidence >= 40) return warning;
    return error;
  }

  // Metric score colors
  static Color getScoreColor(double score, {double max = 100}) {
    final percentage = score / max;
    if (percentage >= 0.7) return success;
    if (percentage >= 0.4) return warning;
    return error;
  }
}
