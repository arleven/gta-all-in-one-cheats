import 'package:flutter/material.dart';
import 'package:all_gta/Presentation/Onboardings/platform_selection.dart';
import 'package:video_player/video_player.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Settings_Screen/webview_screen.dart';
import 'package:flutter/gestures.dart';

class HiddenCheatsScreen extends StatefulWidget {
  const HiddenCheatsScreen({super.key});

  @override
  State<HiddenCheatsScreen> createState() => _HiddenCheatsScreenState();
}

class _HiddenCheatsScreenState extends State<HiddenCheatsScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/videos/onboarding1_ani.mov')
          ..initialize().then((_) {
            _controller.setLooping(true);
            _controller.setVolume(0);
            _controller.play();
            setState(() {});
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
        children: [
          if (_controller.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Center(
                    child: Text(
                      'Unlock Hidden Cheats',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tap to reveal rare spawn codes.',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
