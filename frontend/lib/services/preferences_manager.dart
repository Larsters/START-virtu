import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const String _hasCompletedSurveyKey = 'has_completed_survey';

  static final PreferencesManager _instance = PreferencesManager._internal();

  factory PreferencesManager() {
    return _instance;
  }

  PreferencesManager._internal();

  Future<bool> hasCompletedSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedSurveyKey) ?? false;
  }

  Future<void> setCompletedSurvey(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedSurveyKey, value);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
