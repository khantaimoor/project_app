import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSource({required this.sharedPreferences});

  static const String nameKey = 'user_name';
  static const String photoUrlKey = 'user_photo_url';
  static const String isDarkModeKey = 'is_dark_mode';

  Future<void> saveName(String name) async {
    await sharedPreferences.setString(nameKey, name);
  }

  Future<void> savePhotoUrl(String? url) async {
    if (url != null) {
      await sharedPreferences.setString(photoUrlKey, url);
    } else {
      await sharedPreferences.remove(photoUrlKey);
    }
  }

  Future<void> saveIsDarkMode(bool isDarkMode) async {
    await sharedPreferences.setBool(isDarkModeKey, isDarkMode);
  }

  String? getName() {
    return sharedPreferences.getString(nameKey);
  }

  String? getPhotoUrl() {
    return sharedPreferences.getString(photoUrlKey);
  }

  bool getIsDarkMode() {
    return sharedPreferences.getBool(isDarkModeKey) ?? false;
  }

  Future<void> clear() async {
    await sharedPreferences.clear();
  }
}
