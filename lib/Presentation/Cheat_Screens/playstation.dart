import 'package:all_gta/Models/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:all_gta/ARAppKit/ARReview_Manager/ARReview_Manager.dart';
import 'package:all_gta/Models/cheat_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/Utils/code_mapper.dart';
import 'package:all_gta/Models/image_swiper.dart';
import 'package:all_gta/l10n/app_localizations.dart';

class Playstation extends StatefulWidget {
  const Playstation({super.key});

  @override
  State<Playstation> createState() => _PlaystationState();
}

class _PlaystationState extends State<Playstation> {
  List<CheatCode> _allCheats = [];
  bool _isLoading = true;
  Set<String> _favorites = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  static const String _prefsKey = 'favoriteCheats_playstation';
  String _selectedSection = 'All';
  List<String> _allSections = ['All'];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadCheats();
    _loadSelectedLanguage();
    ARReviewManager.startReviewRequestIfRequired(context);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  String _selectedLangCode = 'en';

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLangCode = prefs.getString('selectedLang') ?? 'en';
    });
  }

  String _localized(String fallback, CheatCode cheat, String fieldPrefix) {
    if (_selectedLangCode == 'en') return fallback;

    final translated = cheat.rawData['${fieldPrefix}_$_selectedLangCode'];

    if (translated != null && translated.toString().trim().isNotEmpty) {
      return translated.toString();
    }

    return fallback;
  }

  void _loadCheats() async {
    setState(() => _isLoading = true);

    final fresh = await CheatService.fetchPlaystationCheats(
      useCacheFirst: false,
    );

    if (!mounted) return;
    setState(() {
      _allCheats = fresh;
      _isLoading = false;

      final uniqueSections = fresh.map((e) => e.section).toSet().toList();

      uniqueSections.sort();

      _allSections = ['All', ...uniqueSections];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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

      if (_selectedSection != 'All' && cheat.section != _selectedSection) {
        continue;
      }

      groupedCheats.putIfAbsent(cheat.section, () => []).add(cheat);
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardAppearance: Brightness.dark,
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: "Search cheats by keyword or effect",
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(200, 196, 196, 1),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color.fromRGBO(200, 196, 196, 1),
                        size: 35,
                      ),
                      filled: true,
                      fillColor: AppColors.notSelectedbg,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(255, 255, 255, 0.1),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(255, 255, 255, 0.1),
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (_searchFocusNode.hasFocus || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: AppColors.primaryButton),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
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
                        color: Colors.greenAccent,
                      ),
                    )
                  : ListView(
                      children: [
                        ...groupedCheats.entries.map((entry) {
                          final cheats = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...cheats.map(
                                (cheat) => CheatCard(
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
                                  buttons: cheat.codes
                                      .split(',')
                                      .map((b) => b.trim())
                                      .toList(),
                                  isFavorite: _favorites.contains(cheat.title),
                                  onFavoriteToggle: (_) =>
                                      toggleFavorite(cheat.title),
                                  useImages: true,
                                  imageMapper: getPlaystationImagePath,
                                  onTap: () {
                                    final images = cheat.codes
                                        .split(',')
                                        .map(
                                          (code) => getPlaystationImagePath(
                                            code.trim(),
                                          ),
                                        )
                                        .toList();

                                    final codes = cheat.codes
                                        .split(',')
                                        .map(
                                          (code) => code.trim().toLowerCase(),
                                        )
                                        .toList();

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.black,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (_) => SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.6,
                                        child: SlidingImageViewer(
                                          imagePaths: images,
                                          codeTexts: codes,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
