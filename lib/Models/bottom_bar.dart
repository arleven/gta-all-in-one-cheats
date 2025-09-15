import 'package:flutter/material.dart';
import 'package:all_gta/Presentation/Cheat_Screens/xbox.dart';
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
  String _selectedPlatformKey = 'xbox';
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

    final gameProvider = context.read<GameProvider>();
    await gameProvider.loadGame();
    var currentGame = gameProvider.selectedGame.isNotEmpty
        ? gameProvider.selectedGame
        : widget.initialGame;

    if (!_allowedGames.contains(currentGame)) {
      currentGame = _allowedGames.first;
      await gameProvider.setGame(currentGame);
    }

    await prefs.setString('selectedPlatform', _selectedPlatformKey);

    setState(() {
      _initDone = true;
    });
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
      await gameProvider.setGame(selected);

      setState(() {});
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
      XboxScreen(),
      Center(
        child: Text(
          "Favorites Screen",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  _selectedPlatformKey.toUpperCase(),
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
              child: const Icon(Icons.arrow_drop_down, color: Colors.white),
            ),
          ],
        ),
      ),

      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: "Xbox",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Fav"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
