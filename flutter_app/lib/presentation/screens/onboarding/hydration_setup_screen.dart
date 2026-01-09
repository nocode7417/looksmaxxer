import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/hydration_model.dart';
import '../../../providers/hydration_provider.dart';

/// Hydration setup screen for optional personalization during onboarding
class HydrationSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const HydrationSetupScreen({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  ConsumerState<HydrationSetupScreen> createState() => _HydrationSetupScreenState();
}

class _HydrationSetupScreenState extends ConsumerState<HydrationSetupScreen> {
  double _weightKg = 70.0;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  bool _usePersonalized = true;

  int get _calculatedGoal {
    if (!_usePersonalized) return 2500;
    return (_weightKg * _activityLevel.mlPerKg).round();
  }

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
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (widget.onSkip != null)
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text(
                        'Skip',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Hydration Goal',
                      style: AppTypography.display,
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      'Set a personalized goal or use the default',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                    const SizedBox(height: AppSpacing.xxl),

                    // Goal preview
                    _buildGoalPreview()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppSpacing.xl),

                    // Toggle for personalized
                    _buildPersonalizedToggle()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms),

                    if (_usePersonalized) ...[
                      const SizedBox(height: AppSpacing.xl),

                      // Weight slider
                      _buildWeightSlider()
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: AppSpacing.xl),

                      // Activity level
                      _buildActivityLevelSelector()
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideX(begin: -0.1, end: 0),
                    ],

                    const SizedBox(height: AppSpacing.xxl),

                    // Info
                    _buildInfoCard()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms),
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: InkWell(
                    onTap: _saveAndContinue,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      alignment: Alignment.center,
                      child: Text(
                        'Continue',
                        style: AppTypography.body.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPreview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.surfaceElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop,
            size: 48,
            color: AppColors.info,
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: _calculatedGoal),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, _) => Text(
              _formatMl(value),
              style: AppTypography.display.copyWith(
                fontSize: 48,
                color: AppColors.info,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Daily Goal',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalize goal',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Based on weight and activity',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _usePersonalized,
            onChanged: (value) => setState(() => _usePersonalized = value),
            activeColor: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSlider() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_weightKg.round()} kg',
                style: AppTypography.body.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.info,
              inactiveTrackColor: AppColors.surfaceElevated,
              thumbColor: AppColors.info,
              overlayColor: AppColors.info.withOpacity(0.2),
            ),
            child: Slider(
              value: _weightKg,
              min: 40,
              max: 150,
              divisions: 110,
              onChanged: (value) => setState(() => _weightKg = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '40 kg',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                '150 kg',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelSelector() {
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
          Text(
            'Activity Level',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...ActivityLevel.values.map((level) => _buildActivityOption(level)),
        ],
      ),
    );
  }

  Widget _buildActivityOption(ActivityLevel level) {
    final isSelected = _activityLevel == level;

    return GestureDetector(
      onTap: () => setState(() => _activityLevel = level),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.info.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.info : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getActivityIcon(level),
              size: 20,
              color: isSelected ? AppColors.info : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.displayName,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.info : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _getActivityDescription(level),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${level.mlPerKg.round()} ml/kg',
              style: AppTypography.footnote.copyWith(
                color: isSelected ? AppColors.info : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'You can always change your goal later in settings.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return Icons.chair;
      case ActivityLevel.moderate:
        return Icons.directions_walk;
      case ActivityLevel.active:
        return Icons.directions_run;
    }
  }

  String _getActivityDescription(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Office work, minimal exercise';
      case ActivityLevel.moderate:
        return 'Regular walks, light exercise';
      case ActivityLevel.active:
        return 'Intense workouts, physical job';
    }
  }

  String _formatMl(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  void _saveAndContinue() {
    final notifier = ref.read(hydrationNotifierProvider.notifier);

    if (_usePersonalized) {
      notifier.setGoal(
        HydrationGoal.personalized(
          weightKg: _weightKg,
          activityLevel: _activityLevel,
        ),
      );
    } else {
      notifier.setGoal(HydrationGoal.defaultGoal());
    }

    widget.onComplete();
  }
}
