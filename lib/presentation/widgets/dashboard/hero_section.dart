import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/photo_model.dart';
import '../../../providers/photos_provider.dart';

/// Hero section showing weekly photo progress
class HeroSection extends ConsumerWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onViewProgress;

  const HeroSection({
    super.key,
    this.onCapture,
    this.onViewProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestPhotoAsync = ref.watch(latestPhotoProvider);
    final baselineAsync = ref.watch(baselineProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceElevated,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          latestPhotoAsync.when(
            data: (latestPhoto) => _buildContent(
              latestPhoto: latestPhoto,
              baseline: baselineAsync.valueOrNull,
            ),
            loading: () => _buildLoadingState(),
            error: (_, __) => _buildEmptyState(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Progress',
                style: AppTypography.titleSmall,
              ),
              Text(
                'Track your journey',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent({
    required Photo? latestPhoto,
    required Photo? baseline,
  }) {
    if (latestPhoto == null) {
      return _buildEmptyState();
    }

    final daysSinceCapture = DateTime.now().difference(latestPhoto.capturedAt).inDays;
    final daysUntilNext = 7 - daysSinceCapture;
    final symmetryScore = latestPhoto.metrics['facialSymmetry']?.value ?? 0;
    final confidenceScore = latestPhoto.metrics['facialSymmetry']?.confidence ?? 0;

    // Calculate change from baseline
    double? symmetryChange;
    if (baseline != null && baseline.id != latestPhoto.id) {
      final baselineSymmetry = baseline.metrics['facialSymmetry']?.value;
      if (baselineSymmetry != null) {
        symmetryChange = symmetryScore - baselineSymmetry;
      }
    }

    return Row(
      children: [
        // Photo preview
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
            child: latestPhoto.imageData != null
                ? Image.memory(
                    latestPhoto.imageData!,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: AppColors.textTertiary,
                    size: 32,
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symmetry score
              Row(
                children: [
                  Text(
                    symmetryScore.toStringAsFixed(1),
                    style: AppTypography.title.copyWith(fontSize: 28),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '%',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (symmetryChange != null) ...[
                    const SizedBox(width: 8),
                    _buildChangeIndicator(symmetryChange),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Symmetry Score',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Next capture countdown
              Row(
                children: [
                  Icon(
                    daysUntilNext <= 0 ? Icons.camera_alt : Icons.schedule,
                    size: 14,
                    color: daysUntilNext <= 0
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysUntilNext <= 0
                        ? 'Ready for new photo!'
                        : '$daysUntilNext days until next capture',
                    style: AppTypography.footnote.copyWith(
                      color: daysUntilNext <= 0
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChangeIndicator(double change) {
    final isPositive = change > 0;
    final isNeutral = change.abs() < 0.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isNeutral
            ? AppColors.textTertiary.withOpacity(0.1)
            : (isPositive
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isNeutral)
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          Text(
            isNeutral
                ? '='
                : '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}',
            style: AppTypography.footnote.copyWith(
              color: isNeutral
                  ? AppColors.textTertiary
                  : (isPositive ? AppColors.success : AppColors.error),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.textTertiary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start your journey',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take your first photo to establish a baseline and begin tracking progress.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1.seconds, color: AppColors.border),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InkWell(
              onTap: onCapture,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: AppColors.background,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'New Photo',
                      style: AppTypography.body.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Material(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: onViewProgress,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: const Icon(
                Icons.timeline_outlined,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
