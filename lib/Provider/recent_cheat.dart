import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';

class RecentCheatsProvider extends ChangeNotifier {
  String _platform = 'xbox';
  String _game = 'sanandreas';
  List<CheatCode> _recentCheats = [];
  List<Map<String, dynamic>> recentHiddenLocations = [];

  List<CheatCode> get recentCheats => _recentCheats;
  String get platform => _platform;
  String get game => _game;

  RecentCheatsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _platform = prefs.getString('selectedPlatform') ?? 'xbox';
    _game = prefs.getString('selectedGame') ?? 'sanandreas';
    await loadRecentCheats();
    await loadRecentHiddenLocations();
  }

  Future<void> setPlatform(String platform) async {
    if (_platform != platform) {
      _platform = platform;
      await loadRecentCheats();
      await loadRecentHiddenLocations();
    }
  }

  Future<void> setGame(String game) async {
    if (_game != game) {
      _game = game;
      await loadRecentCheats();
      await loadRecentHiddenLocations();
    }
  }

  Future<void> loadRecentCheats() async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'recentCheats_${_game.toLowerCase()}_${_platform.toLowerCase()}';
    final stored = prefs.getString(key);

    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      _recentCheats = decoded.map((data) {
        return CheatCode(
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          codes: data['codes'] ?? '',
          section: data['section'] ?? '',
          rawData: data,
        );
      }).toList();
    } else {
      _recentCheats = [];
    }

    notifyListeners();
  }

  Future<void> loadRecentHiddenLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'recentHiddenLocations_${_game.toLowerCase()}_${_platform.toLowerCase()}';
    final stored = prefs.getString(key);

    if (stored != null) {
      recentHiddenLocations = List<Map<String, dynamic>>.from(
        jsonDecode(stored),
      );
    } else {
      recentHiddenLocations = [];
    }

    notifyListeners();
  }

  Future<void> addRecent(CheatCode cheat) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'recentCheats_${_game.toLowerCase()}_${_platform.toLowerCase()}';

    _recentCheats.removeWhere((c) => c.title == cheat.title);
    _recentCheats.insert(0, cheat);

    if (_recentCheats.length > 10) {
      _recentCheats = _recentCheats.sublist(0, 10);
    }

    final encoded = jsonEncode(_recentCheats.map((c) => c.rawData).toList());
    await prefs.setString(key, encoded);

    notifyListeners();
  }
}
