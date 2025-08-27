import 'package:flutter/material.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Onboardings/find_hidden_cheats.dart';
import 'package:all_gta/Presentation/Settings_Screen/webview_screen.dart';
import 'package:flutter/gestures.dart';

class GtaExperienceScreen extends StatefulWidget {
  const GtaExperienceScreen({super.key});

  @override
  State<GtaExperienceScreen> createState() => _GtaExperienceScreenState();
}

class _GtaExperienceScreenState extends State<GtaExperienceScreen> {
  String selected = 'No';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0E0E0E),
              Color(0xFF0E0E0E),
              AppColors.bottomGradiant,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.85, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Have you ever tried\nother GTA apps?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),

                Center(
                  child: Text(
                    'Tell us about your past experiences to\nenhance your journey.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                buildOption('Yes'),
                const SizedBox(height: 16),
                buildOption('No'),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (ctx) => HiddenCheatsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                    children: [
                      TextSpan(
                        text:
                            "We won’t share this information with anyone. Go to GTA cheat code’s ",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 11,
                        ),
                      ),
                      TextSpan(
                        text: "Terms of Use",

                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w300,
                          fontSize: 11,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            openWebView(
                              context,
                              'https://arleven.com/projects/ALL%20GTA%20Cheats/tnc',
                            );
                          },
                      ),
                      TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w300,
                          fontSize: 11,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            openWebView(
                              context,
                              'https://arleven.com/projects/ALL%20GTA%20Cheats/privacy',
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOption(String label) {
    bool isSelected = selected == label;
    return GestureDetector(
      onTap: () => setState(() => selected = label),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(119, 119, 119, 1)
              : const Color.fromRGBO(60, 57, 57, 1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00FF9D), size: 35)
            else
              const Icon(
                Icons.circle_outlined,
                color: Colors.white30,
                size: 35,
              ),
          ],
        ),
      ),
    );
  }
}
