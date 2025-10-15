import 'dart:convert';
import 'package:all_gta/Networking/hidden_location_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class HiddenLocationService {
  static List<HiddenLocation>? _cachedXboxCheats;
  static List<HiddenLocation>? _cachedIphoneCheats;
  static List<HiddenLocation>? _cachedPlaystationCheats;
  static List<HiddenLocation>? _cachedPcCheats;

  static String _selectedGame = 'sanandreas';

  static void updateHiddenSelectedGame(String gameKey) {
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

  static Future<List<HiddenLocation>> fetchXboxHiddenLocation({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedXboxCheats != null) {
      return _cachedXboxCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/hidden/$_gameFolder/xbox.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => HiddenLocation.fromJson(e)).toList();
      _cachedXboxCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }

  static Future<List<HiddenLocation>> fetchIphoneHiddenLocation({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedIphoneCheats != null) {
      return _cachedIphoneCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/hidden/$_gameFolder/iphone.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => HiddenLocation.fromJson(e)).toList();
      _cachedIphoneCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }

  static Future<List<HiddenLocation>> fetchPlaystationHiddenLocation({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedPlaystationCheats != null) {
      return _cachedPlaystationCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/hidden/$_gameFolder/playstation.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => HiddenLocation.fromJson(e)).toList();
      _cachedPlaystationCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }

  static Future<List<HiddenLocation>> fetchHiddenLocation({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedPcCheats != null) {
      return _cachedPcCheats!;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/hidden/$_gameFolder/pc.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final cheats = jsonList.map((e) => HiddenLocation.fromJson(e)).toList();
      _cachedPcCheats = cheats;
      return cheats;
    } catch (e) {
      print('Error loading local JSON: $e');
      return [];
    }
  }
}
