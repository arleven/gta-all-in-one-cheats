import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Networking/cheat_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:all_gta/Presentation/Settings_Screen/webview_screen.dart';
import 'package:all_gta/l10n/app_localizations.dart';
import 'package:all_gta/main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:all_gta/Provider/recent_cheat.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<String>? onPlatformChanged;
  final ValueChanged<String>? onGameChanged;
  const SettingsScreen({super.key, this.onPlatformChanged, this.onGameChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //MARK: Variables

  String _version = '';
  String _selectedLangCode = 'en';

  List<String> get platformKeys {
    if (selectedGameKey == 'libertycity') {
      return ['playstation'];
    }
    return gamePlatforms[selectedGameKey] ?? [];
  }

  Map<String, String> get localizedPlatforms => {
    'playstation': AppLocalizations.of(context)!.playstation,
    'xbox': AppLocalizations.of(context)!.xbox,
    'pc': AppLocalizations.of(context)!.pc,
    'iphone': AppLocalizations.of(context)!.iphone,
  };

  String selectedPlatformKey = 'xbox';

  final Map<String, List<String>> gamePlatforms = {
    'sanandreas': ['playstation', 'xbox', 'pc', 'iphone'],
    'vicecity': ['playstation', 'xbox', 'pc', 'iphone'],
    'gtav': ['playstation', 'xbox', 'pc', 'iphone'],
    'libertycity': ['playstation'],
  };

  final GlobalKey _trailingKey = GlobalKey();

  final List<String> gameKeys = [
    'gtav',
    'sanandreas',
    'vicecity',
    'libertycity',
  ];

  Map<String, String> get localizedGames => {
    'gtav': 'GTA V',
    'sanandreas': 'San Andreas',
    'vicecity': 'Vice City',
    'libertycity': 'Liberty City',
  };

  String selectedGameKey = 'sanandreas';

  //MARK: Custom Methods

  void openWebView(BuildContext context, String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WebViewFullScreen(url: url),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _savePlatform(String platformKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPlatform', platformKey);
  }

  Future<void> _saveGame(String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGame', gameKey);
  }

  late List<String> allowedGames = [];

  Future<void> _loadSelectedGames() async {
    final prefs = await SharedPreferences.getInstance();
    allowedGames = prefs.getStringList('selectedGames') ?? gameKeys;

    final savedGame = prefs.getString('selectedGame');
    setState(() {
      if (savedGame != null && allowedGames.contains(savedGame)) {
        selectedGameKey = savedGame;
      } else if (allowedGames.isNotEmpty) {
        selectedGameKey = allowedGames.first;
      }
    });
    CheatService.updateSelectedGame(selectedGameKey);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedPlatform();
      _loadSelectedLangCode();
      _loadVersion();
      _loadSelectedGames();
    });
  }

  Future<void> _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _loadSelectedLangCode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selectedLang');
    setState(() {
      _selectedLangCode = saved ?? 'en';
    });
  }

  Future<void> _loadSavedPlatform() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selectedPlatform');

    String defaultPlatform = 'xbox';

    if (allowedGames.length == 1 && allowedGames.first == 'libertycity') {
      defaultPlatform = 'playstation';
    }

    if (saved == null || !platformKeys.contains(saved)) {
      setState(() {
        selectedPlatformKey = defaultPlatform;
      });
      _savePlatform(defaultPlatform);
    } else {
      setState(() {
        selectedPlatformKey = saved;
      });
    }
  }

  void _showGameDropdown(BuildContext context) async {
    if (allowedGames.length == 1) return;

    await showModalBottomSheet<String>(
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

            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              AppLocalizations.of(context)!.selectGame,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            for (int i = 0; i < allowedGames.length; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final selected = allowedGames[i];

                  setState(() {
                    selectedGameKey = selected;

                    if (selected == 'libertycity') {
                      selectedPlatformKey = 'playstation';
                      _savePlatform('playstation');
                      widget.onPlatformChanged?.call('playstation');
                    } else {
                      if (!gamePlatforms[selected]!.contains(
                        selectedPlatformKey,
                      )) {
                        selectedPlatformKey = gamePlatforms[selected]!.first;
                        _savePlatform(selectedPlatformKey);
                        widget.onPlatformChanged?.call(selectedPlatformKey);
                      }
                    }
                  });

                  _saveGame(selected);
                  CheatService.updateSelectedGame(selected);

                  final recentProvider = context.read<RecentCheatsProvider>();
                  await recentProvider.setGame(selected);

                  widget.onGameChanged?.call(selected);
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
                    color: selectedGameKey == allowedGames[i]
                        ? const Color.fromRGBO(31, 69, 50, 1)
                        : const Color.fromRGBO(42, 40, 40, 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedGameKey == allowedGames[i]
                          ? const Color.fromRGBO(31, 164, 106, 1)
                          : const Color.fromRGBO(76, 72, 72, 1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizedGames[allowedGames[i]] ??
                            allowedGames[i].capitalize(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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

  void _showPlatformDropdown(BuildContext context) async {
    if (platformKeys.length == 1) return;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      color: const Color.fromRGBO(0, 0, 0, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color.fromRGBO(102, 102, 102, 0.49), width: 1),
      ),
      position: RelativeRect.fromLTRB(12, kToolbarHeight + 20, 12, 0),
      constraints: BoxConstraints(
        minWidth: overlay.size.width - 24,
        maxWidth: overlay.size.width - 24,
      ),
      items: List.generate(platformKeys.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const PopupMenuItem<String>(
            enabled: false,
            height: 1,
            child: Divider(
              height: 1,
              color: Color.fromRGBO(102, 102, 102, 0.49),
            ),
          );
        }

        final key = platformKeys[index ~/ 2];
        final platform = localizedPlatforms[key] ?? key.capitalize();

        return PopupMenuItem<String>(
          value: key,
          height: 60,

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset(
                  _getPlatformImage(key),
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    platform,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (selectedPlatformKey == key)
                  Icon(Icons.check, color: AppColors.primaryButton, size: 20),
              ],
            ),
          ),
        );
      }),
    );

    if (selected != null) {
      setState(() => selectedPlatformKey = selected);
      _savePlatform(selected);
      widget.onPlatformChanged?.call(selected);
    }
  }

  String _getPlatformImage(String key) {
    switch (key.toLowerCase()) {
      case "xbox":
        return "assets/images/xbox_icon.png";
      case "pc":
        return "assets/images/pc_icon.png";
      case "playstation":
        return "assets/images/play_icon.png";
      case "iphone":
        return "assets/images/iphone_icon.png";
      default:
        return "assets/images/xbox_icon.png";
    }
  }

  //MARK: Build Method
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(bottom: 32),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                // ------------------ APP SETTINGS ------------------
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'App Settings',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Card(
                  color: const Color.fromRGBO(35, 35, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: SettingsTile(
                      imagePath: 'assets/images/platform_icon.png',
                      title: AppLocalizations.of(context)!.platformTitle,
                      subtitle: AppLocalizations.of(context)!.platformSubtitle,
                      trailingText: localizedPlatforms[selectedPlatformKey],
                      onTap: () {},
                      onTrailingTap: () => _showPlatformDropdown(context),
                      trailingKey: _trailingKey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color.fromRGBO(35, 35, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: SettingsTile(
                      imagePath: 'assets/images/platform_icon.png',
                      title: AppLocalizations.of(context)!.gameTitle,
                      subtitle: AppLocalizations.of(context)!.gameSubtitle,
                      trailingText: localizedGames[selectedGameKey],
                      onTap: () {},
                      onTrailingTap: () => _showGameDropdown(context),
                    ),
                  ),
                ),

                // ------------------ CHECK OUR OTHER APPS ------------------
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Check Our Other Apps',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                AppCard(
                  imageUrl: 'assets/images/welcome.png',
                  title: 'Glow light',
                  subtitle: 'Helps in glowing lights',
                  rating: 5,
                  ratingCount: 5,
                  developer: 'Axebox',
                  category: 'category',
                  onTap: () {
                    print('tapped appcard');
                  },
                ),

                // ------------------ SETTINGS ------------------
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Settings',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Card(
                  color: const Color.fromRGBO(35, 35, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: SettingsTile(
                      imagePath: 'assets/images/contact_icon.png',
                      title: AppLocalizations.of(context)!.contactMeTitle,
                      subtitle: AppLocalizations.of(context)!.contactMeSubtitle,
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'info@arleven.com',
                          query: Uri.encodeFull(
                            'subject=Cheats for SA&body=Hi, I would like to share...',
                          ),
                        );

                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.couldNotOpenMailApp,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color.fromRGBO(35, 35, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: SettingsTile(
                      imagePath: 'assets/images/privacy_icon.png',
                      title: AppLocalizations.of(context)!.privacyPolicyTitle,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.privacyPolicySubtitle,
                      onTap: () {
                        openWebView(
                          context,
                          'https://arleven.com/projects/ALL%20GTA%20Cheats/privacy',
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color.fromRGBO(35, 35, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: SettingsTile(
                      imagePath: 'assets/images/terms_icon.png',
                      title: AppLocalizations.of(context)!.termsOfServiceTitle,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.privacyPolicySubtitle,
                      onTap: () {
                        openWebView(
                          context,
                          'https://arleven.com/projects/ALL%20GTA%20Cheats/tnc',
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color.fromRGBO(35, 35, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: SettingsTile(
                      imagePath: 'assets/images/language_icon.png',
                      title: AppLocalizations.of(context)!.changeLanguageTitle,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.changeLanguageSubtitle,
                      onTap: () => _showLanguageBottomSheet(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color.fromRGBO(35, 35, 35, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: SettingsTile(
                      imagePath: 'assets/images/contact_icon.png',
                      title: AppLocalizations.of(context)!.version,
                      subtitle: AppLocalizations.of(context)!.version_subtitle,
                      trailingText: _version,
                      trailingPlain: true,
                      onTap: () {},
                    ),
                  ),
                ),

                // ------------------ INFO ------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.infoText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSelectedLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLang', langCode);

    if (!mounted) return;

    final locale = langCode.contains('_')
        ? Locale(langCode.split('_')[0], langCode.split('_')[1])
        : Locale(langCode);

    await Future(() => MyApp.setLocale(context, locale));

    if (mounted) {
      await _loadSavedPlatform();
      print(_selectedLangCode);
    }
  }

  void _showLanguageBottomSheet(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selectedLang') ?? 'en';

    setState(() {
      _selectedLangCode = saved;
    });

    final Map<String, Map<String, String>> languages = {
      'en': {'label': 'English', 'native': 'English'},
      'ar': {'label': 'Arabic', 'native': 'عربي'},
      'zh': {'label': 'Chinese (Simplified)', 'native': '简体中文'},
      'fr': {'label': 'French', 'native': 'Français'},
      'de': {'label': 'German', 'native': 'Deutsch'},
      'hi': {'label': 'Hindi', 'native': 'हिंदी'},
      'it': {'label': 'Italian', 'native': 'Italiano'},
      'ja': {'label': 'Japanese', 'native': '日本語'},
      'ko': {'label': 'Korean', 'native': '한국인'},
      'pt': {'label': 'Portuguese (Brazil)', 'native': 'Português (Brasil)'},
      'fil': {'label': 'Filipino', 'native': 'Filipino'},
      'ms': {'label': 'Malay', 'native': 'Bahasa Melayu'},
      'pl': {'label': 'Polish', 'native': 'Polski'},
      'ru': {'label': 'Russian', 'native': 'Русский'},
      'es': {'label': 'Spanish', 'native': 'Español'},
      'th': {'label': 'Thai', 'native': 'ไทย'},
      'tr': {'label': 'Turkish', 'native': 'Türkçe'},
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(13, 13, 13, 1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.changeLanguageTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.78,
                                color: Color.fromRGBO(148, 148, 148, 1),
                              ),
                              color: Color.fromRGBO(32, 31, 31, 1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    color: Color.fromRGBO(150, 150, 150, 0.21),
                    height: 1,
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: languages.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Colors.white24),
                      itemBuilder: (context, index) {
                        final entry = languages.entries.toList()[index];
                        final code = entry.key;
                        final label = entry.value['label']!;
                        final native = entry.value['native']!;
                        final isSelected = _selectedLangCode == code;

                        return InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            await _updateSelectedLanguage(code);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.languageChangedMessage(label),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _getFlagEmoji(code),
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          color: Color.fromRGBO(
                                            238,
                                            238,
                                            238,
                                            1,
                                          ),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        native,
                                        style: const TextStyle(
                                          color: Color.fromRGBO(
                                            184,
                                            181,
                                            181,
                                            1,
                                          ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: AppColors.primaryButton,
                                    size: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getFlagEmoji(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'ar':
        return '🇸🇦';
      case 'zh':
        return '🇨🇳';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'hi':
        return '🇮🇳';
      case 'it':
        return '🇮🇹';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'pt':
        return '🇧🇷';
      case 'fil':
        return '🇵🇭';
      case 'ms':
        return '🇲🇾';
      case 'pl':
        return '🇵🇱';
      case 'ru':
        return '🇷🇺';
      case 'es':
        return '🇪🇸';
      case 'th':
        return '🇹🇭';
      case 'tr':
        return '🇹🇷';
      default:
        return '🌐';
    }
  }
}

class SettingsTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailingText;
  final VoidCallback? onTrailingTap;
  final Key? trailingKey;
  final bool trailingPlain;

  const SettingsTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
    this.onTrailingTap,
    this.trailingKey,
    this.trailingPlain = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: 2),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: Image.asset(
          imagePath,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailingText != null
          ? trailingPlain
                ? Text(
                    trailingText!,
                    style: const TextStyle(
                      color: AppColors.primaryButton,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : GestureDetector(
                    key: trailingKey,
                    onTap: onTrailingTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(105, 240, 174, 0.17),
                            ),
                            color: const Color.fromRGBO(5, 241, 139, 0.23),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            trailingText!,
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 255, 130, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Image.asset(
                          'assets/images/dropdown_arrow.png',
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  )
          : null,
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

//MARK:- App Card Class

class AppCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final double rating;
  final int ratingCount;
  final String developer;
  final String category;
  final String buttonText;
  final VoidCallback onTap;

  const AppCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.ratingCount,
    required this.developer,
    required this.category,
    this.buttonText = "Get",
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(35, 35, 35, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Column(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: AppColors.primaryButton,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Free",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
