import 'package:flutter/material.dart';
import 'package:all_gta/Presentation/Onboardings/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/Models/bottom_bar.dart';
import 'package:all_gta/Networking/other_app_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //MARK:- Method
  @override
  void initState() {
    super.initState();
    _initNotificationsAndNavigate();
  }

  Future<void> _initNotificationsAndNavigate() async {
    await OtherAppsService.fetchOtherApps();

    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    String? savedGame = prefs.getString('selectedGame') ?? 'sanandreas';
    String? savedPlatform =
        prefs.getString('selectedPlatform') ?? 'playstation';

    if (!mounted) return;

    if (isFirstLaunch) {
      await prefs.setBool('is_first_launch', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GtaWelcomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BottomBars(
            initialGame: savedGame,
            initialPlatform: savedPlatform,
          ),
        ),
      );
    }
  }

  //MARK:- Build Methods
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/splash_image.png'),
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
