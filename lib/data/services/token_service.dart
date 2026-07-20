import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static Future<bool> add_token(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool saved = await prefs.setString(
      "login_token",
      token.substring(token.indexOf('|') + 1, token.length),
    );
    return saved;
  }

  static Future<bool> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool removed = await prefs.remove("login_token");
    return removed;
  }
}