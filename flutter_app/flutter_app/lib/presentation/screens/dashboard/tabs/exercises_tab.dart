import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/providers.dart';
import '../../../../data/models/models.dart';
import '../../../../engine/engine.dart';
import '../../../widgets/common/common_widgets.dart';

class ExercisesTab extends ConsumerWidget {
  const ExercisesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(recommendationsProvider);
    final settings = ref.watch(settingsProvider);
    final userAge = ref.watch(userAgeProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Exercises', style: AppTypography.display)
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Evidence-based recommendations for improvement',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: AppSpacing.lg),

                  // Medical disclaimer
                  _buildDisclaimer(userAge)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Evidence legend
                  if (settings.showEvidenceLabels)
                    _buildEvidenceLegend()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms),
                ],
              ),
            ),
          ),

          // Recommendations list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recommendation = recommendations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ExerciseCard(
                      recommendation: recommendation,
                      showEvidence: settings.showEvidenceLabels,
                      showCitations: settings.showScientificCitations,
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 400 + (index * 100)),
                        )
                        .slideY(begin: 0.1, end: 0),
                  );
                },
                childCount: recommendations.length,
              ),
            ),
          ),

          // Banned practices warning
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildBannedPracticesWarning()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 800.ms),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(int? userAge) {
    final isTeenager = userAge != null && userAge < 18;
    final disclaimerText = isTeenager
        ? MentalHealthRepository.teenDisclaimer
        : MentalHealthRepository.generalDisclaimer;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.alertTriangle,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              disclaimerText,
              style: AppTypography.caption.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceLegend() {
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
            'Evidence Levels',
            style: AppTypography.footnote.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLegendItem(
            '\u2713',
            'Strong Evidence',
            'Multiple studies confirm',
            AppColors.success,
          ),
          _buildLegendItem(
            '\u2248',
            'Moderate Evidence',
            'Some studies support',
            AppColors.info,
          ),
          _buildLegendItem(
            '\u26A0',
            'Limited Evidence',
            'Theory or mixed results',
            AppColors.warning,
          ),
          _buildLegendItem(
            '\u2717',
            'No Evidence',
            'Pseudoscience or unproven',
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String icon,
    String label,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Text(
              icon,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.footnote),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannedPracticesWarning() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.shieldAlert,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Dangerous Practices - NEVER Try',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...BannedPractices.bannedList.take(3).map((practice) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '\u2717 ',
                      style: TextStyle(color: AppColors.error),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            practice['name']!,
                            style: AppTypography.footnote.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            practice['reason']!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'These practices have NO scientific evidence and risk serious injury.',
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final Recommendation recommendation;
  final bool showEvidence;
  final bool showCitations;

  const _ExerciseCard({
    required this.recommendation,
    required this.showEvidence,
    required this.showCitations,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _isExpanded = false;

  Color _getEvidenceColor(EvidenceStrength strength) {
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

  String _getEvidenceIcon(EvidenceStrength strength) {
    switch (strength) {
      case EvidenceStrength.strong:
        return '\u2713';
      case EvidenceStrength.moderate:
        return '\u2248';
      case EvidenceStrength.limited:
        return '\u26A0';
      case EvidenceStrength.none:
        return '\u2717';
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.recommendation.exercise;
    final evidenceColor = _getEvidenceColor(exercise.evidenceStrength);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category and evidence badge
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      exercise.category.icon,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exercise.category.displayName,
                      style: AppTypography.footnote,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (widget.showEvidence)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: evidenceColor.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getEvidenceIcon(exercise.evidenceStrength),
                        style: TextStyle(color: evidenceColor, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exercise.evidenceStrength.label,
                        style: AppTypography.footnote.copyWith(
                          color: evidenceColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Exercise name
          Text(exercise.name, style: AppTypography.titleSmall),

          const SizedBox(height: AppSpacing.xs),

          // Personalized message
          Text(
            widget.recommendation.personalizedMessage,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Expand/collapse button
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? 'Show less' : 'How to do it',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.md),

            // Theory
            Text(
              'Theory',
              style: AppTypography.footnote.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(exercise.theory, style: AppTypography.caption),

            const SizedBox(height: AppSpacing.md),

            // Honest assessment
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: evidenceColor.withOpacity(0.05),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: evidenceColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Honest Assessment',
                    style: AppTypography.footnote.copyWith(
                      fontWeight: FontWeight.w600,
                      color: evidenceColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    exercise.honestAssessment,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // How-to steps
            Text(
              'How To',
              style: AppTypography.footnote.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...exercise.howToSteps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: AppSpacing.borderRadiusFull,
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppTypography.caption,
                        ),
                      ),
                    ],
                  ),
                )),

            // Frequency and duration
            if (exercise.frequency != null || exercise.duration != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (exercise.frequency != null)
                    Expanded(
                      child: _buildInfoChip(
                        LucideIcons.repeat,
                        exercise.frequency!,
                      ),
                    ),
                  if (exercise.frequency != null && exercise.duration != null)
                    const SizedBox(width: AppSpacing.sm),
                  if (exercise.duration != null)
                    Expanded(
                      child: _buildInfoChip(
                        LucideIcons.clock,
                        exercise.duration!,
                      ),
                    ),
                ],
              ),
            ],

            // Warnings
            if (exercise.warnings.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Important',
                          style: AppTypography.footnote.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...exercise.warnings.map((warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '- $warning',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],

            // Citations
            if (widget.showCitations && exercise.citations.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Scientific References',
                style: AppTypography.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...exercise.citations.map((citation) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            citation.formattedCitation,
                            style: AppTypography.caption.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            citation.summary,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: AppTypography.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
