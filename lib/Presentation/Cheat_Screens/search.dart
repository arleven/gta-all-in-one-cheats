import 'package:flutter/material.dart';
import 'package:all_gta/Networking/cheat_codes_model.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:all_gta/Models/cheat_cards.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Utils/code_mapper.dart';
import 'package:all_gta/Models/image_swiper.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  List<Map<String, dynamic>> _recentCheats = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCheats();
    _loadRecentCheats();
  }

  Future<void> _loadRecentCheats() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('recentCheats') ?? [];
    setState(() {
      _recentCheats = list
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
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
    }
    setState(() {
      _allCheats = cheats;
      _isLoading = false;
      _filteredCheats = [];
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

  void _openCheat(Map<String, dynamic> cheatData) async {
    final cheat = CheatCode(
      title: cheatData['title'],
      description: cheatData['description'],
      codes: cheatData['codes'],
      section: '',
      rawData: {},
    );

    String platform = cheatData['platform'];
    Function(String)? mapper;
    if (platform == 'xbox') mapper = getXboxImagePath;
    if (platform == 'playstation') mapper = getPlaystationImagePath;

    final codes = cheat.codes.split(',').map((e) => e.trim()).toList();
    final List<String> imagePaths = mapper != null
        ? codes.map((e) => mapper!(e).toString()).toList()
        : <String>[];

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

  @override
  Widget build(BuildContext context) {
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
                    decoration: InputDecoration(
                      hintText: 'Search cheats',
                      filled: true,
                      fillColor: AppColors.notSelectedbg,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
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
                  : _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildRecentSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredCheats.isEmpty) {
      return Center(
        child: Text(
          'No cheats found for "$_searchQuery"',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: _filteredCheats.length,
      itemBuilder: (context, index) {
        final cheat = _filteredCheats[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CheatCard(
            title: cheat.title,
            desc: cheat.description,
            buttons: cheat.codes.split(',').map((e) => e.trim()).toList(),
            isFavorite: false,
            onFavoriteToggle: (_) {},
          ),
        );
      },
    );
  }

  Widget _buildRecentSection() {
    if (_recentCheats.isEmpty) {
      return const Center(
        child: Text(
          'Search any cheats here',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12, left: 4),
          child: Text(
            'Recent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ..._recentCheats.map((data) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CheatCard(
              title: data['title'],
              desc: data['description'],
              buttons: data['codes'].split(',').map((b) => b.trim()).toList(),
              isFavorite: false,
              onFavoriteToggle: (_) {},
              onTap: () => _openCheat(data),
              useImages: ['xbox', 'playstation'].contains(data['platform']),
              imageMapper: data['platform'] == 'xbox'
                  ? getXboxImagePath
                  : data['platform'] == 'playstation'
                  ? getPlaystationImagePath
                  : null,
            ),
          );
        }).toList(),
      ],
    );
  }
}
