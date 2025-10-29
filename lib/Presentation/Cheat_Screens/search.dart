import 'package:all_gta/Models/hidden_loc_card.dart';
import 'package:all_gta/Models/simple_cheat_viewer.dart';
import 'package:all_gta/Networking/hidden_location_model.dart';
import 'package:all_gta/Networking/hidden_location_service.dart';
import 'package:all_gta/Presentation/Cheat_Screens/rate_unlock.dart';
import 'package:flutter/material.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/Models/cheat_cards.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Utils/code_mapper.dart';
import 'package:all_gta/Models/image_swiper.dart';
import 'package:all_gta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:all_gta/Provider/recent_cheat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  final String platform;
  const SearchScreen({super.key, required this.platform});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<CheatCode> _allCheats = [];
  List<CheatCode> _filteredCheats = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Set<String> _favorites = {};
  static const String _prefsKeyPrefix = 'favoriteCheats_';
  final List<String> _lockedSections = ['Weapons', 'Vehicle'];
  bool _hasReviewedUnlocked = false;
  List<HiddenLocation> _allHiddenLocations = [];
  List<HiddenLocation> _filteredHiddenLocations = [];

  @override
  void initState() {
    super.initState();
    _loadCheats();
    _loadUnlockStatus();
    _loadFavorites();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        await Provider.of<RecentCheatsProvider>(
          context,
          listen: false,
        ).setPlatform(widget.platform);
      });
    });
  }

  Future<void> _loadUnlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasReviewedUnlocked = prefs.getBool('hasReviewedUnlocked') ?? false;
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsKeyPrefix${widget.platform.toLowerCase()}';
    final savedList = prefs.getStringList(key) ?? [];
    setState(() {
      _favorites = savedList.toSet();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsKeyPrefix${widget.platform.toLowerCase()}';
    await prefs.setStringList(key, _favorites.toList());
  }

  void _toggleFavorite(String title) async {
    setState(() {
      if (_favorites.contains(title)) {
        _favorites.remove(title);
      } else {
        _favorites.add(title);
      }
    });
    await _saveFavorites();
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.platform != widget.platform) {
      final recentProvider = Provider.of<RecentCheatsProvider>(
        context,
        listen: false,
      );
      recentProvider.setPlatform(widget.platform);
      recentProvider.loadRecentHiddenLocations();
      _loadCheats();
    }
  }

  Future<void> _loadCheats() async {
    setState(() => _isLoading = true);
    List<CheatCode> cheats = [];
    List<HiddenLocation> hidden = [];

    switch (widget.platform.toLowerCase()) {
      case 'xbox':
        cheats = await CheatService.fetchXboxCheats(useCacheFirst: true);
        hidden = await HiddenLocationService.fetchXboxHiddenLocation();
        break;
      case 'playstation':
        cheats = await CheatService.fetchPlaystationCheats(useCacheFirst: true);
        hidden = await HiddenLocationService.fetchPlaystationHiddenLocation();
        break;
      case 'iphone':
        cheats = await CheatService.fetchIphoneCheats(useCacheFirst: true);
        hidden = await HiddenLocationService.fetchIphoneHiddenLocation();
        break;
      case 'pc':
        cheats = await CheatService.fetchPcCheats(useCacheFirst: true);
        hidden = await HiddenLocationService.fetchPcHiddenLocation();
        break;
    }

    setState(() {
      _allCheats = cheats;
      _allHiddenLocations = hidden;
      _filteredCheats = [];
      _filteredHiddenLocations = [];
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCheats = [];
        _filteredHiddenLocations = [];
      } else {
        _filteredCheats = _allCheats.where((cheat) {
          return cheat.title.toLowerCase().contains(lowerQuery) ||
              cheat.description.toLowerCase().contains(lowerQuery) ||
              cheat.codes.toLowerCase().contains(lowerQuery) ||
              cheat.section.toLowerCase().contains(lowerQuery);
        }).toList();

        _filteredHiddenLocations = _allHiddenLocations.where((hidden) {
          return hidden.title.toLowerCase().contains(lowerQuery) ||
              hidden.desc.toLowerCase().contains(lowerQuery) ||
              hidden.section.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  _showBottomSheetWithImages(CheatCode cheat) async {
    debugPrint('🧩 Opening bottom sheet for: ${cheat.title}');
    debugPrint('🎬 Video URL: ${cheat.youtube}');
    debugPrint('📝 Description: ${cheat.description}');
    debugPrint('💾 Code: ${cheat.codes}');
    final codes = cheat.codes.split(',').map((code) => code.trim()).toList();
    final imagePaths = codes.map((code) => getXboxImagePath(code)).toList();
    final codeTexts = codes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SlidingImageViewer(
            imagePaths: imagePaths,
            codeTexts: codeTexts,
            videourl: 'https://www.youtube.com/watch?v=ks_0L3kHwn8',
            desc: cheat.description,
            title: cheat.title,
          ),
        ),
      ),
    );
  }

  _showHiddenLocationBottomSheet(HiddenLocation hidden) {
    debugPrint('🧩 Opening bottom sheet for: ${hidden.title}');
    debugPrint('🎬 Video URL: ${hidden.videourl}');
    debugPrint('📝 Description: ${hidden.desc}');
    debugPrint('💾 Code: ${hidden.section}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.60,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),

          child: SimpleCheatViewer(
            videourl: 'https://www.youtube.com/watch?v=ks_0L3kHwn8',
            desc: hidden.desc,
            title: hidden.title,
          ),
        ),
      ),
    );
  }

  _showBottomSheetSimple(CheatCode cheat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SimpleCheatViewer(
                title: cheat.title,
                videourl: 'https://www.youtube.com/watch?v=ks_0L3kHwn8',
                desc: cheat.description,
                code: cheat.codes,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecentCheatsProvider>(
      builder: (context, recentProvider, child) {
        final recentCheats = recentProvider.recentCheats;

        return SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchChanged,
                              keyboardAppearance: Brightness.dark,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                )!.searchText,
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(200, 196, 196, 1),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color.fromRGBO(200, 196, 196, 1),
                                  size: 30,
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
                          if (_searchFocusNode.hasFocus ||
                              _searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                                _searchFocusNode.unfocus();
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.primaryButton,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_searchQuery.isEmpty)
                        (recentCheats.isEmpty &&
                                recentProvider.recentHiddenLocations.isEmpty)
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: const Center(
                                  child: Text(
                                    'Search any cheats here',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (recentCheats.isNotEmpty) ...[
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        'Recent Cheat Codes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    ...recentCheats.map((cheat) {
                                      bool useImages =
                                          widget.platform.toLowerCase() ==
                                              'playstation' ||
                                          widget.platform.toLowerCase() ==
                                              'xbox';
                                      String Function(String)? imageMapper;
                                      if (widget.platform.toLowerCase() ==
                                          'playstation') {
                                        imageMapper = getPlaystationImagePath;
                                      } else if (widget.platform
                                              .toLowerCase() ==
                                          'xbox') {
                                        imageMapper = getXboxImagePath;
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: CheatCard(
                                          title: cheat.title,
                                          desc: cheat.description,
                                          phoneNum: cheat.phoneNum,
                                          buttons: cheat.codes
                                              .split(',')
                                              .map((b) => b.trim())
                                              .toList(),
                                          isFavorite: _favorites.contains(
                                            cheat.title,
                                          ),
                                          onFavoriteToggle: (_) =>
                                              _toggleFavorite(cheat.title),
                                          useImages: useImages,
                                          imageMapper: imageMapper,
                                          onTap: () {
                                            if (widget.platform == 'iphone' ||
                                                widget.platform == 'pc') {
                                              _showBottomSheetSimple(cheat);
                                            } else {
                                              _showBottomSheetWithImages(cheat);
                                            }
                                          },
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 30),
                                  ],

                                  if (recentProvider
                                      .recentHiddenLocations
                                      .isNotEmpty) ...[
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        'Recent Hidden Locations',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    ...recentProvider.recentHiddenLocations.map((
                                      loc,
                                    ) {
                                      final isLocked =
                                          _lockedSections.contains(
                                            loc['section'],
                                          ) &&
                                          !_hasReviewedUnlocked;

                                      if (isLocked) {
                                        return Card(
                                          color: AppColors.notSelectedbg,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                                  loc['title'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(
                                                        context,
                                                      ).push(
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
                                                        color:
                                                            const Color.fromRGBO(
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
                                                        style: const TextStyle(
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

                                      return HiddenLocationCard(
                                        title: loc['title'] ?? '',
                                        desc: loc['desc'] ?? '',
                                        isFavorite: _favorites.contains(
                                          loc['title'],
                                        ),
                                        onFavoriteToggle: (_) =>
                                            _toggleFavorite(loc['title']),
                                        onTap: () {
                                          _showHiddenLocationBottomSheet(
                                            HiddenLocation(
                                              title: loc['title'] ?? '',
                                              desc: loc['desc'] ?? '',
                                              videourl: loc['videourl'] ?? '',
                                              section: loc['section'],
                                              rawData: loc,
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ],
                                ],
                              )
                      else if (_filteredCheats.isEmpty &&
                          _filteredHiddenLocations.isEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Text(
                              'No cheats found for "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_filteredCheats.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Cheat Codes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ..._filteredCheats.map((cheat) {
                                bool useImages =
                                    widget.platform.toLowerCase() ==
                                        'playstation' ||
                                    widget.platform.toLowerCase() == 'xbox';

                                String Function(String)? imageMapper;
                                if (widget.platform.toLowerCase() ==
                                    'playstation') {
                                  imageMapper = getPlaystationImagePath;
                                } else if (widget.platform.toLowerCase() ==
                                    'xbox') {
                                  imageMapper = getXboxImagePath;
                                }

                                final isLocked =
                                    _lockedSections.contains(cheat.section) &&
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
                                            cheat.title,
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
                                                    color: const Color.fromRGBO(
                                                      31,
                                                      164,
                                                      106,
                                                      1,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.unlock,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
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
                                } else {
                                  return CheatCard(
                                    title: cheat.title,
                                    desc: cheat.description,
                                    phoneNum: cheat.phoneNum,
                                    buttons: cheat.codes
                                        .split(',')
                                        .map((b) => b.trim())
                                        .toList(),
                                    isFavorite: _favorites.contains(
                                      cheat.title,
                                    ),
                                    onFavoriteToggle: (_) =>
                                        _toggleFavorite(cheat.title),
                                    useImages: useImages,
                                    imageMapper: imageMapper,
                                    onTap: () {
                                      if (widget.platform == 'iphone' ||
                                          widget.platform == 'pc') {
                                        _showBottomSheetSimple(cheat);
                                      } else {
                                        _showBottomSheetWithImages(cheat);
                                      }
                                    },
                                  );
                                }
                              }),
                              const SizedBox(height: 20),
                            ],

                            if (_filteredHiddenLocations.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Hidden Locations',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ..._filteredHiddenLocations.map((hidden) {
                                final isLocked =
                                    _lockedSections.contains(hidden.section) &&
                                    !_hasReviewedUnlocked;

                                if (isLocked) {
                                  return Card(
                                    color: AppColors.notSelectedbg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hidden.title,
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
                                                    color: const Color.fromRGBO(
                                                      31,
                                                      164,
                                                      106,
                                                      1,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.unlock,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
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

                                return HiddenLocationCard(
                                  title: hidden.title,
                                  desc: hidden.desc,
                                  isFavorite: _favorites.contains(hidden.title),
                                  onFavoriteToggle: (_) =>
                                      _toggleFavorite(hidden.title),
                                  onTap: () =>
                                      _showHiddenLocationBottomSheet(hidden),
                                );
                              }),
                            ],
                          ],
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
