import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/providers.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/common_widgets.dart';

class TimelineTab extends ConsumerWidget {
  const TimelineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final timeline = appState.timeline;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: const Text('Timeline', style: AppTypography.display)
                  .animate()
                  .fadeIn(duration: 400.ms),
            ),
          ),

          // Stats cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      label: 'Total Photos',
                      value: timeline.length.toString(),
                      icon: LucideIcons.image,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatsCard(
                      label: 'Days Covered',
                      value: appState.uniqueDaysWithPhotos.toString(),
                      icon: LucideIcons.calendar,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatsCard(
                      label: 'Avg Confidence',
                      value: '${appState.averageConfidence.toStringAsFixed(0)}%',
                      icon: LucideIcons.target,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),

          // Photo grid or empty state
          if (timeline.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildTimelineItem(context, ref, timeline[index], index);
                  },
                  childCount: timeline.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              LucideIcons.image,
              size: 32,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No photos yet',
            style: AppTypography.title.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start capturing daily photos to build your timeline',
            style: AppTypography.body.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    WidgetRef ref,
    TimelineEntry entry,
    int index,
  ) {
    final dateFormat = DateFormat('MMM d');

    return FutureBuilder(
      future: ref.read(databaseServiceProvider).getPhoto(entry.photoId),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            _showPhotoDetail(context, entry, snapshot.data);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo or placeholder
              if (snapshot.hasData && snapshot.data != null)
                Image.memory(
                  snapshot.data!.imageData,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(
                      LucideIcons.image,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

              // Date overlay
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.8),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Text(
                    dateFormat.format(entry.date),
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Confidence indicator
              Positioned(
                right: 4,
                top: 4,
                child: ConfidenceDot(confidence: entry.confidence),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (50 * (index % 9)).ms);
      },
    );
  }

  void _showPhotoDetail(
    BuildContext context,
    TimelineEntry entry,
    PhotoModel? photo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _PhotoDetailSheet(
              entry: entry,
              photo: photo,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}

class _PhotoDetailSheet extends StatelessWidget {
  final TimelineEntry entry;
  final PhotoModel? photo;
  final ScrollController scrollController;

  const _PhotoDetailSheet({
    required this.entry,
    this.photo,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Date header
        Text(
          dateFormat.format(entry.date),
          style: AppTypography.headline,
        ),
        Text(
          timeFormat.format(entry.date),
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Photo
        if (photo != null)
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusLg,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.memory(
                photo!.imageData,
                fit: BoxFit.cover,
              ),
            ),
          ),

        const SizedBox(height: AppSpacing.lg),

        // Confidence
        Row(
          children: [
            const Text('Confidence', style: AppTypography.bodyMedium),
            const Spacer(),
            ConfidenceBand(confidence: entry.confidence, width: 80),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${entry.confidence.toStringAsFixed(0)}%',
              style: AppTypography.body,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Metrics section
        const Text('Metrics', style: AppTypography.titleSmall),
        const SizedBox(height: AppSpacing.md),

        ...entry.metrics.entries.map((metricEntry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    metricEntry.key,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  metricEntry.value.value.toStringAsFixed(1),
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
