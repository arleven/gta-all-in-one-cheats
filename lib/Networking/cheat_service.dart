import 'dart:convert';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class CheatService {
  static List<CheatCode>? _cachedXboxCheats;
  static List<CheatCode>? _cachedIphoneCheats;
  static List<CheatCode>? _cachedPlaystationCheats;
  static List<CheatCode>? _cachedPcCheats;
  static List<CheatCode>? _cachedPhoneNumCheats;

  static String _selectedGame = 'sanandreas';

  static void updateSelectedGame(String gameKey) {
    _selectedGame = gameKey;
    // Optionally clear caches if needed
    _cachedXboxCheats = null;
    _cachedPlaystationCheats = null;
    _cachedIphoneCheats = null;
    _cachedPcCheats = null;
  }

  static String get _gameFolder {
    switch (_selectedGame) {
      case 'gtav':
        return 'gtav';
      case 'vicecity':
        return 'vicecity';
      case 'libertycity':
        return 'libertycity';
      case 'sanandreas':
      default:
        return 'sanandreas';
    }
  }

  static Future<List<CheatCode>> fetchXboxCheats({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedXboxCheats != null) {
      return _cachedXboxCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/xbox.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => CheatCode.fromJson(e)).toList();
      _cachedXboxCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }

  static Future<List<CheatCode>> fetchIphoneCheats({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedIphoneCheats != null) {
      return _cachedIphoneCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/iphone.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => CheatCode.fromJson(e)).toList();
      _cachedIphoneCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }

  static Future<List<CheatCode>> fetchPlaystationCheats({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedPlaystationCheats != null) {
      return _cachedPlaystationCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/playstation.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => CheatCode.fromJson(e)).toList();
      _cachedPlaystationCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }

  static Future<List<CheatCode>> fetchPcCheats({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedPcCheats != null) {
      return _cachedPcCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/pc.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => CheatCode.fromJson(e)).toList();
      _cachedPcCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }

  static Future<List<CheatCode>> fetchPhoneNumCheats({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedPhoneNumCheats != null) {
      return _cachedPhoneNumCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/phone_num.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => CheatCode.fromJson(e)).toList();
      _cachedPhoneNumCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }
}
