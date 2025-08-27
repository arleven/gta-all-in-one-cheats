import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Onboardings/platform_selection.dart';
import 'package:all_gta/Presentation/Settings_Screen/webview_screen.dart';
import 'package:flutter/gestures.dart';

class GoToCheatsScreen extends StatefulWidget {
  const GoToCheatsScreen({super.key});

  @override
  State<GoToCheatsScreen> createState() => _GoToCheatsScreenState();
}

class _GoToCheatsScreenState extends State<GoToCheatsScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.asset("assets/videos/onboarding_ani.mov")
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
            _controller.setLooping(true);
            _controller.setVolume(0);
          });
  }

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),

                  const Text(
                    'Save Your Go-To Cheats',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Tag your favourites for quick access later.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

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
                            builder: (ctx) => const PlatformSelectionScreen(),
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

                  const SizedBox(height: 12),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                      children: [
                        TextSpan(
                          text:
                              "We won’t share this information with anyone. Go to GTA cheat code’s ",
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
