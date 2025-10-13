import 'package:all_gta/Models/cheat_cards.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:all_gta/Networking/cheat_service.dart';
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
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsKey = 'favoriteCheats_$_selectedPlatform';
    final savedList = prefs.getStringList(prefsKey) ?? [];

    List<CheatCode> platformCheats = [];

    switch (_selectedPlatform) {
      case 'xbox':
        platformCheats = await CheatService.fetchXboxCheats(
          useCacheFirst: true,
        );
        break;
      case 'playstation':
        platformCheats = await CheatService.fetchPlaystationCheats(
          useCacheFirst: true,
        );
        break;
      case 'pc':
        platformCheats = await CheatService.fetchPcCheats(useCacheFirst: true);
        break;
      case 'iphone':
        platformCheats = await CheatService.fetchIphoneCheats(
          useCacheFirst: true,
        );
        break;
      default:
        platformCheats = await CheatService.fetchXboxCheats(
          useCacheFirst: true,
        );
    }

    setState(() {
      _favorites = savedList.toSet();
      _platformCheats = platformCheats;
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

  VoidCallback? _getOnTapAction(CheatCode cheat) {
    if (!_shouldUseImages()) return null;

    return () {
      final codes = cheat.codes.split(',').map((code) => code.trim()).toList();
      final imagePaths = codes.map((code) => _getImageMapper()!(code)).toList();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.black87,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.5,
          child: SlidingImageViewer(
            imagePaths: imagePaths,
            codeTexts: codes,
            title: cheat.title,
            videourl: cheat.youtube,
          ),
        ),
      );
    };
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
            const SizedBox(height: 8),

            if (favCheats.isEmpty)
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
            else
              ...favCheats.map((cheat) {
                return CheatCard(
                  title: _localized(cheat.title, cheat, 'title'),
                  desc: _localized(cheat.description, cheat, 'description'),
                  buttons: cheat.codes.split(',').map((b) => b.trim()).toList(),
                  isFavorite: _favorites.contains(cheat.title),
                  onFavoriteToggle: (_) => _toggleFavorite(cheat.title),
                  useImages: _shouldUseImages(),
                  imageMapper: _getImageMapper(),
                  onTap: _getOnTapAction(cheat),
                );
              }),
          ],
        ),
      ),
    );
  }
}
