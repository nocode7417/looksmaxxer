import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/services/services.dart';
import 'providers/providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  AppTheme.setSystemUIOverlayStyle();
  await AppTheme.setPreferredOrientations();

  // Initialize services
  await PreferencesService().init();

  runApp(
    const ProviderScope(
      child: LooksmaxxerApp(),
    ),
  );
}
