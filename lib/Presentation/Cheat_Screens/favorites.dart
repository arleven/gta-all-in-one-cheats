import 'package:all_gta/Models/cheat_cards.dart';
import 'package:all_gta/Models/hidden_loc_card.dart';
import 'package:all_gta/Models/simple_cheat_viewer.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/Networking/hidden_location_model.dart';
import 'package:all_gta/Networking/hidden_location_service.dart';
import 'package:all_gta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/Utils/code_mapper.dart';
import 'package:all_gta/Models/image_swiper.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  Set<String> _favorites = {};
  List<CheatCode> _platformCheats = [];
  bool _isLoading = true;
  String _selectedPlatform = 'xbox';
  String _selectedLangCode = 'en';
  List<HiddenLocation> _hiddenLocations = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedPlatform();
    _loadSelectedGame();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLangCode = prefs.getString('selectedLang') ?? 'en';
    });
  }

  Future<void> _loadSelectedPlatform() async {
    final prefs = await SharedPreferences.getInstance();
    final platform = prefs.getString('selectedPlatform') ?? 'xbox';

    setState(() {
      _selectedPlatform = platform;
    });

    _loadFavorites();
  }

  Future<void> _loadSelectedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGame = prefs.getString('selectedGame') ?? 'sanandreas';
    CheatService.updateSelectedGame(savedGame);
    HiddenLocationService.updateHiddenSelectedGame(savedGame);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsKey = 'favoriteCheats_$_selectedPlatform';
    final savedList = prefs.getStringList(prefsKey) ?? [];

    List<CheatCode> platformCheats = [];
    List<HiddenLocation> hiddenLocations = [];

    switch (_selectedPlatform) {
      case 'xbox':
        platformCheats = await CheatService.fetchXboxCheats(
          useCacheFirst: true,
        );
        hiddenLocations = await HiddenLocationService.fetchXboxHiddenLocation();
        break;
      case 'playstation':
        platformCheats = await CheatService.fetchPlaystationCheats(
          useCacheFirst: true,
        );
        hiddenLocations =
            await HiddenLocationService.fetchPlaystationHiddenLocation();
        break;
      case 'pc':
        platformCheats = await CheatService.fetchPcCheats(useCacheFirst: true);
        hiddenLocations = await HiddenLocationService.fetchPcHiddenLocation();
        break;
      case 'iphone':
        platformCheats = await CheatService.fetchIphoneCheats(
          useCacheFirst: true,
        );
        hiddenLocations =
            await HiddenLocationService.fetchIphoneHiddenLocation();
        break;
    }

    final favoriteCheats = platformCheats
        .where((c) => savedList.contains(c.title))
        .toList();

    final favoriteHidden = hiddenLocations
        .where((h) => savedList.contains(h.title))
        .toList();

    setState(() {
      _favorites = savedList.toSet();
      _platformCheats = favoriteCheats;
      _hiddenLocations = favoriteHidden;
      _isLoading = false;
    });
  }

  void _toggleFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsKey = 'favoriteCheats_$_selectedPlatform';

    setState(() {
      if (_favorites.contains(title)) {
        _favorites.remove(title);
      } else {
        _favorites.add(title);
      }
    });

    await prefs.setStringList(prefsKey, _favorites.toList());
  }

  bool _shouldUseImages() {
    return _selectedPlatform == 'xbox' || _selectedPlatform == 'playstation';
  }

  String Function(String)? _getImageMapper() {
    if (!_shouldUseImages()) return null;

    switch (_selectedPlatform) {
      case 'xbox':
        return getXboxImagePath;
      case 'playstation':
        return getPlaystationImagePath;
      default:
        return getXboxImagePath;
    }
  }

  _showBottomSheetWithImages(CheatCode cheat) async {
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
            videourl: cheat.youtube,
            desc: cheat.description,
            title: cheat.title,
          ),
        ),
      ),
    );
  }

  _showHiddenLocationBottomSheet(HiddenLocation hidden) {
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
            videourl: hidden.videoUrl,
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
                videourl: cheat.youtube,
                desc: cheat.description,
                code: cheat.codes,
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      );
    }

    final favCheats = _platformCheats
        .where((c) => _favorites.contains(c.title))
        .toList();

    final favHidden = _hiddenLocations
        .where((h) => _favorites.contains(h.title))
        .toList();

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(bottom: 32),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              AppLocalizations.of(context)!.favoritesTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            if (favCheats.isEmpty && favHidden.isEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Text(
                    "No favorites ${_selectedPlatform.toUpperCase()}",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              if (favCheats.isNotEmpty) ...[
                Text(
                  "Cheat Codes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                ...favCheats.map(
                  (cheat) => CheatCard(
                    title: _localized(cheat.title, cheat, 'title'),
                    desc: _localized(cheat.description, cheat, 'description'),
                    buttons: cheat.codes
                        .split(',')
                        .map((b) => b.trim())
                        .toList(),
                    isFavorite: _favorites.contains(cheat.title),
                    onFavoriteToggle: (_) => _toggleFavorite(cheat.title),
                    useImages: _shouldUseImages(),
                    imageMapper: _getImageMapper(),
                    onTap: () {
                      if (_selectedPlatform == 'iphone' ||
                          _selectedPlatform == 'pc') {
                        _showBottomSheetSimple(cheat);
                      } else {
                        _showBottomSheetWithImages(cheat);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (favHidden.isNotEmpty) ...[
                Text(
                  "Hidden Locations",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                ...favHidden.map(
                  (hidden) => HiddenLocationCard(
                    title: hidden.title,
                    desc: hidden.desc,
                    isFavorite: _favorites.contains(hidden.title),
                    onFavoriteToggle: (_) => _toggleFavorite(hidden.title),
                    onTap: () => _showHiddenLocationBottomSheet(hidden),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
