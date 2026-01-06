/// Geometry-based facial metrics for bias-minimized analysis
/// Based on objective spatial relationships rather than learned attractiveness models

/// Evidence strength levels for recommendations
enum EvidenceStrength {
  strong,    // Multiple peer-reviewed studies confirm
  moderate,  // Some studies, moderate support
  limited,   // Theory only, few studies, or mixed results
  none,      // Pseudoscience or unproven
}

extension EvidenceStrengthExtension on EvidenceStrength {
  String get label {
    switch (this) {
      case EvidenceStrength.strong:
        return 'STRONG EVIDENCE';
      case EvidenceStrength.moderate:
        return 'MODERATE EVIDENCE';
      case EvidenceStrength.limited:
        return 'LIMITED EVIDENCE';
      case EvidenceStrength.none:
        return 'NO EVIDENCE';
    }
  }

  String get icon {
    switch (this) {
      case EvidenceStrength.strong:
        return '\u2713'; // Checkmark
      case EvidenceStrength.moderate:
        return '\u2248'; // Approximately equal
      case EvidenceStrength.limited:
        return '\u26A0'; // Warning
      case EvidenceStrength.none:
        return '\u2717'; // X mark
    }
  }

  String get color {
    switch (this) {
      case EvidenceStrength.strong:
        return 'success';
      case EvidenceStrength.moderate:
        return 'info';
      case EvidenceStrength.limited:
        return 'warning';
      case EvidenceStrength.none:
        return 'error';
    }
  }
}

/// Facial geometry measurement with cultural neutrality
class GeometryMeasurement {
  final String id;
  final String name;
  final String description;
  final double value;
  final String unit;
  final double confidence;
  final double? deviation; // Deviation from midline/center in mm
  final DateTime measuredAt;
  final String? culturalDisclaimer;

  const GeometryMeasurement({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.confidence,
    this.deviation,
    required this.measuredAt,
    this.culturalDisclaimer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'value': value,
      'unit': unit,
      'confidence': confidence,
      'deviation': deviation,
      'measuredAt': measuredAt.toIso8601String(),
      'culturalDisclaimer': culturalDisclaimer,
    };
  }

  factory GeometryMeasurement.fromMap(Map<String, dynamic> map) {
    return GeometryMeasurement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      value: map['value'],
      unit: map['unit'],
      confidence: map['confidence'],
      deviation: map['deviation'],
      measuredAt: DateTime.parse(map['measuredAt']),
      culturalDisclaimer: map['culturalDisclaimer'],
    );
  }
}

/// Symmetry analysis results
class SymmetryAnalysis {
  final double overallSymmetry; // 0-100
  final double midlineDeviation; // mm from anatomical center
  final RegionalSymmetry eyeSymmetry;
  final RegionalSymmetry noseSymmetry;
  final RegionalSymmetry lipSymmetry;
  final RegionalSymmetry jawSymmetry;
  final double confidence;
  final DateTime measuredAt;

  const SymmetryAnalysis({
    required this.overallSymmetry,
    required this.midlineDeviation,
    required this.eyeSymmetry,
    required this.noseSymmetry,
    required this.lipSymmetry,
    required this.jawSymmetry,
    required this.confidence,
    required this.measuredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'overallSymmetry': overallSymmetry,
      'midlineDeviation': midlineDeviation,
      'eyeSymmetry': eyeSymmetry.toMap(),
      'noseSymmetry': noseSymmetry.toMap(),
      'lipSymmetry': lipSymmetry.toMap(),
      'jawSymmetry': jawSymmetry.toMap(),
      'confidence': confidence,
      'measuredAt': measuredAt.toIso8601String(),
    };
  }

  factory SymmetryAnalysis.fromMap(Map<String, dynamic> map) {
    return SymmetryAnalysis(
      overallSymmetry: map['overallSymmetry'],
      midlineDeviation: map['midlineDeviation'],
      eyeSymmetry: RegionalSymmetry.fromMap(map['eyeSymmetry']),
      noseSymmetry: RegionalSymmetry.fromMap(map['noseSymmetry']),
      lipSymmetry: RegionalSymmetry.fromMap(map['lipSymmetry']),
      jawSymmetry: RegionalSymmetry.fromMap(map['jawSymmetry']),
      confidence: map['confidence'],
      measuredAt: DateTime.parse(map['measuredAt']),
    );
  }
}

/// Regional symmetry for a specific facial area
class RegionalSymmetry {
  final String region;
  final double symmetryScore; // 0-100
  final double leftRightDifference; // mm
  final double confidence;

  const RegionalSymmetry({
    required this.region,
    required this.symmetryScore,
    required this.leftRightDifference,
    required this.confidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'region': region,
      'symmetryScore': symmetryScore,
      'leftRightDifference': leftRightDifference,
      'confidence': confidence,
    };
  }

  factory RegionalSymmetry.fromMap(Map<String, dynamic> map) {
    return RegionalSymmetry(
      region: map['region'],
      symmetryScore: map['symmetryScore'],
      leftRightDifference: map['leftRightDifference'],
      confidence: map['confidence'],
    );
  }
}

/// Facial proportion analysis with cultural disclaimers
class ProportionAnalysis {
  final FacialThirds facialThirds;
  final double goldenRatio; // Actual ratio (ideal is 1.618)
  final double facialIndex; // Face length/width
  final AngularMeasurements angles;
  final double confidence;
  final DateTime measuredAt;

  static const String culturalDisclaimer =
      'These ratios derive from Renaissance art traditions. Beauty standards '
      'vary across cultures and eras. Deviation from these ratios does not '
      'indicate lesser attractiveness.';

  const ProportionAnalysis({
    required this.facialThirds,
    required this.goldenRatio,
    required this.facialIndex,
    required this.angles,
    required this.confidence,
    required this.measuredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'facialThirds': facialThirds.toMap(),
      'goldenRatio': goldenRatio,
      'facialIndex': facialIndex,
      'angles': angles.toMap(),
      'confidence': confidence,
      'measuredAt': measuredAt.toIso8601String(),
    };
  }

  factory ProportionAnalysis.fromMap(Map<String, dynamic> map) {
    return ProportionAnalysis(
      facialThirds: FacialThirds.fromMap(map['facialThirds']),
      goldenRatio: map['goldenRatio'],
      facialIndex: map['facialIndex'],
      angles: AngularMeasurements.fromMap(map['angles']),
      confidence: map['confidence'],
      measuredAt: DateTime.parse(map['measuredAt']),
    );
  }
}

/// Facial thirds analysis (vertical proportions)
class FacialThirds {
  final double upperThird; // Hairline to brow (percentage)
  final double middleThird; // Brow to nose base (percentage)
  final double lowerThird; // Nose base to chin (percentage)
  final bool isBalanced; // Within 5% of 33.3% each

  const FacialThirds({
    required this.upperThird,
    required this.middleThird,
    required this.lowerThird,
    required this.isBalanced,
  });

  Map<String, dynamic> toMap() {
    return {
      'upperThird': upperThird,
      'middleThird': middleThird,
      'lowerThird': lowerThird,
      'isBalanced': isBalanced,
    };
  }

  factory FacialThirds.fromMap(Map<String, dynamic> map) {
    return FacialThirds(
      upperThird: map['upperThird'],
      middleThird: map['middleThird'],
      lowerThird: map['lowerThird'],
      isBalanced: map['isBalanced'],
    );
  }
}

/// Angular measurements for facial geometry
class AngularMeasurements {
  final double canthalTilt; // Eye corner angle in degrees
  final double gonialAngle; // Jaw angle in degrees
  final double nasolabialAngle; // Nose-lip angle in degrees
  final double? holdawayAngle; // Facial convexity (profile only)
  final double? cervicoMentalAngle; // Jaw-neck definition (profile only)

  const AngularMeasurements({
    required this.canthalTilt,
    required this.gonialAngle,
    required this.nasolabialAngle,
    this.holdawayAngle,
    this.cervicoMentalAngle,
  });

  Map<String, dynamic> toMap() {
    return {
      'canthalTilt': canthalTilt,
      'gonialAngle': gonialAngle,
      'nasolabialAngle': nasolabialAngle,
      'holdawayAngle': holdawayAngle,
      'cervicoMentalAngle': cervicoMentalAngle,
    };
  }

  factory AngularMeasurements.fromMap(Map<String, dynamic> map) {
    return AngularMeasurements(
      canthalTilt: map['canthalTilt'],
      gonialAngle: map['gonialAngle'],
      nasolabialAngle: map['nasolabialAngle'],
      holdawayAngle: map['holdawayAngle'],
      cervicoMentalAngle: map['cervicoMentalAngle'],
    );
  }
}

/// Complete geometry analysis results
class GeometryAnalysisResult {
  final SymmetryAnalysis symmetry;
  final ProportionAnalysis proportions;
  final List<GeometryMeasurement> additionalMeasurements;
  final double overallConfidence;
  final int framesAnalyzed;
  final double measurementUncertainty; // +/- mm
  final DateTime analyzedAt;

  const GeometryAnalysisResult({
    required this.symmetry,
    required this.proportions,
    required this.additionalMeasurements,
    required this.overallConfidence,
    required this.framesAnalyzed,
    required this.measurementUncertainty,
    required this.analyzedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'symmetry': symmetry.toMap(),
      'proportions': proportions.toMap(),
      'additionalMeasurements':
          additionalMeasurements.map((m) => m.toMap()).toList(),
      'overallConfidence': overallConfidence,
      'framesAnalyzed': framesAnalyzed,
      'measurementUncertainty': measurementUncertainty,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory GeometryAnalysisResult.fromMap(Map<String, dynamic> map) {
    return GeometryAnalysisResult(
      symmetry: SymmetryAnalysis.fromMap(map['symmetry']),
      proportions: ProportionAnalysis.fromMap(map['proportions']),
      additionalMeasurements: (map['additionalMeasurements'] as List)
          .map((m) => GeometryMeasurement.fromMap(m))
          .toList(),
      overallConfidence: map['overallConfidence'],
      framesAnalyzed: map['framesAnalyzed'],
      measurementUncertainty: map['measurementUncertainty'],
      analyzedAt: DateTime.parse(map['analyzedAt']),
    );
  }
}

/// Language sanitizer for neutral terminology
class LanguageSanitizer {
  // Banned terms that should never appear in output
  static const List<String> bannedTerms = [
    'flaw',
    'flawed',
    'defect',
    'defective',
    'ugly',
    'unattractive',
    'abnormal',
    'deformity',
    'deformed',
    'imperfect',
    'imperfection',
    'bad',
    'wrong',
    'crooked',
    'weird',
    'strange',
    'broken',
    'damaged',
    'inferior',
    'subpar',
    'below average',
    'unappealing',
    'unsightly',
    'hideous',
    'grotesque',
    'disfigured',
    'malformed',
    'misshapen',
    'distorted',
    'disproportionate',
    'lopsided',
    'off-putting',
    'unfortunate',
    'problematic features',
    'needs fixing',
    'should be corrected',
  ];

  // Replacement vocabulary
  static const Map<String, String> replacements = {
    'crooked': 'deviated',
    'uneven': 'asymmetric',
    'bad': 'atypical',
    'wrong': 'different',
    'abnormal': 'uncommon',
    'imperfect': 'unique',
    'flaw': 'variation',
    'defect': 'characteristic',
    'problem': 'observation',
  };

  /// Check if text contains any banned terms
  static bool containsBannedTerms(String text) {
    final lowerText = text.toLowerCase();
    return bannedTerms.any((term) => lowerText.contains(term));
  }

  /// Sanitize text by replacing banned terms
  static String sanitize(String text) {
    String result = text;
    for (final entry in replacements.entries) {
      result = result.replaceAll(
        RegExp(entry.key, caseSensitive: false),
        entry.value,
      );
    }
    return result;
  }

  /// Get neutral description for a measurement
  static String getNeutralDescription({
    required String measurementName,
    required double value,
    required String unit,
    required double typicalMin,
    required double typicalMax,
  }) {
    final isWithinTypical = value >= typicalMin && value <= typicalMax;

    if (isWithinTypical) {
      return '$measurementName measures ${value.toStringAsFixed(1)}$unit. '
          'This falls within typical human variation ($typicalMin-$typicalMax$unit).';
    } else {
      final direction = value < typicalMin ? 'below' : 'above';
      return '$measurementName measures ${value.toStringAsFixed(1)}$unit, '
          'which is $direction the typical range ($typicalMin-$typicalMax$unit). '
          'This is a natural variation.';
    }
  }
}
