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
  final GlobalKey _gameTrailingKey = GlobalKey();

  int _selectedIndex = 0;
  String _selectedPlatformKey = 'playstation';
  List<String> _allowedGames = [];
  bool _initDone = false;

  final Map<String, String> _localizedGames = const {
    'gtav': 'GTA V',
    'sanandreas': 'San Andreas',
    'vicecity': 'Vice City',
    'libertycity': 'Liberty City',
  };

  final Map<String, List<String>> _platformTabsByGame = const {
    'gtav': ['playstation', 'pc', 'xbox', 'iphone'],
    'sanandreas': ['playstation', 'pc', 'xbox', 'iphone'],
    'vicecity': ['playstation', 'pc', 'xbox', 'iphone'],
    'libertycity': ['playstation'],
  };

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();

    _allowedGames = prefs.getStringList('selectedGames') ?? ['sanandreas'];

    final gameProvider = context.read<GameProvider>();
    await gameProvider.loadGame();
    var currentGame = gameProvider.selectedGame.isNotEmpty
        ? gameProvider.selectedGame
        : widget.initialGame;

    if (!_allowedGames.contains(currentGame)) {
      currentGame = _allowedGames.first;
      await gameProvider.setGame(currentGame);
    }

    final savedPlatform = prefs.getString('selectedPlatform');
    String desiredPlatform =
        (widget.initialPlatform.isNotEmpty
                ? widget.initialPlatform
                : (savedPlatform ?? 'playstation'))
            .toLowerCase();

    final platformsForGame =
        _platformTabsByGame[currentGame] ?? const ['playstation'];
    if (!platformsForGame.contains(desiredPlatform)) {
      desiredPlatform = platformsForGame.first;
    }
    _selectedPlatformKey = desiredPlatform;

    _selectedIndex = _indexForPlatformInTabs(currentGame, _selectedPlatformKey);

    await _savePlatform(_selectedPlatformKey);

    setState(() {
      _initDone = true;
    });
  }

  Future<void> _savePlatform(String platformKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPlatform', platformKey);
  }

  List<String> _platformOrderInTabs(String game) {
    return _platformTabsByGame[game] ?? const ['playstation'];
  }

  int _indexForPlatformInTabs(String game, String platform) {
    final order = _platformOrderInTabs(game);
    final idx = order.indexOf(platform);
    return idx >= 0 ? idx : 0;
  }

  String? _platformKeyForIndex(String game, int index) {
    final order = _platformOrderInTabs(game);
    if (index >= 0 && index < order.length) return order[index];
    return null;
  }

  Future<void> _showGameDropdown(BuildContext context) async {
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
      items: List.generate(_allowedGames.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const PopupMenuItem<String>(
            enabled: false,
            height: 1,
            child: Divider(height: 1, color: Colors.white24),
          );
        }

        final key = _allowedGames[index ~/ 2];
        final game = _localizedGames[key]!;

        final isCurrent = context.read<GameProvider>().selectedGame == key;

        return PopupMenuItem<String>(
          value: key,
          height: 50,
          child: Row(
            children: [
              if (isCurrent)
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
      final gameProvider = context.read<GameProvider>();
      final previousPlatform = _selectedPlatformKey;
      final newPlatforms = _platformOrderInTabs(selected);

      final nextPlatform = newPlatforms.contains(previousPlatform)
          ? previousPlatform
          : newPlatforms.first;

      await gameProvider.setGame(selected);
      await _savePlatform(nextPlatform);

      setState(() {
        _selectedPlatformKey = nextPlatform;
        _selectedIndex = _indexForPlatformInTabs(selected, nextPlatform);
      });
    }
  }

  List<Widget> _getScreens(String game) {
    final platformTabs = _platformOrderInTabs(game);
    final screens = <Widget>[];

    for (final tab in platformTabs) {
      switch (tab) {
        case 'playstation':
          screens.add(Playstation());
          break;
        case 'pc':
          screens.add(Pc());
          break;
        case 'xbox':
          screens.add(XboxScreen());
          break;
        case 'iphone':
          screens.add(Iphone());
          break;
      }
    }

    if (game == 'gtav') {
      screens.add(PhoneNum());
    }
    screens.add(SettingsScreen());

    return screens;
  }

  List<BottomNavigationBarItem> _getBottomItems(
    String game,
    BuildContext context,
  ) {
    final local = AppLocalizations.of(context)!;
    final items = <BottomNavigationBarItem>[];

    final platformTabs = _platformOrderInTabs(game);
    for (final tab in platformTabs) {
      switch (tab) {
        case 'playstation':
          items.add(
            BottomNavigationBarItem(
              icon: const Icon(Icons.sports_esports),
              label: local.playstation,
            ),
          );
          break;
        case 'pc':
          items.add(
            BottomNavigationBarItem(
              icon: const Icon(Icons.computer),
              label: local.pc,
            ),
          );
          break;
        case 'xbox':
          items.add(
            BottomNavigationBarItem(
              icon: const Icon(Icons.videogame_asset),
              label: local.xbox,
            ),
          );
          break;
        case 'iphone':
          items.add(
            BottomNavigationBarItem(
              icon: const Icon(Icons.phone_iphone),
              label: local.iphone,
            ),
          );
          break;
      }
    }

    if (game == 'gtav') {
      items.add(
        const BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Phone'),
      );
    }
    items.add(
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: local.settings,
      ),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (!_initDone) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gameProvider = context.watch<GameProvider>();
    final selectedGameKey = gameProvider.selectedGame;

    final screens = _getScreens(selectedGameKey);
    final items = _getBottomItems(selectedGameKey, context);

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
                _localizedGames[selectedGameKey] ?? selectedGameKey,
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
        onTap: (index) async {
          setState(() => _selectedIndex = index);

          final maybePlatform = _platformKeyForIndex(selectedGameKey, index);
          if (maybePlatform != null) {
            _selectedPlatformKey = maybePlatform;
            await _savePlatform(_selectedPlatformKey);
          }
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
