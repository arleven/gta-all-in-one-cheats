import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';

class RecentCheatsProvider extends ChangeNotifier {
  String _platform = 'xbox';
  List<CheatCode> _recentCheats = [];

  List<CheatCode> get recentCheats => _recentCheats;
  String get platform => _platform;

  RecentCheatsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _platform = prefs.getString('selectedPlatform') ?? 'xbox';
    await loadRecentCheats();
  }

  Future<void> setPlatform(String platform) async {
    if (_platform != platform) {
      _platform = platform;
      await loadRecentCheats();
    }
  }

  Future<void> loadRecentCheats() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'recentCheats_${_platform.toLowerCase()}';
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

  Future<void> addRecent(CheatCode cheat) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'recentCheats_${_platform.toLowerCase()}';

    // Remove duplicate if already in list
    _recentCheats.removeWhere((c) => c.title == cheat.title);

    // Add at top
    _recentCheats.insert(0, cheat);

    // Keep only 10 recents
    if (_recentCheats.length > 10) {
      _recentCheats = _recentCheats.sublist(0, 10);
    }

    // Save to SharedPrefs
    final encoded = jsonEncode(_recentCheats.map((c) => c.rawData).toList());
    await prefs.setString(key, encoded);

    notifyListeners();
  }
}
