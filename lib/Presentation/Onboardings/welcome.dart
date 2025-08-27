import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Onboardings/experienced_screen.dart';
import 'package:all_gta/Presentation/Settings_Screen/webview_screen.dart';

class GtaWelcomeScreen extends StatefulWidget {
  const GtaWelcomeScreen({super.key});

  @override
  State<GtaWelcomeScreen> createState() => _GtaWelcomeScreenState();
}

class _GtaWelcomeScreenState extends State<GtaWelcomeScreen> {
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
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black, AppColors.bottomGradiant],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.85, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/welcome.png',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),

                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "Get ready to explore the streets of GTA\nlike never before.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 40),

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
                              builder: (ctx) => GtaExperienceScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                            text: "By tapping “Get Started”, you agree to our ",
                          ),
                          TextSpan(
                            text: "Terms of Use",
                            style: TextStyle(
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
                          TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
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
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
