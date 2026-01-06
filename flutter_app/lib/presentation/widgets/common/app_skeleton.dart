import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Skeleton loading placeholder
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  /// Creates a text line skeleton
  factory AppSkeleton.text({
    double width = 100,
    double height = 16,
  }) {
    return AppSkeleton(
      width: width,
      height: height,
      borderRadius: AppSpacing.borderRadiusSm,
    );
  }

  /// Creates a circular skeleton (for avatars, icons)
  factory AppSkeleton.circle({
    double size = 40,
  }) {
    return AppSkeleton(
      width: size,
      height: size,
      isCircle: true,
    );
  }

  /// Creates a card skeleton
  factory AppSkeleton.card({
    double? width,
    double height = 100,
  }) {
    return AppSkeleton(
      width: width,
      height: height,
      borderRadius: AppSpacing.borderRadiusLg,
    );
  }

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withOpacity(_animation.value),
            borderRadius: widget.isCircle
                ? null
                : (widget.borderRadius ?? AppSpacing.borderRadiusSm),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        );
      },
    );
  }
}

/// Skeleton for a metric card
class MetricCardSkeleton extends StatelessWidget {
  const MetricCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSkeleton.text(width: 120, height: 20),
              const Spacer(),
              AppSkeleton.text(width: 40, height: 20),
            ],
          ),
          const SizedBox(height: 12),
          AppSkeleton.text(width: double.infinity, height: 8),
          const SizedBox(height: 8),
          AppSkeleton.text(width: 200, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton for the photo grid
class PhotoGridSkeleton extends StatelessWidget {
  final int count;
  final int crossAxisCount;

  const PhotoGridSkeleton({
    super.key,
    this.count = 6,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return const AppSkeleton(
          borderRadius: BorderRadius.zero,
        );
      },
    );
  }
}
