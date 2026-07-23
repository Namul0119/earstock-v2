import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static Future<bool> loadSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('soundEnabled') ?? true;
  }

  static Future<bool> loadVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibrationEnabled') ?? true;
  }

  static Future<bool> loadPushEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pushEnabled') ?? true;
  }

  static Future<String> loadWarningSound() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
          'selectedWarningSound',
        ) ??
        'sounds/warning_01.mp3';
  }

  static Future<String> loadSuccessSound() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
          'selectedSuccessSound',
        ) ??
        'sounds/success_01.mp3';
  }

  static Future<void> saveSoundEnabled(
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'soundEnabled',
      value,
    );
  }

  static Future<void> saveVibrationEnabled(
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'vibrationEnabled',
      value,
    );
  }

  static Future<void> savePushEnabled(
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'pushEnabled',
      value,
    );
  }

  static Future<void> saveWarningSound(
    String value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'selectedWarningSound',
      value,
    );
  }

  static Future<void> saveSuccessSound(
    String value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'selectedSuccessSound',
      value,
    );
  }
}