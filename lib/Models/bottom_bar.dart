import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/Presentation/Cheat_Screens/favorites.dart';
import 'package:all_gta/Presentation/Cheat_Screens/iphone.dart';
import 'package:all_gta/Presentation/Cheat_Screens/pc.dart';
import 'package:all_gta/Presentation/Cheat_Screens/playstation.dart';

import 'package:all_gta/Presentation/Cheat_Screens/xbox.dart';
import 'package:all_gta/l10n/app_localizations.dart';

import 'package:flutter/material.dart';

import 'package:all_gta/Presentation/Settings_Screen/settings.dart';
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
  String? _selectedPlatformKey;
  List<String> _allowedGames = [];
  bool _initDone = false;

  final Map<String, String> _localizedGames = const {
    'gtav': 'GTA V',
    'sanandreas': 'San Andreas',
    'vicecity': 'Vice City',
    'libertycity': 'Liberty City',
  };

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();

    _allowedGames = prefs.getStringList('selectedGames') ?? ['sanandreas'];

    _selectedPlatformKey =
        prefs.getString('selectedPlatform') ?? widget.initialPlatform;
    final savedPlatform = prefs.getString('selectedPlatform');
    print('Saved platform in prefs: $savedPlatform');
    print('Initial platform: ${widget.initialPlatform}');
    print(_selectedPlatformKey);

    final gameProvider = context.read<GameProvider>();
    await gameProvider.loadGame();

    var currentGame = gameProvider.selectedGame.isNotEmpty
        ? gameProvider.selectedGame
        : widget.initialGame;

    if (!_allowedGames.contains(currentGame)) {
      currentGame = _allowedGames.first;
      await gameProvider.setGame(currentGame);
    }

    CheatService.updateSelectedGame(currentGame);

    setState(() {
      _initDone = true;
    });
  }

  Widget _getPlatformScreen() {
    switch (_selectedPlatformKey) {
      case 'playstation':
        return Playstation();
      case 'pc':
        return Pc();
      case 'iphone':
        return Iphone();
      case 'xbox':
      default:
        return XboxScreen();
    }
  }

  final Map<String, String> _platformLabels = const {
    'playstation': 'Playstation',
    'pc': 'PC',
    'xbox': 'Xbox',
    'iphone': 'iPhone',
  };
  OverlayEntry? _dropdownOverlay;

  void _showGameDropdown(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox =
        _gameTrailingKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    _dropdownOverlay = OverlayEntry(
      builder: (context) {
        final currentGame = context.read<GameProvider>().selectedGame;

        return Positioned(
          top: offset.dy + renderBox.size.height,
          left: 12,
          width: screenWidth - 24,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.grey[700]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < _allowedGames.length; i++) ...[
                    InkWell(
                      onTap: () async {
                        final gameProvider = context.read<GameProvider>();
                        await gameProvider.setGame(_allowedGames[i]);

                        _removeDropdown();
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _localizedGames[_allowedGames[i]]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (currentGame == _allowedGames[i])
                              Icon(Icons.check, color: AppColors.primaryButton),
                          ],
                        ),
                      ),
                    ),

                    if (i < _allowedGames.length - 1)
                      Divider(height: 1, color: Colors.grey[700]),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_dropdownOverlay!);
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
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
      _getPlatformScreen(),
      Favorites(),
      SettingsScreen(
        onPlatformChanged: (newPlatform) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selectedPlatform', newPlatform);
          setState(() => _selectedPlatformKey = newPlatform);
        },
        onGameChanged: (newGame) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selectedGame', newGame);

          final gameProvider = context.read<GameProvider>();
          await gameProvider.setGame(newGame);

          // Important: keep CheatService in sync
          CheatService.updateSelectedGame(newGame);

          setState(() {});
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Color.fromRGBO(13, 13, 13, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 13, 13, 1),
        elevation: 0,
        centerTitle: false,
        title: () {
          if (_selectedIndex == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _platformLabels[_selectedPlatformKey] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                GestureDetector(
                  key: _gameTrailingKey,
                  onTap: () => _showGameDropdown(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(
                      Icons.videogame_asset,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            );
          } else if (_selectedIndex == 1) {
            return Text(
              AppLocalizations.of(context)!.favoritesTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            );
          } else {
            return Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            );
          }
        }(),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.bottomGradiant, Colors.transparent],
              stops: [0.0, 1.0],
            ),
          ),
        ),
      ),

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
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: "Fav",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Settings",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
