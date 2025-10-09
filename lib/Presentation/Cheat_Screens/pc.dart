import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Cheat_Screens/rate_unlock.dart';
import 'package:flutter/material.dart';
import 'package:all_gta/ARAppKit/ARReview_Manager/ARReview_Manager.dart';
import 'package:all_gta/Models/cheat_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:all_gta/Provider/recent_cheat.dart';
import 'dart:convert';
import 'package:all_gta/Provider/game_provider.dart';

class Pc extends StatefulWidget {
  final String initialGame;
  final String initialPlatform;
  const Pc({
    super.key,
    required this.initialGame,
    required this.initialPlatform,
  });

  @override
  State<Pc> createState() => _PcState();
}

class _PcState extends State<Pc> {
  List<CheatCode> _allCheats = [];
  bool _isLoading = true;
  Set<String> _favorites = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  static const String _prefsKey = 'favoriteCheats_pc';
  String? _selectedSection;
  bool _isMounted = false;
  List<String> _allSections = [];
  final Set<String> _lockedSections = {'Weapons', 'Vehicle'};
  bool _hasReviewedUnlocked = false;
  static const String _reviewUnlockKey = 'unlockedReviewed';
  final GlobalKey _gameTrailingKey = GlobalKey();
  List<String> _allowedGames = [];
  bool _initDone = false;
  String? _selectedPlatformKey;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _isMounted = true;
    print(_initDone);
    _loadReviewUnlockStatus();
    _loadCheats();
    _loadSelectedLanguage();
    _loadSelectedGame();
    _bootstrap();

    ARReviewManager.startReviewRequestIfRequired(context);
    _refreshCheatsInBackground();

    _searchController.addListener(() {
      if (!_isMounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadSelectedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGame = prefs.getString('selectedGame') ?? 'sanandreas';
    CheatService.updateSelectedGame(
      savedGame,
    ); // <- tell CheatService which game
  }

  Future<void> _loadReviewUnlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasReviewedUnlocked = prefs.getBool(_reviewUnlockKey) ?? false;
    });
  }

  String _selectedLangCode = 'en';

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLangCode = prefs.getString('selectedLang') ?? 'en';
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadCheats() async {
    setState(() => _isLoading = true);

    final fresh = await CheatService.fetchPcCheats(useCacheFirst: false);

    if (!mounted) return;
    setState(() {
      _allCheats = fresh;
      _isLoading = false;

      final uniqueSections = fresh.map((e) => e.section).toSet().toList();
      uniqueSections.sort();

      _allSections = uniqueSections;

      if (_allSections.isNotEmpty &&
          (_selectedSection == null ||
              !_allSections.contains(_selectedSection))) {
        _selectedSection = _allSections.first;
      }
    });
  }

  void _refreshCheatsInBackground() async {
    try {
      final fresh = await CheatService.fetchPcCheats(useCacheFirst: false);
      if (_isMounted) {
        final sections = fresh.map((e) => e.section).toSet().toList();
        sections.sort();
        setState(() {
          _allCheats = fresh;
          _allSections = sections;

          if (_allSections.isNotEmpty &&
              (_selectedSection == null ||
                  !_allSections.contains(_selectedSection))) {
            _selectedSection = _allSections.first;
          }
        });
      }
    } catch (e) {
      print("Failed to refresh in background: $e");
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_prefsKey) ?? [];

    if (!mounted) return;
    setState(() {
      _favorites = savedList.toSet();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _favorites.toList());
  }

  void toggleFavorite(String title) {
    setState(() {
      if (_favorites.contains(title)) {
        _favorites.remove(title);
      } else {
        _favorites.add(title);
      }
    });
    _saveFavorites();
  }

  final Map<String, String> _localizedGames = const {
    'gtav': 'GTA V',
    'sanandreas': 'San Andreas',
    'vicecity': 'Vice City',
    'libertycity': 'Liberty City',
  };

  Future<void> saveRecentCheat(
    BuildContext context,
    CheatCode cheat,
    String platform,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final game = prefs.getString('selectedGame') ?? 'sanandreas';
    final key = 'recentCheats_${game.toLowerCase()}_${platform.toLowerCase()}';

    List<Map<String, dynamic>> recents = [];

    final stored = prefs.getString(key);
    if (stored != null) {
      recents = List<Map<String, dynamic>>.from(jsonDecode(stored));
    }

    recents.removeWhere((c) => c['title'] == cheat.title);
    recents.insert(0, {
      'title': cheat.title,
      'description': cheat.description,
      'codes': cheat.codes,
      'section': cheat.section,
      'platform': platform,
    });

    if (recents.length > 15) recents = recents.sublist(0, 15);

    await prefs.setString(key, jsonEncode(recents));

    final provider = Provider.of<RecentCheatsProvider>(context, listen: false);
    provider.loadRecentCheats();
  }

  void _showGameBottomSheet(BuildContext context) {
    final currentGame = context.read<GameProvider>().selectedGame;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(42, 40, 40, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            buildDragHandle(),

            const SizedBox(height: 8),

            Text(
              AppLocalizations.of(context)!.selectGame,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            for (int i = 0; i < _allowedGames.length; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('selectedGame', _allowedGames[i]);

                  final gameProvider = context.read<GameProvider>();
                  await gameProvider.setGame(_allowedGames[i]);

                  CheatService.updateSelectedGame(_allowedGames[i]);

                  final recentProvider = context.read<RecentCheatsProvider>();
                  await recentProvider.setGame(_allowedGames[i]);

                  setState(() {});
                  Navigator.pop(context);
                },

                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: currentGame == _allowedGames[i]
                        ? const Color.fromRGBO(31, 69, 50, 1)
                        : const Color.fromRGBO(42, 40, 40, 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentGame == _allowedGames[i]
                          ? const Color.fromRGBO(31, 164, 106, 1)
                          : const Color.fromRGBO(76, 72, 72, 1),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _localizedGames[_allowedGames[i]]!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 45),
          ],
        );
      },
    );
  }

  Widget buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 4,
        width: 40,
        decoration: BoxDecoration(
          color: Color.fromRGBO(76, 72, 72, 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
    final recentProvider = context.read<RecentCheatsProvider>();
    await recentProvider.setGame(currentGame);

    setState(() {
      _initDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCheats();
      }
    });

    final groupedCheats = <String, List<CheatCode>>{};

    for (var cheat in _allCheats) {
      if (_searchQuery.isNotEmpty &&
          !cheat.title.toLowerCase().contains(_searchQuery)) {
        continue;
      }

      if (_selectedSection != null && cheat.section != _selectedSection) {
        continue;
      }

      groupedCheats.putIfAbsent(cheat.section, () => []).add(cheat);
    }

    if (!_initDone) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryButton),
        ),
      );
    }

    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PC',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                    ),
                  ),
                  GestureDetector(
                    key: _gameTrailingKey,
                    onTap: () => _showGameBottomSheet(context),
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
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _allSections.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final section = _allSections[index];
                    final isSelected = section == _selectedSection;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSection = section;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.4,
                            color: isSelected
                                ? AppColors.shadowBorder
                                : Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                          color: isSelected
                              ? AppColors.primaryButton
                              : AppColors.notSelectedbg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _localized(
                            section,
                            _allCheats.firstWhere(
                              (c) => c.section == section,
                              orElse: () => CheatCode(
                                title: '',
                                section: section,
                                description: '',
                                codes: '',
                                rawData: {},
                              ),
                            ),
                            'section',
                          ),
                          style: TextStyle(
                            color: isSelected
                                ? Color.fromRGBO(4, 4, 4, 1)
                                : Color.fromRGBO(200, 196, 196, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryButton,
                        ),
                      )
                    : ListView(
                        children: [
                          ...groupedCheats.entries.map((entry) {
                            final cheats = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...cheats.map((cheat) {
                                  final isLocked =
                                      _lockedSections.contains(entry.key) &&
                                      !_hasReviewedUnlocked;

                                  if (isLocked) {
                                    return Card(
                                      color: AppColors.notSelectedbg,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _localized(
                                                cheat.title,
                                                cheat,
                                                'title',
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const ReviewToUnlcock(),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(
                                                      31,
                                                      69,
                                                      50,
                                                      1,
                                                    ),
                                                    border: Border.all(
                                                      width: 1.8,
                                                      color:
                                                          const Color.fromRGBO(
                                                            31,
                                                            164,
                                                            106,
                                                            1,
                                                          ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.unlock,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return CheatCard(
                                    title: _localized(
                                      cheat.title,
                                      cheat,
                                      'title',
                                    ),
                                    desc: _localized(
                                      cheat.description,
                                      cheat,
                                      'description',
                                    ),
                                    phoneNum: cheat.phoneNum,
                                    buttons: cheat.codes
                                        .split(',')
                                        .map((b) => b.trim())
                                        .toList(),
                                    isFavorite: _favorites.contains(
                                      cheat.title,
                                    ),
                                    onFavoriteToggle: (_) =>
                                        toggleFavorite(cheat.title),
                                    useImages: false,
                                    onTap: () {
                                      saveRecentCheat(context, cheat, 'pc');
                                    },
                                  );
                                }),
                                SizedBox(height: 40),
                              ],
                            );
                          }),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localized(String fallback, CheatCode cheat, String fieldPrefix) {
    if (_selectedLangCode == 'en') return fallback;

    final translated = cheat.rawData['${fieldPrefix}_$_selectedLangCode'];

    if (translated != null && translated.toString().trim().isNotEmpty) {
      return translated.toString();
    }

    return fallback;
  }
}
