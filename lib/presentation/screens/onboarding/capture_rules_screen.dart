import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class CaptureRulesScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const CaptureRulesScreen({
    super.key,
    required this.onContinue,
    required this.onBack,
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
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Photo Guidelines',
                      style: AppTypography.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For accurate tracking, follow these guidelines:',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Rule cards
                    _buildRuleCard(
                      index: 0,
                      icon: LucideIcons.sun,
                      title: 'Neutral Lighting',
                      description:
                          'Use soft, even lighting. Avoid harsh shadows or direct sunlight.',
                      rationale:
                          'Consistent lighting ensures accurate metric comparison over time.',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    _buildRuleCard(
                      index: 1,
                      icon: LucideIcons.camera,
                      title: 'Direct Camera Angle',
                      description:
                          'Hold the camera at eye level, facing straight ahead.',
                      rationale:
                          'Angled shots distort facial proportions and skew measurements.',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    _buildRuleCard(
                      index: 2,
                      icon: LucideIcons.user,
                      title: 'Neutral Expression',
                      description:
                          'Relax your face. Don\'t smile, squint, or tense any muscles.',
                      rationale:
                          'Expressions temporarily alter facial structure measurements.',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    _buildRuleCard(
                      index: 3,
                      icon: LucideIcons.ban,
                      title: 'No Filters',
                      description:
                          'Use your phone\'s default camera. No beauty modes or filters.',
                      rationale:
                          'Filters artificially modify features, making tracking meaningless.',
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: 'Take First Photo',
                isFullWidth: true,
                icon: LucideIcons.camera,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required String rationale,
  }) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.info,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          rationale,
                          style: AppTypography.footnote,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (100 * index).ms)
        .slideX(begin: 0.1, end: 0);
  }
}
