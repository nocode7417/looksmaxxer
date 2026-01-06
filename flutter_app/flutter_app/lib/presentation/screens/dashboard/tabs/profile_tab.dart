import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/common/common_widgets.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text('Profile', style: AppTypography.display)
                .animate()
                .fadeIn(duration: 400.ms),

            const SizedBox(height: AppSpacing.xxl),

            // Stats grid
            _buildStatsGrid(appState)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            // About section
            _buildAboutSection()
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Settings section
            _buildSettingsSection(context, ref, appState)
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // Version info
            Center(
              child: Text(
                'Looksmaxxer v${AppConstants.appVersion}',
                style: AppTypography.footnote,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AppStateModel appState) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        StatsCard(
          label: 'Days Tracking',
          value: appState.daysSinceStart.toString(),
          icon: LucideIcons.calendar,
        ),
        StatsCard(
          label: 'Total Photos',
          value: appState.timeline.length.toString(),
          icon: LucideIcons.image,
        ),
        StatsCard(
          label: 'Current Streak',
          value: appState.challengeStreak.toString(),
          icon: LucideIcons.flame,
          valueColor: appState.challengeStreak > 0
              ? AppColors.warning
              : null,
        ),
        StatsCard(
          label: 'Challenges Done',
          value: appState.challenges.length.toString(),
          icon: LucideIcons.checkCircle,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return AppSectionCard(
      title: 'About Looksmaxxer',
      child: Text(
        AppConstants.appDescription,
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    AppStateModel appState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // General Settings
        Text(
          'General',
          style: AppTypography.footnote.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: LucideIcons.bell,
                title: 'Notifications',
                trailing: Switch(
                  value: appState.settings.notifications,
                  onChanged: (value) {
                    ref.read(appStateProvider.notifier).updateSettings(
                          appState.settings.copyWith(notifications: value),
                        );
                  },
                  activeColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.surfaceElevated,
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: LucideIcons.vibrate,
                title: 'Haptic Feedback',
                trailing: Switch(
                  value: appState.settings.haptics,
                  onChanged: (value) {
                    ref.read(appStateProvider.notifier).updateSettings(
                          appState.settings.copyWith(haptics: value),
                        );
                  },
                  activeColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.surfaceElevated,
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Science & Evidence Settings
        Text(
          'Science & Evidence',
          style: AppTypography.footnote.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: LucideIcons.flaskConical,
                title: 'Show Evidence Labels',
                subtitle: 'Display scientific evidence strength',
                trailing: Switch(
                  value: appState.settings.showEvidenceLabels,
                  onChanged: (value) {
                    ref.read(appStateProvider.notifier).toggleEvidenceLabels(value);
                  },
                  activeColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.surfaceElevated,
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: LucideIcons.quote,
                title: 'Show Scientific Citations',
                subtitle: 'Include research paper references',
                trailing: Switch(
                  value: appState.settings.showScientificCitations,
                  onChanged: (value) {
                    ref.read(appStateProvider.notifier).updateSettings(
                          appState.settings.copyWith(showScientificCitations: value),
                        );
                  },
                  activeColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.surfaceElevated,
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: LucideIcons.globe,
                title: 'Cultural Disclaimers',
                subtitle: 'Show beauty standard context',
                trailing: Switch(
                  value: appState.settings.showCulturalDisclaimers,
                  onChanged: (value) {
                    ref.read(appStateProvider.notifier).toggleCulturalDisclaimers(value);
                  },
                  activeColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.surfaceElevated,
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Wellness & Safety Settings
        Text(
          'Wellness & Safety',
          style: AppTypography.footnote.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: LucideIcons.heart,
                title: 'Mental Health Reminders',
                subtitle: 'Show wellness check-ins when needed',
                trailing: Switch(
                  value: appState.settings.showMentalHealthReminders,
                  onChanged: (value) {
                    ref.read(appStateProvider.notifier).toggleMentalHealthReminders(value);
                  },
                  activeColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.surfaceElevated,
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: LucideIcons.leaf,
                title: 'Wellness Mode',
                subtitle: 'Reduced analysis frequency, gentler messaging',
                trailing: Switch(
                  value: appState.settings.wellnessMode,
                  onChanged: (value) {
                    ref.read(appStateProvider.notifier).toggleWellnessMode(value);
                  },
                  activeColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.surfaceElevated,
                  inactiveThumbColor: AppColors.textTertiary,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: LucideIcons.phone,
                title: 'Crisis Resources',
                subtitle: 'Mental health support contacts',
                onTap: () => _showCrisisResources(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Usage Stats
        _buildUsageStats(appState),

        const SizedBox(height: AppSpacing.lg),

        // Data Settings
        Text(
          'Data',
          style: AppTypography.footnote.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: _buildSettingsTile(
            icon: LucideIcons.trash2,
            title: 'Reset App Data',
            titleColor: AppColors.error,
            onTap: () => _showResetConfirmation(context, ref),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageStats(AppStateModel appState) {
    final tracker = appState.usageTracker;

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
          Row(
            children: [
              const Icon(
                LucideIcons.activity,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Usage This Week',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildUsageStat(
                  'Today',
                  tracker.todayAnalysesCount.toString(),
                  tracker.todayAnalysesCount > 5 ? AppColors.warning : null,
                ),
              ),
              Expanded(
                child: _buildUsageStat(
                  'This Week',
                  tracker.weeklyAnalysesCount.toString(),
                  tracker.weeklyAnalysesCount > 20 ? AppColors.warning : null,
                ),
              ),
              Expanded(
                child: _buildUsageStat(
                  'Day Streak',
                  tracker.consecutiveDays.toString(),
                  tracker.consecutiveDays > 7 ? AppColors.info : null,
                ),
              ),
            ],
          ),
          if (tracker.activeFlags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Consider taking a break if you notice yourself checking often.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageStat(String label, String value, Color? color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: color ?? AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  void _showCrisisResources(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.heart,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Mental Health Resources',
                      style: AppTypography.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'If you\'re struggling with how you feel about your appearance, '
                  'these resources can help:',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildResourceItem(
                  'Crisis Text Line',
                  'Text HOME to 741741',
                  LucideIcons.messageSquare,
                ),
                _buildResourceItem(
                  'Teen Line',
                  'Text TEEN to 839863',
                  LucideIcons.phone,
                ),
                _buildResourceItem(
                  '988 Lifeline',
                  'Call or text 988',
                  LucideIcons.phoneCall,
                ),
                _buildResourceItem(
                  'BDD Foundation',
                  'bddfoundation.org',
                  LucideIcons.globe,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResourceItem(String name, String contact, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.info),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.bodyMedium),
                  Text(
                    contact,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: titleColor ?? AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Reset App Data'),
          content: const Text(
            'This will delete all your photos, metrics, and progress. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(appStateProvider.notifier).resetAllData();
                Navigator.pop(context);
              },
              child: Text(
                'Reset',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
