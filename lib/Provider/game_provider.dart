import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/Networking/hidden_location_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider extends ChangeNotifier {
  String _selectedGame = 'sanandreas';

  String get selectedGame => _selectedGame;

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedGame = prefs.getString('selectedGame') ?? 'sanandreas';
    CheatService.updateSelectedGame(_selectedGame);
    notifyListeners();
  }

  Future<void> setGame(String game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGame', game);
    _selectedGame = game;
    CheatService.updateSelectedGame(game);
    notifyListeners();
  }

  Future<void> loadHiddenGame() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedGame = prefs.getString('selectedGame') ?? 'sanandreas';
    HiddenLocationService.updateHiddenSelectedGame(_selectedGame);
    notifyListeners();
  }

  Future<void> setHiddenGame(String game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGame', game);
    _selectedGame = game;
    HiddenLocationService.updateHiddenSelectedGame(game);
    notifyListeners();
  }
}
