import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/usage_tracking_model.dart';
import '../../../providers/usage_tracking_provider.dart';

/// Mental health intervention dialog
class InterventionDialog extends ConsumerWidget {
  final Intervention intervention;
  final VoidCallback? onDismiss;

  const InterventionDialog({
    super.key,
    required this.intervention,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessage(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSuggestions(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildResources(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildActions(context, ref),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            duration: 200.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  Widget _buildHeader() {
    final color = _getAlertColor(intervention.triggerType);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAlertIcon(intervention.triggerType),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mindful Moment',
                  style: AppTypography.titleSmall.copyWith(color: color),
                ),
                Text(
                  _getAlertSubtitle(intervention.triggerType),
                  style: AppTypography.caption.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      _getInterventionMessage(intervention.triggerType),
      style: AppTypography.body.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = _getSuggestions(intervention.triggerType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try this instead:',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '\u2022 ',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildResources() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_outlined,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: 6),
              Text(
                'Need support?',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...CrisisResource.defaultResources.take(2).map((resource) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: GestureDetector(
                  onTap: () => _openResource(resource),
                  child: Row(
                    children: [
                      Text(
                        resource.name,
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.info,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (resource.phone != null)
                        Text(
                          '(${resource.phone})',
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InkWell(
              onTap: () {
                ref.read(usageTrackingNotifierProvider.notifier).acknowledgeIntervention(
                      InterventionResponse.dismissed,
                    );
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                alignment: Alignment.center,
                child: Text(
                  'Continue',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Material(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InkWell(
              onTap: () {
                ref.read(usageTrackingNotifierProvider.notifier).acknowledgeIntervention(
                      InterventionResponse.breakTaken,
                    );
                Navigator.of(context).pop();
                onDismiss?.call();
                // Could navigate to a break screen or minimize app
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                alignment: Alignment.center,
                child: Text(
                  'Take a Break',
                  style: AppTypography.body.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getAlertColor(UsageAlertType type) {
    switch (type) {
      case UsageAlertType.lateNight:
        return AppColors.info;
      case UsageAlertType.consecutiveDays:
        return AppColors.warning;
      case UsageAlertType.rapidAnalysis:
      case UsageAlertType.excessiveWeekly:
        return AppColors.error;
      case UsageAlertType.frequentUsage:
      default:
        return AppColors.warning;
    }
  }

  IconData _getAlertIcon(UsageAlertType type) {
    switch (type) {
      case UsageAlertType.lateNight:
        return Icons.nightlight_round;
      case UsageAlertType.consecutiveDays:
        return Icons.calendar_today;
      case UsageAlertType.rapidAnalysis:
        return Icons.speed;
      case UsageAlertType.excessiveWeekly:
        return Icons.warning_amber_rounded;
      case UsageAlertType.frequentUsage:
      default:
        return Icons.timer_outlined;
    }
  }

  String _getAlertSubtitle(UsageAlertType type) {
    switch (type) {
      case UsageAlertType.lateNight:
        return 'Late night check-in';
      case UsageAlertType.consecutiveDays:
        return 'Daily usage pattern';
      case UsageAlertType.rapidAnalysis:
        return 'Frequent analysis';
      case UsageAlertType.excessiveWeekly:
        return 'Weekly usage notice';
      case UsageAlertType.frequentUsage:
      default:
        return 'Usage reminder';
    }
  }

  String _getInterventionMessage(UsageAlertType type) {
    switch (type) {
      case UsageAlertType.lateNight:
        return 'It\'s getting late! Your appearance looks best after proper rest. Consider putting down your phone and getting some quality sleep.';
      case UsageAlertType.consecutiveDays:
        return 'You\'ve been using the app every day. While consistency is good, remember that real progress takes time. Daily checking won\'t speed up results.';
      case UsageAlertType.rapidAnalysis:
        return 'Taking multiple photos in quick succession won\'t give better results. Facial analysis works best with weekly photos taken in consistent conditions.';
      case UsageAlertType.excessiveWeekly:
        return 'You\'ve spent significant time in the app this week. Remember, your worth isn\'t defined by metrics. Take some time to appreciate yourself as you are.';
      case UsageAlertType.frequentUsage:
      default:
        return 'You\'ve been using the app for a while. It\'s a good time to take a break and focus on something else.';
    }
  }

  List<String> _getSuggestions(UsageAlertType type) {
    switch (type) {
      case UsageAlertType.lateNight:
        return [
          'Put your phone away 30 minutes before bed',
          'Practice a relaxing bedtime routine',
          'Read a book or listen to calming music',
        ];
      case UsageAlertType.consecutiveDays:
        return [
          'Set a weekly photo schedule instead of daily',
          'Focus on habits rather than constant measurement',
          'Trust the process - changes take weeks to notice',
        ];
      case UsageAlertType.rapidAnalysis:
        return [
          'Take one photo per session maximum',
          'Wait at least a week between progress photos',
          'Focus on the quality of each photo, not quantity',
        ];
      case UsageAlertType.excessiveWeekly:
        return [
          'Set app time limits in your phone settings',
          'Practice self-affirmation exercises',
          'Connect with friends or family instead',
        ];
      case UsageAlertType.frequentUsage:
      default:
        return [
          'Step away from screens for 15 minutes',
          'Go for a walk or do some stretching',
          'Drink some water and take deep breaths',
        ];
    }
  }

  Future<void> _openResource(CrisisResource resource) async {
    if (resource.phone != null) {
      final uri = Uri.parse('tel:${resource.phone}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else if (resource.url != null) {
      final uri = Uri.parse(resource.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

/// Shows the intervention dialog
Future<void> showInterventionDialog(
  BuildContext context,
  Intervention intervention, {
  VoidCallback? onDismiss,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => InterventionDialog(
      intervention: intervention,
      onDismiss: onDismiss,
    ),
  );
}

/// Mindful reminder banner (less intrusive)
class MindfulReminderBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const MindfulReminderBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.textTertiary,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
