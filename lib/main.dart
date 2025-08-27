import 'package:flutter/material.dart';
import 'package:all_gta/Presentation/Onboardings/splash_screen.dart';
import 'package:all_gta/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:all_gta/Presentation/Settings_Screen/game_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider()..loadGame(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selectedLang') ?? 'en';
    setState(() {
      _locale = Locale(langCode);
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (_locale != null) return _locale;
        if (deviceLocale != null) {
          for (var supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode &&
                (supported.countryCode == null ||
                    supported.countryCode == deviceLocale.countryCode)) {
              return supported;
            }
          }
        }
        return supportedLocales.first;
      },
      home: const SplashScreen(),
    );
  }
}
