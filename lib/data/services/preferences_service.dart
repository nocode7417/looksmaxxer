import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_state_model.dart';

/// Preferences service for app state (replaces localStorage)
class PreferencesService {
  static const String _appStateKey = 'app_state';
  static SharedPreferences? _prefs;
  static final PreferencesService _instance = PreferencesService._internal();

  factory PreferencesService() => _instance;
  PreferencesService._internal();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Load app state
  Future<AppStateModel> loadAppState() async {
    final preferences = await prefs;
    final json = preferences.getString(_appStateKey);

    if (json == null) {
      return AppStateModel.initial();
    }

    try {
      return AppStateModel.fromJson(json);
    } catch (e) {
      // If parsing fails, return initial state
      return AppStateModel.initial();
    }
  }

  /// Save app state
  Future<void> saveAppState(AppStateModel state) async {
    final preferences = await prefs;
    await preferences.setString(_appStateKey, state.toJson());
  }

  /// Check if onboarding is complete
  Future<bool> hasCompletedOnboarding() async {
    final state = await loadAppState();
    return state.hasCompletedOnboarding;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete() async {
    final state = await loadAppState();
    await saveAppState(state.copyWith(hasCompletedOnboarding: true));
  }

  /// Reset all app data
  Future<void> resetAllData() async {
    final preferences = await prefs;
    await preferences.remove(_appStateKey);
  }

  /// Get a specific boolean preference
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final preferences = await prefs;
    return preferences.getBool(key) ?? defaultValue;
  }

  /// Set a specific boolean preference
  Future<void> setBool(String key, bool value) async {
    final preferences = await prefs;
    await preferences.setBool(key, value);
  }

  /// Get a specific string preference
  Future<String?> getString(String key) async {
    final preferences = await prefs;
    return preferences.getString(key);
  }

  /// Set a specific string preference
  Future<void> setString(String key, String value) async {
    final preferences = await prefs;
    await preferences.setString(key, value);
  }

  /// Get a specific int preference
  Future<int?> getInt(String key) async {
    final preferences = await prefs;
    return preferences.getInt(key);
  }

  /// Set a specific int preference
  Future<void> setInt(String key, int value) async {
    final preferences = await prefs;
    await preferences.setInt(key, value);
  }
}
