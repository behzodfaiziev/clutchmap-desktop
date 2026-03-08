import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_settings.dart';

class SettingsLocalDataSource {
  static const String _darkModeKey = 'darkMode';
  static const String _devModeKey = 'devMode';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      darkMode: prefs.getBool(_darkModeKey) ?? true,
      devMode: prefs.getBool(_devModeKey) ?? false,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, settings.darkMode);
    await prefs.setBool(_devModeKey, settings.devMode);
  }
}



