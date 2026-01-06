import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/providers.dart';
import '../../../../game/game.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/common_widgets.dart';

class TodayTab extends ConsumerWidget {
  final VoidCallback onCapturePhoto;

  const TodayTab({
    super.key,
    required this.onCapturePhoto,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final todaysChallenge = ref.watch(todaysChallengeProvider);
    final appStateNotifier = ref.read(appStateProvider.notifier);

    final hasCapturedToday = appStateNotifier.hasCapturedToday();
    final hasCompletedChallenge = appStateNotifier.hasCompletedTodaysChallenge();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('Today', style: AppTypography.display),
                const Spacer(),
                if (appState.challengeStreak > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.flame,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${appState.challengeStreak}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: AppSpacing.xxl),

            // Progress Score Card
            _buildProgressScoreCard(appState)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Daily Challenge Card
            _buildChallengeCard(
              challenge: todaysChallenge,
              isCompleted: hasCompletedChallenge,
              onComplete: () {
                appStateNotifier.completeChallenge(
                  todaysChallenge.id,
                  todaysChallenge.category.name,
                );
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Capture Photo Card
            _buildCaptureCard(
              hasCaptured: hasCapturedToday,
              onCapture: onCapturePhoto,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Top Recommendation Preview
            _buildRecommendationPreview(ref)
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Info Banner
            _buildInfoBanner()
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),

            const SizedBox(height: AppSpacing.lg),

            // Cultural Disclaimer
            _buildCulturalDisclaimer(ref)
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressScoreCard(AppStateModel appState) {
    final isUnlocked = appState.isProgressUnlocked;
    final score = appState.progressScore ?? 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Progress Score', style: AppTypography.titleSmall),
              const Spacer(),
              if (!isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.lock,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Locked',
                        style: AppTypography.footnote,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          if (isUnlocked) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score.toStringAsFixed(0),
                  style: AppTypography.scoreDisplay,
                ),
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '/ 100',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppProgressBar(
              value: score,
              height: 8,
              color: AppColors.getScoreColor(score),
            ),
          ] else ...[
            Text(
              ScoringEngine.getUnlockStatusMessage(appState),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildUnlockProgress(appState),
          ],
        ],
      ),
    );
  }

  Widget _buildUnlockProgress(AppStateModel appState) {
    final dayProgress = (appState.daysSinceStart / 14).clamp(0.0, 1.0);
    final photoProgress = (appState.timeline.length / 7).clamp(0.0, 1.0);
    final challengeProgress = (appState.challenges.length / 5).clamp(0.0, 1.0);

    return Column(
      children: [
        _buildProgressRow('Days', dayProgress, appState.daysSinceStart, 14),
        const SizedBox(height: AppSpacing.sm),
        _buildProgressRow('Photos', photoProgress, appState.timeline.length, 7),
        const SizedBox(height: AppSpacing.sm),
        _buildProgressRow(
            'Challenges', challengeProgress, appState.challenges.length, 5),
      ],
    );
  }

  Widget _buildProgressRow(
      String label, double progress, int current, int required) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: AppTypography.caption),
        ),
        Expanded(
          child: AppProgressBar(
            value: progress * 100,
            height: 4,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$current/$required',
          style: AppTypography.footnote,
        ),
      ],
    );
  }

  Widget _buildChallengeCard({
    required Challenge challenge,
    required bool isCompleted,
    required VoidCallback onComplete,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  challenge.category.displayName,
                  style: AppTypography.footnote,
                ),
              ),
              const Spacer(),
              if (isCompleted)
                const Icon(
                  LucideIcons.checkCircle,
                  size: 20,
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(challenge.title, style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            challenge.description,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (challenge.tip != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.lightbulb,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      challenge.tip!,
                      style: AppTypography.footnote,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: isCompleted ? 'Completed' : 'Mark Complete',
            variant: isCompleted
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            isFullWidth: true,
            icon: isCompleted ? LucideIcons.check : null,
            onPressed: isCompleted ? null : onComplete,
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureCard({
    required bool hasCaptured,
    required VoidCallback onCapture,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.camera,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Daily Photo', style: AppTypography.titleSmall),
              const Spacer(),
              if (hasCaptured)
                const Icon(
                  LucideIcons.checkCircle,
                  size: 20,
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasCaptured
                ? 'You\'ve captured today\'s photo. Great job staying consistent!'
                : 'Capture your daily photo to track progress over time.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: hasCaptured ? 'Photo Captured' : 'Capture Photo',
            variant: hasCaptured
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            isFullWidth: true,
            icon: hasCaptured ? LucideIcons.check : LucideIcons.camera,
            onPressed: hasCaptured ? null : onCapture,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
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
            size: 20,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Progress score is calculated from consistency, challenge completion, photo quality, and improvement trends.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPreview(WidgetRef ref) {
    final recommendations = ref.watch(recommendationsProvider);
    final settings = ref.watch(settingsProvider);

    if (recommendations.isEmpty) return const SizedBox.shrink();

    // Get the top recommendation with strongest evidence
    final topRec = recommendations.first;
    final exercise = topRec.exercise;

    Color getEvidenceColor(EvidenceStrength strength) {
      switch (strength) {
        case EvidenceStrength.strong:
          return AppColors.success;
        case EvidenceStrength.moderate:
          return AppColors.info;
        case EvidenceStrength.limited:
          return AppColors.warning;
        case EvidenceStrength.none:
          return AppColors.error;
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.sparkles,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Today\'s Top Exercise', style: AppTypography.titleSmall),
              const Spacer(),
              if (settings.showEvidenceLabels)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: getEvidenceColor(exercise.evidenceStrength).withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Text(
                    exercise.evidenceStrength.label,
                    style: AppTypography.caption.copyWith(
                      color: getEvidenceColor(exercise.evidenceStrength),
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                exercise.category.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: AppTypography.bodyMedium),
                    Text(
                      exercise.description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.lightbulb,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    exercise.howToSteps.first,
                    style: AppTypography.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'See Exercises tab for full details and all recommendations',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCulturalDisclaimer(WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    if (!settings.showCulturalDisclaimers) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.globe,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'About Beauty Standards',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Beauty standards vary across cultures and change over time. '
            'The metrics in this app are based on geometric measurements, '
            'not universal standards of attractiveness. Deviation from any '
            '"ideal" ratio does not indicate lesser attractiveness.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
