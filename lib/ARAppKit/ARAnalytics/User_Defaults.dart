import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';

class AppUserDefaults {
  static const String keyConfig = "key_config";
  static const String keyProUser = "key_isProUser";
  static const String userIDKey = "key_userID";

  // MARK: - Review Shown On Save
  static Future<bool> isReviewShownOnSave() async {
    const key = "isReviewShownOnSave";
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool(key) ?? false;
    if (!result) {
      await prefs.setBool(key, true);
    }
    return result;
  }

  // MARK: - Pro user
  static Future<void> setProUser(bool pro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyProUser, pro);
  }

  static Future<bool> getProUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyProUser) ?? false;
  }

  // MARK: - Config
  static Future<void> setConfig(Map<String, dynamic> config) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert map to JSON string since SharedPreferences doesn't support maps directly
    await prefs.setString(keyConfig, jsonEncode(config));
  }

  static Future<Map<String, dynamic>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configString = prefs.getString(keyConfig);
    if (configString != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(configString));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<String> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString(userIDKey);
    if (userID == null || userID.isEmpty) {
      final id = _randomString(6);
      await prefs.setString(userIDKey, id);
      return id;
    }
    return userID;
  }

  // MARK: - Utility methods
  static String _randomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  //MARK: Not known
  Future<int?> getIntFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.getInt(key);
    }
    return null;
  }
}
