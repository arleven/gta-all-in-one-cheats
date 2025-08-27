import 'package:flutter/material.dart';
import 'package:all_gta/ARAppKit/ARReview_Manager/ARReview_Manager.dart';
import 'package:all_gta/Models/image_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/Models/cheat_cards.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/Utils/code_mapper.dart';

import 'package:all_gta/l10n/app_localizations.dart';

class XboxScreen extends StatefulWidget {
  const XboxScreen({super.key});

  @override
  State<XboxScreen> createState() => _XboxScreenState();
}

class _XboxScreenState extends State<XboxScreen> {
  List<CheatCode> _allCheats = [];
  bool _isLoading = true;
  Set<String> _favorites = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  bool _isMounted = false;
  static const String _prefsKey = 'favoriteCheats';
  String _selectedSection = 'All';
  List<String> _allSections = ['All'];

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadFavorites();
    _loadSelectedLanguage();
    _loadCheats();

    //  _searchFocusNode.addListener(() {
    //   if (!_isMounted) return;
    //   setState(() {});
    // });

    ARReviewManager.startReviewRequestIfRequired(context);

    _refreshCheatsInBackground();

    _searchController.addListener(() {
      if (!_isMounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLangCode = prefs.getString('selectedLang') ?? 'en';
    });
  }

  void _loadCheats() async {
    setState(() => _isLoading = true);

    final fresh = await CheatService.fetchXboxCheats(useCacheFirst: false);

    if (!mounted) return;
    setState(() {
      _allCheats = fresh;
      _isLoading = false;
      _allSections = ['All', ...fresh.map((e) => e.section)];
    });
  }

  void _refreshCheatsInBackground() async {
    try {
      final fresh = await CheatService.fetchXboxCheats(useCacheFirst: false);
      if (_isMounted) {
        final sections = {'All', ...fresh.map((e) => e.section)};
        setState(() {
          _allCheats = fresh;
          _allSections = sections.toList();
        });
      }
    } catch (e) {
      print("Failed to refresh in background: $e");
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_prefsKey) ?? [];
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

  _showBottomSheetWithImages(CheatCode cheat) {
    final codes = cheat.codes.split(',').map((code) => code.trim()).toList();

    final imagePaths = codes.map((code) => getXboxImagePath(code)).toList();
    final codeTexts = codes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.5,
        child: SlidingImageViewer(imagePaths: imagePaths, codeTexts: codeTexts),
      ),
    );
  }

  String _selectedLangCode = 'en';

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCheats();
      }
    });
    final favoriteCheats = _allCheats
        .where((cheat) => _favorites.contains(cheat.title))
        .toList();

    final otherCheats = _allCheats
        .where((cheat) => !_favorites.contains(cheat.title))
        .toList();

    final groupedCheats = <String, List<CheatCode>>{};

    for (var cheat in otherCheats) {
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
                      filled: true,
                      fillColor: Colors.grey[900],
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: AppLocalizations.of(context)!.searchHint,

                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
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
                      style: TextStyle(color: Colors.greenAccent),
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
                        color: isSelected
                            ? Colors.greenAccent
                            : Colors.grey[850],
                        borderRadius: BorderRadius.circular(20),
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
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.w500,
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
                        if (_searchQuery.isEmpty ||
                            'favorites'.contains(_searchQuery)) ...[
                          if (favoriteCheats.isNotEmpty) ...[
                            Text(
                              AppLocalizations.of(context)!.favoritesTitle,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...favoriteCheats
                                .where(
                                  (cheat) => cheat.title.toLowerCase().contains(
                                    _searchQuery,
                                  ),
                                )
                                .map(
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
                                    isFavorite: _favorites.contains(
                                      cheat.title,
                                    ),
                                    onFavoriteToggle: (_) =>
                                        toggleFavorite(cheat.title),

                                    useImages: true,
                                    imageMapper: getXboxImagePath,
                                    onTap: () =>
                                        _showBottomSheetWithImages(cheat),
                                  ),
                                ),
                            const SizedBox(height: 24),
                          ],
                        ],
                        ...groupedCheats.entries.map((entry) {
                          final sectionName = _localized(
                            entry.key,
                            entry.value.first,
                            'section',
                          );

                          final cheats = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.label_important,
                                    color: Colors.greenAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    sectionName,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
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
                                  imageMapper: getXboxImagePath,
                                  onTap: () =>
                                      _showBottomSheetWithImages(cheat),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }),
                      ],
                    ),
            ),
            SizedBox(height: 20),
          ],
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
