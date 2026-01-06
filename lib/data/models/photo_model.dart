import 'dart:typed_data';

/// Photo model representing a captured photo
class PhotoModel {
  final String id;
  final Uint8List imageData;
  final DateTime capturedAt;
  final PhotoMetadata metadata;
  final QualityScore qualityScore;
  final Map<String, MetricValue>? analysisResults;

  PhotoModel({
    required this.id,
    required this.imageData,
    required this.capturedAt,
    required this.metadata,
    required this.qualityScore,
    this.analysisResults,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageData': imageData,
      'capturedAt': capturedAt.toIso8601String(),
      'width': metadata.width,
      'height': metadata.height,
      'facingMode': metadata.facingMode,
      'brightnessScore': qualityScore.brightness,
      'contrastScore': qualityScore.contrast,
      'sharpnessScore': qualityScore.sharpness,
      'overallScore': qualityScore.overall,
      'analysisResults': analysisResults != null
          ? analysisResults!.map((k, v) => MapEntry(k, v.toMap()))
          : null,
    };
  }

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    Map<String, MetricValue>? analysisResults;
    if (map['analysisResults'] != null) {
      analysisResults = (map['analysisResults'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, MetricValue.fromMap(v)));
    }

    return PhotoModel(
      id: map['id'],
      imageData: map['imageData'],
      capturedAt: DateTime.parse(map['capturedAt']),
      metadata: PhotoMetadata(
        width: map['width'],
        height: map['height'],
        facingMode: map['facingMode'],
      ),
      qualityScore: QualityScore(
        brightness: map['brightnessScore'],
        contrast: map['contrastScore'],
        sharpness: map['sharpnessScore'],
        overall: map['overallScore'],
      ),
      analysisResults: analysisResults,
    );
  }

  PhotoModel copyWith({
    String? id,
    Uint8List? imageData,
    DateTime? capturedAt,
    PhotoMetadata? metadata,
    QualityScore? qualityScore,
    Map<String, MetricValue>? analysisResults,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      capturedAt: capturedAt ?? this.capturedAt,
      metadata: metadata ?? this.metadata,
      qualityScore: qualityScore ?? this.qualityScore,
      analysisResults: analysisResults ?? this.analysisResults,
    );
  }
}

/// Photo metadata
class PhotoMetadata {
  final int width;
  final int height;
  final String facingMode;

  PhotoMetadata({
    required this.width,
    required this.height,
    required this.facingMode,
  });
}

/// Quality score for a photo
class QualityScore {
  final double brightness;
  final double contrast;
  final double sharpness;
  final double overall;

  QualityScore({
    required this.brightness,
    required this.contrast,
    required this.sharpness,
    required this.overall,
  });

  bool get isAcceptable => overall >= 50;

  String get qualityLabel {
    if (overall >= 80) return 'Excellent';
    if (overall >= 60) return 'Good';
    if (overall >= 50) return 'Acceptable';
    return 'Poor';
  }
}

/// Single metric value with confidence
class MetricValue {
  final double value;
  final double confidence;
  final DateTime measuredAt;

  MetricValue({
    required this.value,
    required this.confidence,
    required this.measuredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'confidence': confidence,
      'measuredAt': measuredAt.toIso8601String(),
    };
  }

  factory MetricValue.fromMap(Map<String, dynamic> map) {
    return MetricValue(
      value: map['value'],
      confidence: map['confidence'],
      measuredAt: DateTime.parse(map['measuredAt']),
    );
  }
}
