import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chewing_model.dart';
import '../../../providers/chewing_provider.dart';

/// Chewing timer with controls
class ChewingTimer extends ConsumerWidget {
  final bool compact;
  final VoidCallback? onTap;

  const ChewingTimer({
    super.key,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chewingNotifierProvider);
    final isRunning = state.isRunning;
    final isPaused = state.isPaused;
    final elapsedSeconds = state.elapsedSeconds;
    final targetMinutes = state.targetMinutes;

    final progress = elapsedSeconds / (targetMinutes * 60);
    final remainingSeconds = (targetMinutes * 60) - elapsedSeconds;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimerCircle(
            progress: progress.clamp(0, 1),
            remainingSeconds: remainingSeconds,
            isRunning: isRunning,
            isPaused: isPaused,
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildControls(ref, isRunning, isPaused),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerCircle({
    required double progress,
    required int remainingSeconds,
    required bool isRunning,
    required bool isPaused,
  }) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return SizedBox(
      width: compact ? 80 : 140,
      height: compact ? 80 : 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: compact ? 6 : 10,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(AppColors.surfaceElevated),
            ),
          ),
          // Progress circle
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: compact ? 6 : 10,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(
                  _getTimerColor(progress, isRunning, isPaused),
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeString,
                style: compact
                    ? AppTypography.body.copyWith(fontWeight: FontWeight.w600)
                    : AppTypography.title.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
              ),
              if (!compact)
                Text(
                  isRunning
                      ? (isPaused ? 'Paused' : 'Chewing')
                      : 'Ready',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
          // Pulsing animation when running
          if (isRunning && !isPaused)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  )
                  .fadeOut(
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls(WidgetRef ref, bool isRunning, bool isPaused) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isRunning) ...[
          _TimerButton(
            icon: Icons.play_arrow_rounded,
            label: 'Start',
            onTap: () => ref.read(chewingNotifierProvider.notifier).startSession(),
            isPrimary: true,
          ),
        ] else ...[
          if (isPaused) ...[
            _TimerButton(
              icon: Icons.play_arrow_rounded,
              label: 'Resume',
              onTap: () => ref.read(chewingNotifierProvider.notifier).resumeSession(),
              isPrimary: true,
            ),
            const SizedBox(width: AppSpacing.md),
            _TimerButton(
              icon: Icons.stop_rounded,
              label: 'Stop',
              onTap: () => ref.read(chewingNotifierProvider.notifier).cancelSession(),
              isPrimary: false,
            ),
          ] else ...[
            _TimerButton(
              icon: Icons.pause_rounded,
              label: 'Pause',
              onTap: () => ref.read(chewingNotifierProvider.notifier).pauseSession(),
              isPrimary: false,
            ),
            const SizedBox(width: AppSpacing.md),
            _TimerButton(
              icon: Icons.check_rounded,
              label: 'Done',
              onTap: () => ref.read(chewingNotifierProvider.notifier).completeSession(),
              isPrimary: true,
            ),
          ],
        ],
      ],
    );
  }

  Color _getTimerColor(double progress, bool isRunning, bool isPaused) {
    if (!isRunning) return AppColors.textTertiary;
    if (isPaused) return AppColors.warning;
    if (progress >= 1) return AppColors.success;
    return AppColors.info;
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.textPrimary : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? AppColors.background : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.body.copyWith(
                  color: isPrimary ? AppColors.background : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact chewing card for dashboard grid
class ChewingCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const ChewingCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chewingNotifierProvider);
    final todayStats = ref.watch(todayChewingStatsProvider);
    final isRunning = state.isRunning;
    final isPaused = state.isPaused;

    final elapsedMinutes = state.elapsedSeconds ~/ 60;
    final targetMinutes = todayStats?.targetMinutes ?? 20;
    final completedMinutes = todayStats?.totalMinutes ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: isRunning ? AppColors.info : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Chewing',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (completedMinutes >= targetMinutes)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (isRunning)
              Text(
                _formatTime(state.elapsedSeconds),
                style: AppTypography.title.copyWith(
                  color: isPaused ? AppColors.warning : AppColors.info,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              )
            else
              Text(
                '$completedMinutes min',
                style: AppTypography.title,
              ),
            const SizedBox(height: 2),
            Text(
              isRunning
                  ? (isPaused ? 'Paused' : 'In progress...')
                  : 'of $targetMinutes min today',
              style: AppTypography.footnote.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ((completedMinutes + elapsedMinutes) / targetMinutes).clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: isRunning ? AppColors.info : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Control button
            SizedBox(
              width: double.infinity,
              child: Material(
                color: isRunning
                    ? (isPaused ? AppColors.info : AppColors.surfaceElevated)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: InkWell(
                  onTap: () {
                    final notifier = ref.read(chewingNotifierProvider.notifier);
                    if (!isRunning) {
                      notifier.startSession();
                    } else if (isPaused) {
                      notifier.resumeSession();
                    } else {
                      notifier.pauseSession();
                    }
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRunning
                              ? (isPaused ? Icons.play_arrow : Icons.pause)
                              : Icons.play_arrow,
                          size: 16,
                          color: isRunning && isPaused
                              ? AppColors.background
                              : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isRunning
                              ? (isPaused ? 'Resume' : 'Pause')
                              : 'Start',
                          style: AppTypography.footnote.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isRunning && isPaused
                                ? AppColors.background
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
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

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// TMJ Warning banner
class TMJWarningBanner extends StatelessWidget {
  final int todayMinutes;
  final int warningThreshold;
  final VoidCallback? onDismiss;

  const TMJWarningBanner({
    super.key,
    required this.todayMinutes,
    this.warningThreshold = 60,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TMJ Health Notice',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You\'ve chewed for $todayMinutes minutes today. Consider taking a break to protect your jaw.',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
