import 'package:flutter/material.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Onboardings/adventure_screen.dart';
import 'package:all_gta/Presentation/Settings_Screen/webview_screen.dart';
import 'package:flutter/gestures.dart';

class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState extends State<ExperienceSelectionScreen> {
  int selectedIndex = 0;

  final List<String> imagePaths = [
    'assets/images/beginner_card.png',
    'assets/images/casual_card.png',
    'assets/images/expert_card.png',
  ];

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
        width: double.infinity,
        height: double.infinity,
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          "Choose your\nexperience level",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "We’ll tailor your gameplay assistant based on your style.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),

                      ...List.generate(imagePaths.length, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedIndex == index
                                    ? Colors.greenAccent
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(imagePaths[index]),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 100),
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
                                builder: (ctx) => const ChooseAdventureScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "We won’t share this information with anyone. Go to GTA cheat code’s ",
                              ),
                              TextSpan(
                                text: "Terms of Use",
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    openWebView(
                                      context,
                                      'https://arleven.com/projects/San%20Andreas/tnc',
                                    );
                                  },
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    openWebView(
                                      context,
                                      'https://arleven.com/projects/San%20Andreas/privacy',
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
