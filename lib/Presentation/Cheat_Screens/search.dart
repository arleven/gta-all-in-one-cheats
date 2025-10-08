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

  @override
  void initState() {
    super.initState();
    _loadCheats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // schedule async work without breaking the callback signature
      Future.microtask(() async {
        await Provider.of<RecentCheatsProvider>(
          context,
          listen: false,
        ).setPlatform(widget.platform);
      });
    });
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
      _loadCheats();
    }
  }

  Future<void> _loadCheats() async {
    setState(() => _isLoading = true);
    List<CheatCode> cheats = [];
    switch (widget.platform.toLowerCase()) {
      case 'xbox':
        cheats = await CheatService.fetchXboxCheats();
        break;
      case 'playstation':
        cheats = await CheatService.fetchPlaystationCheats();
        break;
      case 'iphone':
        cheats = await CheatService.fetchIphoneCheats();
        break;
      case 'pc':
        cheats = await CheatService.fetchPcCheats();
        break;
      case 'phone':
      case 'phonenumbers':
        cheats = await CheatService.fetchPhoneNumCheats();
        break;
    }
    setState(() {
      _allCheats = cheats;
      _filteredCheats = [];
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCheats = [];
      } else {
        _filteredCheats = _allCheats.where((cheat) {
          return cheat.title.toLowerCase().contains(lowerQuery) ||
              cheat.description.toLowerCase().contains(lowerQuery) ||
              cheat.codes.toLowerCase().contains(lowerQuery) ||
              cheat.section.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  void _showBottomSheetWithImages(CheatCode cheat) {
    final codes = cheat.codes.split(',').map((c) => c.trim()).toList();

    String Function(String) imageMapper =
        widget.platform.toLowerCase() == 'xbox'
        ? getXboxImagePath
        : getPlaystationImagePath;

    final imagePaths = codes.map(imageMapper).toList();
    final codeTexts = codes;

    Provider.of<RecentCheatsProvider>(context, listen: false).addRecent(cheat);

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

  @override
  Widget build(BuildContext context) {
    return Consumer<RecentCheatsProvider>(
      builder: (context, recentProvider, child) {
        final recentCheats = recentProvider.recentCheats;

        print(recentCheats);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        keyboardAppearance: Brightness.dark,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.searchText,
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
                    if (_searchFocusNode.hasFocus || _searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          _searchFocusNode.unfocus();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.primaryButton),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchQuery.isEmpty
                      ? (recentCheats.isEmpty
                            ? const Center(
                                child: Text(
                                  'Search any cheats here',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      'Recently Viewed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  ...recentCheats.map((cheat) {
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

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: CheatCard(
                                        title: cheat.title,
                                        desc: cheat.description,
                                        phoneNum: cheat.phoneNum,
                                        buttons: cheat.codes
                                            .split(',')
                                            .map((b) => b.trim())
                                            .toList(),
                                        isFavorite: false,
                                        onFavoriteToggle: (_) {},
                                        useImages: useImages,
                                        imageMapper: imageMapper,
                                        onTap: useImages
                                            ? () => _showBottomSheetWithImages(
                                                cheat,
                                              )
                                            : null,
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ))
                      : _filteredCheats.isEmpty
                      ? Center(
                          child: Text(
                            'No cheats found for "$_searchQuery"',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredCheats.length,
                          itemBuilder: (context, index) {
                            final cheat = _filteredCheats[index];
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

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CheatCard(
                                title: cheat.title,
                                desc: cheat.description,
                                phoneNum: cheat.phoneNum,
                                buttons: cheat.codes
                                    .split(',')
                                    .map((b) => b.trim())
                                    .toList(),
                                isFavorite: false,
                                onFavoriteToggle: (_) {},
                                useImages: useImages,
                                imageMapper: imageMapper,
                                onTap: useImages
                                    ? () => _showBottomSheetWithImages(cheat)
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
