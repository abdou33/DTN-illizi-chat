import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  // static Future<bool> saveuserinfos(String user, String token) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool userissaved = await prefs.setString("user", user);
  //   bool tokenissaved = await prefs.setString(
  //     "login_token",
  //     token.substring(token.indexOf('|') + 1, token.length),
  //   );
  //   return userissaved && tokenissaved;
  // }

  // static Future<bool> isloggedin() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   return prefs.getString("user") != null &&
  //       prefs.getString("login_token") != null;
  // }

  // static Future<bool> logout() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool userwasremoved = await prefs.remove("user");
  //   bool tokenwasremoved = await prefs.remove("login_token");
  //   return userwasremoved && tokenwasremoved;
  // }
}
