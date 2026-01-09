import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/photo_model.dart';
import '../data/services/database_service.dart';
import 'app_state_provider.dart';

/// Type alias for PhotoModel for convenience
typedef Photo = PhotoModel;

/// Extension on PhotoModel to add metrics getter
extension PhotoMetrics on PhotoModel {
  Map<String, MetricValue> get metrics => analysisResults ?? {};
}

/// Provider for the latest photo
final latestPhotoProvider = FutureProvider<Photo?>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  final photos = await dbService.getAllPhotos();

  if (photos.isEmpty) return null;

  // Sort by capturedAt descending and return the first
  photos.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
  return photos.first;
});

/// Provider for the baseline photo
final baselineProvider = FutureProvider<Photo?>((ref) async {
  final appState = ref.watch(appStateProvider);
  final baselinePhotoId = appState.baselinePhotoId;

  if (baselinePhotoId == null) return null;

  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getPhoto(baselinePhotoId);
});

/// Provider for all photos
final allPhotosProvider = FutureProvider<List<Photo>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  final photos = await dbService.getAllPhotos();

  // Sort by capturedAt descending
  photos.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
  return photos;
});

/// Provider for photos in the last 7 days
final weekPhotosProvider = FutureProvider<List<Photo>>((ref) async {
  final photos = await ref.watch(allPhotosProvider.future);
  final weekAgo = DateTime.now().subtract(const Duration(days: 7));

  return photos.where((p) => p.capturedAt.isAfter(weekAgo)).toList();
});

/// Provider for photo count
final photoCountProvider = FutureProvider<int>((ref) async {
  final photos = await ref.watch(allPhotosProvider.future);
  return photos.length;
});
