import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';
import '../../widgets/mental_health/intervention_dialog.dart';
import 'tabs/today_tab.dart';
import 'tabs/timeline_tab.dart';
import 'tabs/baseline_tab.dart';
import 'tabs/exercises_tab.dart';
import 'tabs/profile_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback onCapturePhoto;

  const DashboardScreen({
    super.key,
    required this.onCapturePhoto,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  bool _hasCheckedIntervention = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForIntervention();
  }

  void _checkForIntervention() {
    if (_hasCheckedIntervention) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final intervention = ref.read(currentInterventionProvider);
      if (intervention != null && mounted) {
        _hasCheckedIntervention = true;
        showInterventionDialog(
          context,
          intervention,
          onTakeBreak: () {
            // Navigate to profile or close app
            setState(() => _currentIndex = 4); // Profile tab
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TodayTab(onCapturePhoto: widget.onCapturePhoto),
          const TimelineTab(),
          const BaselineTab(),
          const ExercisesTab(),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: LucideIcons.sun,
                label: 'Today',
              ),
              _buildNavItem(
                index: 1,
                icon: LucideIcons.calendar,
                label: 'Timeline',
              ),
              _buildNavItem(
                index: 2,
                icon: LucideIcons.target,
                label: 'Baseline',
              ),
              _buildNavItem(
                index: 3,
                icon: LucideIcons.dumbbell,
                label: 'Exercises',
              ),
              _buildNavItem(
                index: 4,
                icon: LucideIcons.user,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.footnote.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
