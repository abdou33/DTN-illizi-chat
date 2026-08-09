import 'dart:convert';

import 'package:wilaya_illizi_chat/data/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  static String? token;
  static UserModel? currentUser;

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("login_token");

    final userJson = prefs.getString("user");
    if (userJson != null) {
      currentUser = UserModel.fromMap(jsonDecode(userJson));
    } else {
      currentUser = null;
    }
    print("currentuser id:::::: ${currentUser?.id}");
  }

  static Future<bool> setToken(String newToken) async {
    token = newToken;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool saved = await prefs.setString(
      "login_token",
      newToken.substring(newToken.indexOf('|') + 1, newToken.length),
    );
    await loadToken();
    return saved;
  }

  static Future<void> clearToken() async {
    token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("login_token");
    await prefs.remove("user");
  }

  Future<bool> userisloggedin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user") != null &&
        prefs.getString("login_token") != null;
  }

  Future<void> login({required dynamic user, required String token}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool userissaved = await prefs.setString("user", jsonEncode(user));

    bool tokenissaved = await setToken(token);
    bool issaved = userissaved && tokenissaved;

    if (!issaved) {
      throw Exception('an error was thrown when saving the login infos');
    }
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool userwasremoved = await prefs.remove("user");
    bool tokenwasremoved = await prefs.remove("login_token");
    bool isremoved = userwasremoved && tokenwasremoved;
    if (!isremoved) {
      throw Exception('an error was thrown when removing the login infos');
    }
  }
}
