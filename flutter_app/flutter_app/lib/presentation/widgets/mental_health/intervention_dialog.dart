import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';
import '../common/common_widgets.dart';

/// Mental health intervention dialog
class InterventionDialog extends ConsumerWidget {
  final MentalHealthIntervention intervention;
  final VoidCallback? onDismiss;
  final VoidCallback? onTakeBreak;

  const InterventionDialog({
    super.key,
    required this.intervention,
    this.onDismiss,
    this.onTakeBreak,
  });

  Color _getSeverityColor(InterventionSeverity severity) {
    switch (severity) {
      case InterventionSeverity.gentle:
        return AppColors.info;
      case InterventionSeverity.moderate:
        return AppColors.warning;
      case InterventionSeverity.serious:
        return AppColors.error;
    }
  }

  IconData _getSeverityIcon(InterventionSeverity severity) {
    switch (severity) {
      case InterventionSeverity.gentle:
        return LucideIcons.info;
      case InterventionSeverity.moderate:
        return LucideIcons.alertCircle;
      case InterventionSeverity.serious:
        return LucideIcons.heart;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getSeverityColor(intervention.severity);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Icon(
                      _getSeverityIcon(intervention.severity),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      intervention.title,
                      style: AppTypography.titleMedium,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: AppSpacing.lg),

              // Message
              Text(
                intervention.message,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: AppSpacing.lg),

              // Key points
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remember:',
                      style: AppTypography.footnote.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...intervention.keyPoints.map((point) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\u2022 ',
                                style: TextStyle(color: color),
                              ),
                              Expanded(
                                child: Text(
                                  point,
                                  style: AppTypography.caption,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

              // Crisis resources (for serious interventions)
              if (intervention.crisisResources != null &&
                  intervention.crisisResources!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildCrisisResources(intervention.crisisResources!)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              Column(
                children: [
                  AppButton(
                    label: 'Take a Break',
                    variant: AppButtonVariant.primary,
                    isFullWidth: true,
                    icon: LucideIcons.coffee,
                    onPressed: () {
                      ref.read(appStateProvider.notifier).markInterventionShown();
                      onTakeBreak?.call();
                      Navigator.of(context).pop(true);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Continue Anyway',
                    variant: AppButtonVariant.ghost,
                    isFullWidth: true,
                    onPressed: () {
                      ref.read(appStateProvider.notifier).dismissIntervention();
                      onDismiss?.call();
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrisisResources(List<CrisisResource> resources) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.phone,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Resources That Can Help',
                style: AppTypography.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...resources.take(3).map((resource) => _CrisisResourceItem(
                resource: resource,
              )),
        ],
      ),
    );
  }
}

class _CrisisResourceItem extends StatelessWidget {
  final CrisisResource resource;

  const _CrisisResourceItem({required this.resource});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource.name,
              style: AppTypography.footnote.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              resource.description,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                if (resource.phoneNumber != null)
                  GestureDetector(
                    onTap: () => _launchPhone(resource.phoneNumber!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.phone,
                            size: 10,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            resource.phoneNumber!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (resource.textLine != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.messageSquare,
                          size: 10,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resource.textLine!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.info,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (resource.website != null)
                  GestureDetector(
                    onTap: () => _launchUrl(resource.website!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withOpacity(0.1),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.globe,
                            size: 10,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Website',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Show intervention dialog helper
Future<bool?> showInterventionDialog(
  BuildContext context,
  MentalHealthIntervention intervention, {
  VoidCallback? onDismiss,
  VoidCallback? onTakeBreak,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => InterventionDialog(
      intervention: intervention,
      onDismiss: onDismiss,
      onTakeBreak: onTakeBreak,
    ),
  );
}

/// Wrapper widget that checks for interventions
class InterventionCheckWrapper extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTakeBreak;

  const InterventionCheckWrapper({
    super.key,
    required this.child,
    this.onTakeBreak,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervention = ref.watch(currentInterventionProvider);

    // Show intervention dialog if needed
    if (intervention != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showInterventionDialog(
          context,
          intervention,
          onTakeBreak: onTakeBreak,
        );
      });
    }

    return child;
  }
}
