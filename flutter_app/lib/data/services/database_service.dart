import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/photo_model.dart';
import '../models/hydration_model.dart';
import '../models/mewing_model.dart';
import '../models/chewing_model.dart';
import '../models/usage_tracking_model.dart';

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
    // Photos table
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
    await db.execute('''
      CREATE INDEX idx_photos_capturedAt
      ON ${AppConstants.photosTable} (capturedAt DESC)
    ''');

    // Hydration logs table
    await db.execute('''
      CREATE TABLE ${AppConstants.hydrationLogsTable} (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        amountMl INTEGER NOT NULL,
        drinkType TEXT NOT NULL DEFAULT 'water',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_hydration_timestamp
      ON ${AppConstants.hydrationLogsTable} (timestamp DESC)
    ''');

    // Hydration goals table
    await db.execute('''
      CREATE TABLE ${AppConstants.hydrationGoalsTable} (
        id TEXT PRIMARY KEY,
        goalMl INTEGER NOT NULL,
        calculationMethod TEXT NOT NULL,
        weightKg REAL,
        activityLevel TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Mewing sessions table
    await db.execute('''
      CREATE TABLE ${AppConstants.mewingSessionsTable} (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        checkedIn INTEGER NOT NULL DEFAULT 0,
        durationMinutes INTEGER,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX idx_mewing_unique_date
      ON ${AppConstants.mewingSessionsTable} (date)
    ''');

    // Chewing sessions table
    await db.execute('''
      CREATE TABLE ${AppConstants.chewingSessionsTable} (
        id TEXT PRIMARY KEY,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationMinutes INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        targetMinutes INTEGER NOT NULL DEFAULT 10,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_chewing_start
      ON ${AppConstants.chewingSessionsTable} (startTime DESC)
    ''');

    // Usage sessions table
    await db.execute('''
      CREATE TABLE ${AppConstants.usageSessionsTable} (
        id TEXT PRIMARY KEY,
        sessionStart TEXT NOT NULL,
        sessionEnd TEXT,
        screenType TEXT NOT NULL,
        analysisCount INTEGER NOT NULL DEFAULT 0,
        interactionCount INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_usage_start
      ON ${AppConstants.usageSessionsTable} (sessionStart DESC)
    ''');

    // Interventions log table
    await db.execute('''
      CREATE TABLE ${AppConstants.interventionsLogTable} (
        id TEXT PRIMARY KEY,
        triggeredAt TEXT NOT NULL,
        triggerType TEXT NOT NULL,
        wasAcknowledged INTEGER NOT NULL DEFAULT 0,
        userResponse TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration from version 1 to version 2
    if (oldVersion < 2) {
      // Hydration logs table
      await db.execute('''
        CREATE TABLE ${AppConstants.hydrationLogsTable} (
          id TEXT PRIMARY KEY,
          timestamp TEXT NOT NULL,
          amountMl INTEGER NOT NULL,
          drinkType TEXT NOT NULL DEFAULT 'water',
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE INDEX idx_hydration_timestamp
        ON ${AppConstants.hydrationLogsTable} (timestamp DESC)
      ''');

      // Hydration goals table
      await db.execute('''
        CREATE TABLE ${AppConstants.hydrationGoalsTable} (
          id TEXT PRIMARY KEY,
          goalMl INTEGER NOT NULL,
          calculationMethod TEXT NOT NULL,
          weightKg REAL,
          activityLevel TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      // Mewing sessions table
      await db.execute('''
        CREATE TABLE ${AppConstants.mewingSessionsTable} (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          checkedIn INTEGER NOT NULL DEFAULT 0,
          durationMinutes INTEGER,
          notes TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE UNIQUE INDEX idx_mewing_unique_date
        ON ${AppConstants.mewingSessionsTable} (date)
      ''');

      // Chewing sessions table
      await db.execute('''
        CREATE TABLE ${AppConstants.chewingSessionsTable} (
          id TEXT PRIMARY KEY,
          startTime TEXT NOT NULL,
          endTime TEXT,
          durationMinutes INTEGER NOT NULL,
          completed INTEGER NOT NULL DEFAULT 0,
          targetMinutes INTEGER NOT NULL DEFAULT 10,
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE INDEX idx_chewing_start
        ON ${AppConstants.chewingSessionsTable} (startTime DESC)
      ''');

      // Usage sessions table
      await db.execute('''
        CREATE TABLE ${AppConstants.usageSessionsTable} (
          id TEXT PRIMARY KEY,
          sessionStart TEXT NOT NULL,
          sessionEnd TEXT,
          screenType TEXT NOT NULL,
          analysisCount INTEGER NOT NULL DEFAULT 0,
          interactionCount INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE INDEX idx_usage_start
        ON ${AppConstants.usageSessionsTable} (sessionStart DESC)
      ''');

      // Interventions log table
      await db.execute('''
        CREATE TABLE ${AppConstants.interventionsLogTable} (
          id TEXT PRIMARY KEY,
          triggeredAt TEXT NOT NULL,
          triggerType TEXT NOT NULL,
          wasAcknowledged INTEGER NOT NULL DEFAULT 0,
          userResponse TEXT
        )
      ''');
    }
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

  // ============================================================
  // HYDRATION METHODS
  // ============================================================

  /// Save a hydration log
  Future<void> saveHydrationLog(HydrationLog log) async {
    final db = await database;
    await db.insert(
      AppConstants.hydrationLogsTable,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all hydration logs
  Future<List<HydrationLog>> getAllHydrationLogs() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.hydrationLogsTable,
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => HydrationLog.fromMap(m)).toList();
  }

  /// Get hydration logs for a date range
  Future<List<HydrationLog>> getHydrationLogsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.hydrationLogsTable,
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => HydrationLog.fromMap(m)).toList();
  }

  /// Get hydration logs for today
  Future<List<HydrationLog>> getTodayHydrationLogs() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getHydrationLogsInRange(startOfDay, endOfDay);
  }

  /// Delete a hydration log
  Future<void> deleteHydrationLog(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.hydrationLogsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Save hydration goal
  Future<void> saveHydrationGoal(HydrationGoal goal) async {
    final db = await database;
    await db.insert(
      AppConstants.hydrationGoalsTable,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get the current hydration goal
  Future<HydrationGoal?> getCurrentHydrationGoal() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.hydrationGoalsTable,
      orderBy: 'updatedAt DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HydrationGoal.fromMap(maps.first);
  }

  // ============================================================
  // MEWING METHODS
  // ============================================================

  /// Save a mewing session
  Future<void> saveMewingSession(MewingSession session) async {
    final db = await database;
    await db.insert(
      AppConstants.mewingSessionsTable,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all mewing sessions
  Future<List<MewingSession>> getAllMewingSessions() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.mewingSessionsTable,
      orderBy: 'date DESC',
    );
    return maps.map((m) => MewingSession.fromMap(m)).toList();
  }

  /// Get mewing session for a specific date
  Future<MewingSession?> getMewingSessionForDate(DateTime date) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final db = await database;
    final maps = await db.query(
      AppConstants.mewingSessionsTable,
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    if (maps.isEmpty) return null;
    return MewingSession.fromMap(maps.first);
  }

  /// Get mewing sessions for a date range
  Future<List<MewingSession>> getMewingSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final startStr =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr =
        '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    final db = await database;
    final maps = await db.query(
      AppConstants.mewingSessionsTable,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );
    return maps.map((m) => MewingSession.fromMap(m)).toList();
  }

  /// Get today's mewing session
  Future<MewingSession?> getTodayMewingSession() async {
    return getMewingSessionForDate(DateTime.now());
  }

  /// Delete a mewing session
  Future<void> deleteMewingSession(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.mewingSessionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // CHEWING METHODS
  // ============================================================

  /// Save a chewing session
  Future<void> saveChewingSession(ChewingSession session) async {
    final db = await database;
    await db.insert(
      AppConstants.chewingSessionsTable,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all chewing sessions
  Future<List<ChewingSession>> getAllChewingSessions() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.chewingSessionsTable,
      orderBy: 'startTime DESC',
    );
    return maps.map((m) => ChewingSession.fromMap(m)).toList();
  }

  /// Get chewing sessions for a date range
  Future<List<ChewingSession>> getChewingSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.chewingSessionsTable,
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startTime DESC',
    );
    return maps.map((m) => ChewingSession.fromMap(m)).toList();
  }

  /// Get today's chewing sessions
  Future<List<ChewingSession>> getTodayChewingSessions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getChewingSessionsInRange(startOfDay, endOfDay);
  }

  /// Get active chewing session (not completed, no end time)
  Future<ChewingSession?> getActiveChewingSession() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.chewingSessionsTable,
      where: 'endTime IS NULL AND completed = 0',
      orderBy: 'startTime DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ChewingSession.fromMap(maps.first);
  }

  /// Delete a chewing session
  Future<void> deleteChewingSession(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.chewingSessionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // USAGE TRACKING METHODS
  // ============================================================

  /// Save a usage session
  Future<void> saveUsageSession(UsageSession session) async {
    final db = await database;
    await db.insert(
      AppConstants.usageSessionsTable,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all usage sessions
  Future<List<UsageSession>> getAllUsageSessions() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.usageSessionsTable,
      orderBy: 'sessionStart DESC',
    );
    return maps.map((m) => UsageSession.fromMap(m)).toList();
  }

  /// Get usage sessions for a date range
  Future<List<UsageSession>> getUsageSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.usageSessionsTable,
      where: 'sessionStart >= ? AND sessionStart <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'sessionStart DESC',
    );
    return maps.map((m) => UsageSession.fromMap(m)).toList();
  }

  /// Get recent usage sessions (last 7 days)
  Future<List<UsageSession>> getRecentUsageSessions() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getUsageSessionsInRange(weekAgo, now);
  }

  /// Save an intervention
  Future<void> saveIntervention(Intervention intervention) async {
    final db = await database;
    await db.insert(
      AppConstants.interventionsLogTable,
      intervention.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all interventions
  Future<List<Intervention>> getAllInterventions() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.interventionsLogTable,
      orderBy: 'triggeredAt DESC',
    );
    return maps.map((m) => Intervention.fromMap(m)).toList();
  }

  /// Get the most recent intervention
  Future<Intervention?> getMostRecentIntervention() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.interventionsLogTable,
      orderBy: 'triggeredAt DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Intervention.fromMap(maps.first);
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Delete all data from all tables (for reset functionality)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete(AppConstants.photosTable);
    await db.delete(AppConstants.hydrationLogsTable);
    await db.delete(AppConstants.hydrationGoalsTable);
    await db.delete(AppConstants.mewingSessionsTable);
    await db.delete(AppConstants.chewingSessionsTable);
    await db.delete(AppConstants.usageSessionsTable);
    await db.delete(AppConstants.interventionsLogTable);
  }
}
