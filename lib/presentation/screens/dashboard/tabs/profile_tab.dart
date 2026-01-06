import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/providers.dart';
import '../../../../data/models/models.dart';
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
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Notifications setting
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

          // Haptics setting
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
          const Divider(height: 1),

          // Reset app
          _buildSettingsTile(
            icon: LucideIcons.trash2,
            title: 'Reset App Data',
            titleColor: AppColors.error,
            onTap: () => _showResetConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
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
              child: Text(
                title,
                style: AppTypography.body.copyWith(
                  color: titleColor ?? AppColors.textPrimary,
                ),
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
