import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/Models/cheat_cards.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/l10n/app_localizations.dart';
import 'package:all_gta/ARAppKit/ARReview_Manager/ARReview_Manager.dart';

class PhoneNum extends StatefulWidget {
  const PhoneNum({super.key});

  @override
  State<PhoneNum> createState() => _PhoneNumState();
}

class _PhoneNumState extends State<PhoneNum> {
  List<CheatCode> _allCheats = [];
  bool _isLoading = true;
  Set<String> _favorites = {};
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  static const String _prefsKey = 'favoriteCheats_phoneNum';
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

    final fresh = await CheatService.fetchPhoneNumCheats(useCacheFirst: false);

    if (!mounted) return;
    setState(() {
      _allCheats = fresh;
      _isLoading = false;
      _allSections = ['All', ...fresh.map((e) => e.section)];
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
            const SizedBox(height: 16),
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
                                    buttons: [cheat.codes.trim()],
                                    isFavorite: _favorites.contains(
                                      cheat.title,
                                    ),
                                    onFavoriteToggle: (_) =>
                                        toggleFavorite(cheat.title),
                                    useImages: false,
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
                                children: const [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: Colors.purpleAccent,
                                  ),
                                  SizedBox(width: 8),
                                ],
                              ),
                              Text(
                                sectionName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  buttons: [cheat.codes.trim()],
                                  isFavorite: _favorites.contains(cheat.title),
                                  onFavoriteToggle: (_) =>
                                      toggleFavorite(cheat.title),
                                  useImages: false,
                                ),
                              ),
                              const SizedBox(height: 24),
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
