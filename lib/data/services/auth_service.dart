import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'local_db.dart';

/// Thin API over [LocalDb] for authentication and users.
class AuthService {
  final LocalDb _db = LocalDb();

  UserModel? get currentUser => _db.currentUser;

  Future<UserModel> signUp({
    required String name,
    required String phoneNumber,
    required String password,
  }) => _db.signUp(name: name, phoneNumber: phoneNumber, password: password);

  Future<bool> logIn({
    required String phoneNumber,
    required String password,
  }) async {
    _db.logIn(phoneNumber: phoneNumber, password: password);
    return true;
  }

  static Future<bool> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool removed = await prefs.remove("login_token");
    return removed;
  }

  static Future<bool> add_token(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool saved = await prefs.setString(
      "login_token",
      token.substring(token.indexOf('|') + 1, token.length),
    );
    return saved;
  }

  Future<UserModel?> getCurrentUserData() async => _db.currentUser;

  Future<void> updateProfile({
    String? name,
    String? about,
    String? profileImageUrl,
  }) => _db.updateProfile(
    name: name,
    about: about,
    profileImageUrl: profileImageUrl,
  );

  Future<List<UserModel>> searchUsers(String query) =>
      Future.value(_db.searchUsers(query));

  List<UserModel> get otherUsers {
    final id = _db.currentUser?.uid;
    return _db.users.where((u) => u.uid != id).toList();
  }
}
