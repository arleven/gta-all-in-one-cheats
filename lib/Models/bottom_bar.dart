import 'package:all_gta/Presentation/Cheat_Screens/phone_num.dart';
import 'package:flutter/material.dart';
import 'package:all_gta/l10n/app_localizations.dart';
import 'package:all_gta/Presentation/Cheat_Screens/iphone.dart';
import 'package:all_gta/Presentation/Cheat_Screens/pc.dart';
import 'package:all_gta/Presentation/Cheat_Screens/playstation.dart';
import 'package:all_gta/Presentation/Settings_Screen/settings.dart';
import 'package:all_gta/Presentation/Cheat_Screens/xbox.dart';

import 'package:provider/provider.dart';
import 'package:all_gta/Presentation/Settings_Screen/game_provider.dart';
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
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadSavedGame();
    _selectedIndex = _getIndexForPlatform(widget.initialPlatform);
  }

  Future<void> _loadSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selectedGame');

    String defaultGame = 'sanandreas';

    if (saved == null || !gameKeys.contains(saved)) {
      setState(() {
        selectedGameKey = defaultGame;
      });
      _saveGame(defaultGame);
    } else {
      setState(() {
        selectedGameKey = saved;
      });
    }
  }

  Future<void> _saveGame(String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGame', gameKey);
  }

  int _getIndexForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'playstation':
        return 0;
      case 'pc':
        return 1;
      case 'xbox':
        return 2;
      case 'iphone':
        return 3;
      default:
        return 0;
    }
  }

  String selectedGameKey = 'sanandreas';
  final GlobalKey _gameTrailingKey = GlobalKey();

  final List<String> gameKeys = [
    'gtav',
    'sanandreas',
    'vicecity',
    'libertycity',
  ];

  Map<String, String> get localizedGames => {
    'gtav': 'GTA V',
    'sanandreas': 'San Andreas',
    'vicecity': 'Vice City',
    'libertycity': 'Liberty City',
  };

  List<String> get platformKeys => gamePlatforms[selectedGameKey] ?? [];

  String selectedPlatformKey = 'xbox';

  final Map<String, List<String>> gamePlatforms = {
    'sanandreas': ['playstation', 'xbox', 'pc', 'iphone'],
    'vicecity': ['playstation', 'xbox', 'pc', 'iphone'],
    'gtav': ['playstation', 'xbox', 'pc', 'iphone', 'stadia'],
    'libertycity': ['playstation', 'pc'],
  };

  void _showGameDropdown(BuildContext context) async {
    final RenderBox renderBox =
        _gameTrailingKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      color: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 1,
      ),
      items: List.generate(gameKeys.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const PopupMenuItem<String>(
            enabled: false,
            height: 1,
            child: Divider(height: 1, color: Colors.white24),
          );
        }

        final key = gameKeys[index ~/ 2];
        final game = localizedGames[key]!;

        return PopupMenuItem<String>(
          value: key,
          height: 50,
          child: Row(
            children: [
              if (selectedGameKey == key)
                const Icon(Icons.check, color: Colors.white, size: 20)
              else
                const SizedBox(width: 50),
              const SizedBox(width: 12),
              Text(
                game,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );

    if (selected != null) {
      context.read<GameProvider>().setGame(selected);

      final newPlatforms = gamePlatforms[selected] ?? [];
      final currentPlatform = _getPlatformForIndex(
        _selectedIndex,
        selectedGameKey,
      );

      int newIndex;
      if (newPlatforms.contains(currentPlatform)) {
        // Keep same platform if supported
        newIndex = _getIndexForPlatformInGame(currentPlatform, selected);
      } else {
        // Fallback to first available platform in new game
        newIndex = 0;
      }

      setState(() {
        selectedGameKey = selected;
        _selectedIndex = newIndex;
      });

      _saveGame(selected);
      _savePlatform(_getPlatformForIndex(_selectedIndex, selected));
    }
  }

  String _getPlatformForIndex(int index, String game) {
    final platforms = gamePlatforms[game] ?? [];
    if (index < platforms.length) return platforms[index];
    return platforms.isNotEmpty ? platforms.first : 'playstation';
  }

  int _getIndexForPlatformInGame(String platform, String game) {
    final platforms = gamePlatforms[game] ?? [];
    final idx = platforms.indexOf(platform);
    return idx == -1 ? 0 : idx;
  }

  Future<void> _savePlatform(String platformKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPlatform', platformKey);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final selectedGame = gameProvider.selectedGame;

    final screens = _getScreens(selectedGame);

    final items = _getBottomItems(selectedGame, context);

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: GestureDetector(
          key: _gameTrailingKey,
          onTap: () => _showGameDropdown(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizedGames[selectedGameKey]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),

      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }

  List<Widget> _getScreens(String game) {
    if (game == 'gtav') {
      return [
        Playstation(),
        Pc(),
        XboxScreen(),
        Iphone(),
        PhoneNum(),
        SettingsScreen(),
      ];
    } else if (game == 'libertycity') {
      return [Playstation(), Iphone(), SettingsScreen()];
    } else {
      return [Playstation(), Pc(), XboxScreen(), Iphone(), SettingsScreen()];
    }
  }

  List<BottomNavigationBarItem> _getBottomItems(
    String game,
    BuildContext context,
  ) {
    final local = AppLocalizations.of(context)!;
    if (game == 'gtav') {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: local.playstation,
        ),
        BottomNavigationBarItem(icon: Icon(Icons.computer), label: local.pc),
        BottomNavigationBarItem(
          icon: Icon(Icons.videogame_asset),
          label: local.xbox,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.phone_iphone),
          label: local.iphone,
        ),
        BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Phone'),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: local.settings,
        ),
      ];
    } else if (game == 'libertycity') {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: local.playstation,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.phone_iphone),
          label: local.iphone,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: local.settings,
        ),
      ];
    } else {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: local.playstation,
        ),
        BottomNavigationBarItem(icon: Icon(Icons.computer), label: local.pc),
        BottomNavigationBarItem(
          icon: Icon(Icons.videogame_asset),
          label: local.xbox,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.phone_iphone),
          label: local.iphone,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: local.settings,
        ),
      ];
    }
  }
}
