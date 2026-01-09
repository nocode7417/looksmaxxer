import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/services/services.dart';
import 'engine/analysis_engine.dart';
import 'providers/providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  AppTheme.setSystemUIOverlayStyle();
  await AppTheme.setPreferredOrientations();

  // Initialize services
  await PreferencesService().init();
  await DatabaseService().database; // Ensure database is initialized

  // Initialize ML Kit (async, don't block startup)
  AnalysisEngine.initializeMLKit();

  runApp(
    const ProviderScope(
      child: LooksmaxxerApp(),
    ),
  );
}
