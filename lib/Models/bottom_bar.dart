import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/Presentation/Cheat_Screens/favorites.dart';
import 'package:all_gta/Presentation/Cheat_Screens/iphone.dart';
import 'package:all_gta/Presentation/Cheat_Screens/pc.dart';
import 'package:all_gta/Presentation/Cheat_Screens/playstation.dart';
import 'package:all_gta/Presentation/Cheat_Screens/search.dart';

import 'package:all_gta/Presentation/Cheat_Screens/xbox.dart';
import 'package:all_gta/Provider/recent_cheat.dart';
import 'package:all_gta/l10n/app_localizations.dart';

import 'package:flutter/material.dart';

import 'package:all_gta/Presentation/Settings_Screen/settings.dart';
import 'package:provider/provider.dart';
import 'package:all_gta/Provider/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomBars extends StatefulWidget {
  final String initialGame;
  final String initialPlatform;

  const BottomBars({
    super.key,
    required this.initialGame,
    required this.initialPlatform,
  });

  @override
  State<BottomBars> createState() => _BottomBarsState();
}

class _BottomBarsState extends State<BottomBars> {
  int _selectedIndex = 0;
  String? _selectedPlatformKey;

  bool _initDone = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _getPlatformScreen() {
    switch (_selectedPlatformKey) {
      case 'playstation':
        return Playstation(
          initialGame: widget.initialGame,
          initialPlatform: widget.initialPlatform,
        );
      case 'pc':
        return Pc(
          initialGame: widget.initialGame,
          initialPlatform: widget.initialPlatform,
        );
      case 'iphone':
        return Iphone(
          initialGame: widget.initialGame,
          initialPlatform: widget.initialPlatform,
        );
      case 'xbox':
      default:
        return XboxScreen(
          initialGame: widget.initialGame,
          initialPlatform: widget.initialPlatform,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initDone) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      KeyedSubtree(
        key: ValueKey(_selectedPlatformKey),
        child: _getPlatformScreen(),
      ),
      KeyedSubtree(
        key: ValueKey('search_${_selectedPlatformKey}'),
        child: SearchScreen(
          platform: _selectedPlatformKey ?? widget.initialPlatform,
        ),
      ),
      const Favorites(),
      SettingsScreen(
        onPlatformChanged: (newPlatform) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selectedPlatform', newPlatform);

          setState(() => _selectedPlatformKey = newPlatform);

          final recentProvider = context.read<RecentCheatsProvider>();
          await recentProvider.setPlatform(newPlatform);
        },
        onGameChanged: (newGame) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selectedGame', newGame);

          final gameProvider = context.read<GameProvider>();
          await gameProvider.setGame(newGame);
          CheatService.updateSelectedGame(newGame);

          final recentProvider = context.read<RecentCheatsProvider>();
          await recentProvider.setGame(newGame);

          setState(() {});
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Color.fromRGBO(13, 13, 13, 1),

      body: Stack(
        children: [
          screens[_selectedIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              backgroundColor: Colors.black,
              selectedItemColor: Colors.greenAccent,
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
              iconSize: 22,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: AppLocalizations.of(context)!.favoritesTitle,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: AppLocalizations.of(context)!.settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
