import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const _keyUrl = 'turso_url';
  static const _keyToken = 'turso_token';

  // Defaults — altere aqui ou configure na tela de settings
  static const defaultUrl = 'https://camda-estoque-leolira1.turso.io';

  static Future<String> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUrl) ?? defaultUrl;
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken) ?? '';
  }

  static Future<void> save({required String url, required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUrl, url);
    await prefs.setString(_keyToken, token);
  }
}
