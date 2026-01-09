import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'core/theme/app_theme.dart';
import 'data/models/models.dart';
import 'data/services/services.dart';
import 'engine/engine.dart';
import 'providers/providers.dart';
import 'providers/hydration_provider.dart';
import 'providers/mewing_provider.dart';
import 'providers/chewing_provider.dart';
import 'providers/usage_tracking_provider.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/onboarding/capture_rules_screen.dart';
import 'presentation/screens/onboarding/hydration_setup_screen.dart';
import 'presentation/screens/camera/camera_screen.dart';
import 'presentation/screens/analysis/report_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

/// App screen states
enum AppScreen {
  loading,
  welcome,
  captureRules,
  camera,
  analyzing,
  report,
  hydrationSetup,
  dashboard,
}

class LooksmaxxerApp extends ConsumerStatefulWidget {
  const LooksmaxxerApp({super.key});

  @override
  ConsumerState<LooksmaxxerApp> createState() => _LooksmaxxerAppState();
}

class _LooksmaxxerAppState extends ConsumerState<LooksmaxxerApp> {
  AppScreen _currentScreen = AppScreen.loading;
  Map<String, MetricValue>? _analysisResults;
  bool _isOnboardingCapture = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load app state
    await ref.read(appStateProvider.notifier).initialize();

    // Initialize habit providers
    await ref.read(hydrationNotifierProvider.notifier).initialize();
    await ref.read(mewingNotifierProvider.notifier).initialize();
    await ref.read(chewingNotifierProvider.notifier).initialize();
    await ref.read(usageTrackingNotifierProvider.notifier).initialize();

    // Start usage tracking session
    ref.read(usageTrackingNotifierProvider.notifier).startSession('app');

    // Determine initial screen
    final hasCompletedOnboarding =
        ref.read(appStateProvider).hasCompletedOnboarding;

    setState(() {
      _currentScreen =
          hasCompletedOnboarding ? AppScreen.dashboard : AppScreen.welcome;
    });
  }

  void _navigateTo(AppScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  Future<void> _handlePhotoCapture({bool isOnboarding = false}) async {
    _isOnboardingCapture = isOnboarding;

    // Get captured image from camera provider
    final cameraState = ref.read(cameraProvider);
    final capturedImage = cameraState.capturedImage;
    final qualityScore = cameraState.qualityScore;
    final metadata = ref.read(cameraProvider.notifier).getPhotoMetadata();

    if (capturedImage == null || qualityScore == null || metadata == null) {
      return;
    }

    // Navigate to analyzing state
    setState(() {
      _currentScreen = AppScreen.analyzing;
    });

    // Analyze the photo
    final analysisResults = await AnalysisEngine.analyzePhoto(capturedImage);

    // Save photo to database
    final photoId = const Uuid().v4();
    final photo = PhotoModel(
      id: photoId,
      imageData: capturedImage,
      capturedAt: DateTime.now(),
      metadata: metadata,
      qualityScore: qualityScore,
      analysisResults: analysisResults,
    );

    await ref.read(databaseServiceProvider).savePhoto(photo);

    // Calculate average confidence
    final avgConfidence = analysisResults.values
            .map((m) => m.confidence)
            .reduce((a, b) => a + b) /
        analysisResults.length;

    // Create timeline entry
    final timelineEntry = TimelineEntry(
      photoId: photoId,
      date: DateTime.now(),
      confidence: avgConfidence,
      metrics: analysisResults,
    );

    // Update app state
    final appStateNotifier = ref.read(appStateProvider.notifier);
    await appStateNotifier.addTimelineEntry(timelineEntry);

    if (isOnboarding) {
      // Set as baseline
      await appStateNotifier.setBaseline(photoId, analysisResults);
    } else {
      // Update metrics
      await appStateNotifier.updateMetrics(analysisResults);
      await appStateNotifier.updateProgressScore();
    }

    // Store results and navigate
    _analysisResults = analysisResults;

    setState(() {
      _currentScreen = AppScreen.report;
    });

    // Clear camera state
    ref.read(cameraProvider.notifier).clearCapture();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(appStateProvider.notifier).completeOnboarding();

    // Show hydration setup if not already completed
    final hasCompletedHydrationSetup =
        ref.read(appStateProvider).hasCompletedHydrationSetup;

    if (!hasCompletedHydrationSetup) {
      _navigateTo(AppScreen.hydrationSetup);
    } else {
      _navigateTo(AppScreen.dashboard);
    }
  }

  Future<void> _completeHydrationSetup() async {
    await ref.read(appStateProvider.notifier).completeHydrationSetup();
    _navigateTo(AppScreen.dashboard);
  }

  void _skipHydrationSetup() {
    ref.read(appStateProvider.notifier).completeHydrationSetup();
    _navigateTo(AppScreen.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Looksmaxxer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AppScreen.loading:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.textPrimary,
            ),
          ),
        );

      case AppScreen.welcome:
        return WelcomeScreen(
          onContinue: () => _navigateTo(AppScreen.captureRules),
        );

      case AppScreen.captureRules:
        return CaptureRulesScreen(
          onContinue: () {
            _isOnboardingCapture = true;
            _navigateTo(AppScreen.camera);
          },
          onBack: () => _navigateTo(AppScreen.welcome),
        );

      case AppScreen.camera:
        return CameraScreen(
          onCapture: () => _handlePhotoCapture(isOnboarding: _isOnboardingCapture),
          onCancel: () {
            ref.read(cameraProvider.notifier).clearCapture();
            _navigateTo(
              _isOnboardingCapture ? AppScreen.captureRules : AppScreen.dashboard,
            );
          },
        );

      case AppScreen.analyzing:
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Analyzing...',
                  style: AppTypography.title.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This may take a moment',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        );

      case AppScreen.report:
        return ReportScreen(
          metrics: _analysisResults ?? {},
          onContinue: () {
            if (_isOnboardingCapture) {
              _completeOnboarding();
            } else {
              _navigateTo(AppScreen.dashboard);
            }
          },
        );

      case AppScreen.hydrationSetup:
        return HydrationSetupScreen(
          onComplete: _completeHydrationSetup,
          onSkip: _skipHydrationSetup,
        );

      case AppScreen.dashboard:
        return DashboardScreen(
          onCapturePhoto: () {
            _isOnboardingCapture = false;
            _navigateTo(AppScreen.camera);
          },
        );
    }
  }
}
