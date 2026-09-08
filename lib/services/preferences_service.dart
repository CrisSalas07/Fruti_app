import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyRememberMe = 'remember_me';
  static const String _keyUser = 'user';

  Future<void> saveUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, true);
    await prefs.setString(_keyUser, user);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, false);
    await prefs.remove(_keyUser);
  }

  Future<String?> loadUserRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    if (!rememberMe) {
      return null;
    }
    return prefs.getString(_keyUser);
  }
}
