import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:all_gta/Presentation/Settings_Screen/webview_screen.dart';
import 'package:all_gta/l10n/app_localizations.dart';
import 'package:all_gta/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //MARK: Variables

  List<String> get platformKeys {
    if (allowedGames.length == 1 && allowedGames.first == 'libertycity') {
      return ['playstation']; // Force PlayStation only
    }
    return gamePlatforms[selectedGameKey] ?? [];
  }

  Map<String, String> get localizedPlatforms => {
    'playstation': AppLocalizations.of(context)!.playstation,
    'xbox': AppLocalizations.of(context)!.xbox,
    'pc': AppLocalizations.of(context)!.pc,
    'iphone': AppLocalizations.of(context)!.iphone,
    'stadia': 'Phone Number',
  };

  String selectedPlatformKey = 'xbox';

  final Map<String, List<String>> gamePlatforms = {
    'sanandreas': ['playstation', 'xbox', 'pc', 'iphone'],
    'vicecity': ['playstation', 'xbox', 'pc', 'iphone'],
    'gtav': ['playstation', 'xbox', 'pc', 'iphone', 'stadia'],
    'libertycity': ['playstation', 'pc'],
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

  late List<String> allowedGames = [];

  Future<void> _loadSelectedGames() async {
    final prefs = await SharedPreferences.getInstance();
    allowedGames = prefs.getStringList('selectedGames') ?? gameKeys;

    setState(() {
      if (allowedGames.length == 1 && allowedGames.first == 'libertycity') {
        selectedGameKey = 'libertycity';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedPlatform();
      _loadSelectedLangCode();

      _loadSelectedGames();
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

  void _showPlatformDropdown(BuildContext context) async {
    if (platformKeys.length == 1) {
      // Do nothing if only one option
      return;
    }
    final RenderBox renderBox =
        _trailingKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      color: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 1,
      ),
      items: List.generate(platformKeys.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const PopupMenuItem<String>(
            enabled: false,
            height: 1,
            child: Divider(height: 1, color: Colors.white24),
          );
        }

        final key = platformKeys[index ~/ 2];
        final platform = localizedPlatforms[key] ?? key.capitalize();

        return PopupMenuItem<String>(
          value: key,
          height: 50,
          child: Row(
            children: [
              if (selectedPlatformKey == key)
                const Icon(Icons.check, color: Colors.white, size: 20)
              else
                const SizedBox(width: 50),
              const SizedBox(width: 12),
              Text(
                platform,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );

    if (selected != null) {
      setState(() {
        selectedPlatformKey = selected;
      });
      _savePlatform(selected);
    }
  }

  //MARK: Build Method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          SectionHeader(title: AppLocalizations.of(context)!.userSettings),

          Card(
            color: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: SettingsTile(
                icon: Icons.videogame_asset,
                iconColor: Colors.purpleAccent,
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

          SectionHeader(title: AppLocalizations.of(context)!.contactSection),

          Card(
            color: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: SettingsTile(
                icon: Icons.email_outlined,
                iconColor: Colors.lightBlueAccent,
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
                          AppLocalizations.of(context)!.couldNotOpenMailApp,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          SectionHeader(
            title: AppLocalizations.of(context)!.informationSection,
          ),

          Card(
            color: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.greenAccent,
                    title: AppLocalizations.of(context)!.privacyPolicyTitle,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.privacyPolicySubtitle,
                    onTap: () {
                      openWebView(
                        context,
                        'https://arleven.com/projects/San%20Andreas/privacy',
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  SettingsTile(
                    icon: Icons.article_outlined,
                    iconColor: Colors.orangeAccent,
                    title: AppLocalizations.of(context)!.termsOfServiceTitle,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.privacyPolicySubtitle,
                    onTap: () {
                      openWebView(
                        context,
                        'https://arleven.com/projects/San%20Andreas/tnc',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          SectionHeader(title: AppLocalizations.of(context)!.languageSection),

          Card(
            color: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: SettingsTile(
                icon: Icons.email_outlined,
                iconColor: Colors.lightBlueAccent,
                title: AppLocalizations.of(context)!.changeLanguageTitle,
                subtitle: AppLocalizations.of(context)!.changeLanguageSubtitle,
                onTap: () => _showLanguageBottomSheet(context),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _selectedLangCode = 'en';

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
                color: Colors.black,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          AppLocalizations.of(context)!.changeLanguageTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
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
                                isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : const SizedBox(width: 20),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      native,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailingText;
  final VoidCallback? onTrailingTap;
  final Key? trailingKey;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
    this.onTrailingTap,
    this.trailingKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      trailing: trailingText != null
          ? GestureDetector(
              key: trailingKey,
              onTap: onTrailingTap,
              child: Text(
                trailingText!,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
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
