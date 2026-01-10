import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/geometry_metrics_model.dart';
import '../data/services/database_service.dart';
import 'app_state_provider.dart';

/// State for geometry metrics analysis
class GeometryMetricsState {
  final List<GeometryAnalysisResult> analyses;
  final bool isLoading;
  final String? error;
  final GeometryAnalysisResult? latestAnalysis;

  const GeometryMetricsState({
    this.analyses = const [],
    this.isLoading = false,
    this.error,
    this.latestAnalysis,
  });

  GeometryMetricsState copyWith({
    List<GeometryAnalysisResult>? analyses,
    bool? isLoading,
    String? error,
    GeometryAnalysisResult? latestAnalysis,
  }) {
    return GeometryMetricsState(
      analyses: analyses ?? this.analyses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      latestAnalysis: latestAnalysis ?? this.latestAnalysis,
    );
  }
}

/// Provider for managing geometry-based facial analysis
class GeometryMetricsNotifier extends StateNotifier<GeometryMetricsState> {
  final DatabaseService _db;

  GeometryMetricsNotifier(this._db) : super(const GeometryMetricsState()) {
    _loadAnalyses();
  }

  /// Load all geometry analyses from storage
  Future<void> _loadAnalyses() async {
    state = state.copyWith(isLoading: true);

    try {
      final analysisData = await _db.getGeometryAnalyses();
      final analyses = analysisData
          .map((data) => GeometryAnalysisResult.fromMap(data))
          .toList();

      // Sort by date, most recent first
      analyses.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));

      state = state.copyWith(
        analyses: analyses,
        latestAnalysis: analyses.isEmpty ? null : analyses.first,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load geometry analyses: $e',
      );
    }
  }

  /// Save new geometry analysis
  Future<void> saveAnalysis(GeometryAnalysisResult analysis) async {
    try {
      await _db.saveGeometryAnalysis(analysis.toMap());
      final updatedAnalyses = [analysis, ...state.analyses];
      state = state.copyWith(
        analyses: updatedAnalyses,
        latestAnalysis: analysis,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to save analysis: $e');
    }
  }

  /// Get analyses within date range
  List<GeometryAnalysisResult> getAnalysesInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return state.analyses
        .where((a) =>
            a.analyzedAt.isAfter(startDate) && a.analyzedAt.isBefore(endDate))
        .toList();
  }

  /// Get baseline analysis (first analysis)
  GeometryAnalysisResult? getBaselineAnalysis() {
    if (state.analyses.isEmpty) return null;
    return state.analyses.last; // Last because sorted by most recent first
  }

  /// Calculate symmetry improvement over time
  Map<String, dynamic> getSymmetryProgress() {
    if (state.analyses.length < 2) {
      return {
        'hasData': false,
        'message': 'Need at least 2 analyses to track progress',
      };
    }

    final baseline = getBaselineAnalysis()!;
    final latest = state.latestAnalysis!;

    final overallChange =
        latest.symmetry.overallSymmetry - baseline.symmetry.overallSymmetry;
    final midlineChange =
        baseline.symmetry.midlineDeviation - latest.symmetry.midlineDeviation;

    return {
      'hasData': true,
      'overallChange': overallChange,
      'midlineChange': midlineChange,
      'eyeChange': latest.symmetry.eyeSymmetry.symmetryScore -
          baseline.symmetry.eyeSymmetry.symmetryScore,
      'noseChange': latest.symmetry.noseSymmetry.symmetryScore -
          baseline.symmetry.noseSymmetry.symmetryScore,
      'lipChange': latest.symmetry.lipSymmetry.symmetryScore -
          baseline.symmetry.lipSymmetry.symmetryScore,
      'jawChange': latest.symmetry.jawSymmetry.symmetryScore -
          baseline.symmetry.jawSymmetry.symmetryScore,
      'isImproving': overallChange > 0 || midlineChange > 0,
    };
  }

  /// Calculate proportion changes over time
  Map<String, dynamic> getProportionProgress() {
    if (state.analyses.length < 2) {
      return {
        'hasData': false,
        'message': 'Need at least 2 analyses to track progress',
      };
    }

    final baseline = getBaselineAnalysis()!;
    final latest = state.latestAnalysis!;

    // Check if thirds have become more balanced
    final baselineBalance = baseline.proportions.facialThirds.isBalanced;
    final latestBalance = latest.proportions.facialThirds.isBalanced;

    // Calculate deviation from ideal golden ratio (1.618)
    final baselineGoldenDeviation =
        (baseline.proportions.goldenRatio - 1.618).abs();
    final latestGoldenDeviation =
        (latest.proportions.goldenRatio - 1.618).abs();

    return {
      'hasData': true,
      'thirdsImproved': !baselineBalance && latestBalance,
      'goldenRatioImproved': latestGoldenDeviation < baselineGoldenDeviation,
      'goldenRatioChange': baselineGoldenDeviation - latestGoldenDeviation,
      'facialIndexChange':
          latest.proportions.facialIndex - baseline.proportions.facialIndex,
    };
  }

  /// Get angular measurement trends
  Map<String, dynamic> getAngularTrends() {
    if (state.analyses.isEmpty) {
      return {'hasData': false};
    }

    // Calculate average angles over last 5 analyses
    final recentAnalyses =
        state.analyses.take(5 < state.analyses.length ? 5 : state.analyses.length).toList();

    final avgCanthalTilt = recentAnalyses
            .map((a) => a.proportions.angles.canthalTilt)
            .reduce((a, b) => a + b) /
        recentAnalyses.length;

    final avgGonialAngle = recentAnalyses
            .map((a) => a.proportions.angles.gonialAngle)
            .reduce((a, b) => a + b) /
        recentAnalyses.length;

    final avgNasolabialAngle = recentAnalyses
            .map((a) => a.proportions.angles.nasolabialAngle)
            .reduce((a, b) => a + b) /
        recentAnalyses.length;

    return {
      'hasData': true,
      'avgCanthalTilt': avgCanthalTilt,
      'avgGonialAngle': avgGonialAngle,
      'avgNasolabialAngle': avgNasolabialAngle,
      'sampleSize': recentAnalyses.length,
    };
  }

  /// Check if measurements are improving
  bool isShowingImprovement() {
    final symmetryProgress = getSymmetryProgress();
    final proportionProgress = getProportionProgress();

    if (!symmetryProgress['hasData']) return false;

    final symmetryImproving = symmetryProgress['isImproving'] as bool;
    final proportionsImproving =
        proportionProgress['goldenRatioImproved'] as bool? ?? false;

    return symmetryImproving || proportionsImproving;
  }

  /// Get measurement confidence statistics
  Map<String, dynamic> getConfidenceStats() {
    if (state.analyses.isEmpty) {
      return {'hasData': false};
    }

    final avgConfidence = state.analyses
            .map((a) => a.overallConfidence)
            .reduce((a, b) => a + b) /
        state.analyses.length;

    final avgUncertainty = state.analyses
            .map((a) => a.measurementUncertainty)
            .reduce((a, b) => a + b) /
        state.analyses.length;

    final avgFrames = state.analyses
            .map((a) => a.framesAnalyzed)
            .reduce((a, b) => a + b) ~/
        state.analyses.length;

    return {
      'hasData': true,
      'avgConfidence': avgConfidence,
      'avgUncertainty': avgUncertainty,
      'avgFrames': avgFrames,
      'totalAnalyses': state.analyses.length,
    };
  }

  /// Get regional symmetry comparison
  Map<String, dynamic> getRegionalSymmetryComparison() {
    final latest = state.latestAnalysis;
    if (latest == null) {
      return {'hasData': false};
    }

    return {
      'hasData': true,
      'eye': latest.symmetry.eyeSymmetry.symmetryScore,
      'nose': latest.symmetry.noseSymmetry.symmetryScore,
      'lip': latest.symmetry.lipSymmetry.symmetryScore,
      'jaw': latest.symmetry.jawSymmetry.symmetryScore,
      'overall': latest.symmetry.overallSymmetry,
      'mostSymmetric': _getMostSymmetricRegion(latest),
      'leastSymmetric': _getLeastSymmetricRegion(latest),
    };
  }

  String _getMostSymmetricRegion(GeometryAnalysisResult analysis) {
    final regions = {
      'Eyes': analysis.symmetry.eyeSymmetry.symmetryScore,
      'Nose': analysis.symmetry.noseSymmetry.symmetryScore,
      'Lips': analysis.symmetry.lipSymmetry.symmetryScore,
      'Jaw': analysis.symmetry.jawSymmetry.symmetryScore,
    };

    return regions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getLeastSymmetricRegion(GeometryAnalysisResult analysis) {
    final regions = {
      'Eyes': analysis.symmetry.eyeSymmetry.symmetryScore,
      'Nose': analysis.symmetry.noseSymmetry.symmetryScore,
      'Lips': analysis.symmetry.lipSymmetry.symmetryScore,
      'Jaw': analysis.symmetry.jawSymmetry.symmetryScore,
    };

    return regions.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  /// Create mock analysis for testing (remove in production)
  GeometryAnalysisResult createMockAnalysis() {
    final now = DateTime.now();

    return GeometryAnalysisResult(
      symmetry: SymmetryAnalysis(
        overallSymmetry: 85.5,
        midlineDeviation: 1.2,
        eyeSymmetry: const RegionalSymmetry(
          region: 'Eyes',
          symmetryScore: 88.0,
          leftRightDifference: 0.8,
          confidence: 0.92,
        ),
        noseSymmetry: const RegionalSymmetry(
          region: 'Nose',
          symmetryScore: 82.0,
          leftRightDifference: 1.5,
          confidence: 0.89,
        ),
        lipSymmetry: const RegionalSymmetry(
          region: 'Lips',
          symmetryScore: 86.5,
          leftRightDifference: 0.9,
          confidence: 0.91,
        ),
        jawSymmetry: const RegionalSymmetry(
          region: 'Jaw',
          symmetryScore: 84.0,
          leftRightDifference: 1.3,
          confidence: 0.87,
        ),
        confidence: 0.90,
        measuredAt: now,
      ),
      proportions: ProportionAnalysis(
        facialThirds: const FacialThirds(
          upperThird: 33.5,
          middleThird: 33.0,
          lowerThird: 33.5,
          isBalanced: true,
        ),
        goldenRatio: 1.62,
        facialIndex: 0.88,
        angles: const AngularMeasurements(
          canthalTilt: 4.5,
          gonialAngle: 122.0,
          nasolabialAngle: 105.0,
          holdawayAngle: 12.0,
          cervicoMentalAngle: 115.0,
        ),
        confidence: 0.88,
        measuredAt: now,
      ),
      additionalMeasurements: const [],
      overallConfidence: 0.89,
      framesAnalyzed: 30,
      measurementUncertainty: 0.5,
      analyzedAt: now,
    );
  }
}

/// Provider instance
final geometryMetricsProvider =
    StateNotifierProvider<GeometryMetricsNotifier, GeometryMetricsState>(
  (ref) {
    final db = ref.watch(databaseServiceProvider);
    return GeometryMetricsNotifier(db);
  },
);

/// Convenience provider for latest analysis
final latestGeometryAnalysisProvider =
    Provider<GeometryAnalysisResult?>((ref) {
  final state = ref.watch(geometryMetricsProvider);
  return state.latestAnalysis;
});

/// Convenience provider for symmetry progress
final symmetryProgressProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(geometryMetricsProvider.notifier);
  return notifier.getSymmetryProgress();
});

/// Convenience provider for proportion progress
final proportionProgressProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(geometryMetricsProvider.notifier);
  return notifier.getProportionProgress();
});

/// Convenience provider for regional symmetry
final regionalSymmetryProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(geometryMetricsProvider.notifier);
  return notifier.getRegionalSymmetryComparison();
});
