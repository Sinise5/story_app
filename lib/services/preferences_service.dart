import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _tokenKey = 'token';
  static const String _isLoggedInKey = 'is_logged_in';

  // Menyimpan token saat login
  Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Mengambil token yang tersimpan
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Mengecek apakah pengguna sudah login
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Menghapus token tanpa mengubah status login
  Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Menghapus token dan status login saat logout
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}
