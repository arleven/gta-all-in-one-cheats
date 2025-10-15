import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:all_gta/Networking/hidden_location_model.dart';

class HiddenLocationService {
  static List<HiddenLocation>? _cachedXboxLocations;
  static List<HiddenLocation>? _cachedIphoneLocations;
  static List<HiddenLocation>? _cachedPlaystationLocations;
  static List<HiddenLocation>? _cachedPcLocations;

  static String _selectedGame = 'vicecity';

  static void updateSelectedGame(String gameKey) {
    _selectedGame = gameKey;
    _cachedXboxLocations = null;
    _cachedIphoneLocations = null;
    _cachedPlaystationLocations = null;
    _cachedPcLocations = null;
  }

  static String get _gameFolder {
    switch (_selectedGame) {
      case 'gtav':
        return 'gtav';
      case 'sanandreas':
        return 'sanandreas';
      case 'libertycity':
        return 'libertycity';
      case 'vicecity':
      default:
        return 'vicecity';
    }
  }

  // ---------- XBOX ----------
  static Future<List<HiddenLocation>> fetchXboxHiddenLocations({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedXboxLocations != null) {
      return _cachedXboxLocations!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/hidden_locations/xbox.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final locations = jsonList
          .map((e) => HiddenLocation.fromJson(e as Map<String, dynamic>))
          .toList();

      _cachedXboxLocations = locations;
      return locations;
    } catch (e) {
      print('Error loading Xbox hidden locations: $e');
      return [];
    }
  }

  // ---------- iPHONE ----------
  static Future<List<HiddenLocation>> fetchIphoneHiddenLocations({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedIphoneLocations != null) {
      return _cachedIphoneLocations!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/hidden_locations/iphone.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final locations = jsonList
          .map((e) => HiddenLocation.fromJson(e as Map<String, dynamic>))
          .toList();

      _cachedIphoneLocations = locations;
      return locations;
    } catch (e) {
      print('Error loading iPhone hidden locations: $e');
      return [];
    }
  }

  // ---------- PLAYSTATION ----------
  static Future<List<HiddenLocation>> fetchPlaystationHiddenLocations({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedPlaystationLocations != null) {
      return _cachedPlaystationLocations!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/hidden_locations/playstation.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final locations = jsonList
          .map((e) => HiddenLocation.fromJson(e as Map<String, dynamic>))
          .toList();

      _cachedPlaystationLocations = locations;
      return locations;
    } catch (e) {
      print('Error loading PlayStation hidden locations: $e');
      return [];
    }
  }

  // ---------- PC ----------
  static Future<List<HiddenLocation>> fetchPcHiddenLocations({
    bool useCacheFirst = true,
  }) async {
    if (useCacheFirst && _cachedPcLocations != null) {
      return _cachedPcLocations!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/$_gameFolder/hidden_locations/pc.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final locations = jsonList
          .map((e) => HiddenLocation.fromJson(e as Map<String, dynamic>))
          .toList();

      _cachedPcLocations = locations;
      return locations;
    } catch (e) {
      print('Error loading PC hidden locations: $e');
      return [];
    }
  }

  // ---------- FILTER BY SECTION ----------
  static Future<List<HiddenLocation>> fetchBySection(
    String section, {
    String platform = 'xbox',
  }) async {
    List<HiddenLocation> all;

    switch (platform.toLowerCase()) {
      case 'iphone':
        all = await fetchIphoneHiddenLocations();
        break;
      case 'playstation':
        all = await fetchPlaystationHiddenLocations();
        break;
      case 'pc':
        all = await fetchPcHiddenLocations();
        break;
      case 'xbox':
      default:
        all = await fetchXboxHiddenLocations();
        break;
    }

    return all
        .where((e) => e.section.toLowerCase() == section.toLowerCase())
        .toList();
  }
}
