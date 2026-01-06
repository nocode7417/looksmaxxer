import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/photo_model.dart';

/// Database service for photo storage (replaces IndexedDB)
class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.photosTable} (
        id TEXT PRIMARY KEY,
        imageData BLOB NOT NULL,
        capturedAt TEXT NOT NULL,
        width INTEGER NOT NULL,
        height INTEGER NOT NULL,
        facingMode TEXT NOT NULL,
        brightnessScore REAL NOT NULL,
        contrastScore REAL NOT NULL,
        sharpnessScore REAL NOT NULL,
        overallScore REAL NOT NULL,
        analysisResults TEXT
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_photos_capturedAt
      ON ${AppConstants.photosTable} (capturedAt DESC)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here in future versions
  }

  /// Save a photo to the database
  Future<void> savePhoto(PhotoModel photo) async {
    final db = await database;
    await db.insert(
      AppConstants.photosTable,
      {
        'id': photo.id,
        'imageData': photo.imageData,
        'capturedAt': photo.capturedAt.toIso8601String(),
        'width': photo.metadata.width,
        'height': photo.metadata.height,
        'facingMode': photo.metadata.facingMode,
        'brightnessScore': photo.qualityScore.brightness,
        'contrastScore': photo.qualityScore.contrast,
        'sharpnessScore': photo.qualityScore.sharpness,
        'overallScore': photo.qualityScore.overall,
        'analysisResults': photo.analysisResults != null
            ? photo.analysisResults.toString()
            : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a photo by ID
  Future<PhotoModel?> getPhoto(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.photosTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToPhoto(maps.first);
  }

  /// Get all photos ordered by capture date
  Future<List<PhotoModel>> getAllPhotos() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.photosTable,
      orderBy: 'capturedAt DESC',
    );

    return maps.map(_mapToPhoto).toList();
  }

  /// Get photos for a specific date range
  Future<List<PhotoModel>> getPhotosInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.photosTable,
      where: 'capturedAt >= ? AND capturedAt <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'capturedAt DESC',
    );

    return maps.map(_mapToPhoto).toList();
  }

  /// Get photo count
  Future<int> getPhotoCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.photosTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get the most recent photo
  Future<PhotoModel?> getMostRecentPhoto() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.photosTable,
      orderBy: 'capturedAt DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToPhoto(maps.first);
  }

  /// Delete a photo by ID
  Future<void> deletePhoto(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.photosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all photos
  Future<void> deleteAllPhotos() async {
    final db = await database;
    await db.delete(AppConstants.photosTable);
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  PhotoModel _mapToPhoto(Map<String, dynamic> map) {
    return PhotoModel(
      id: map['id'] as String,
      imageData: map['imageData'] as Uint8List,
      capturedAt: DateTime.parse(map['capturedAt'] as String),
      metadata: PhotoMetadata(
        width: map['width'] as int,
        height: map['height'] as int,
        facingMode: map['facingMode'] as String,
      ),
      qualityScore: QualityScore(
        brightness: map['brightnessScore'] as double,
        contrast: map['contrastScore'] as double,
        sharpness: map['sharpnessScore'] as double,
        overall: map['overallScore'] as double,
      ),
    );
  }
}
