import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Onboardings/review_onboard.dart';
import 'package:flutter/material.dart';
import 'package:all_gta/Presentation/Settings_Screen/webview_screen.dart';
import 'package:flutter/gestures.dart';

class SelectCategory extends StatefulWidget {
  const SelectCategory({super.key});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final List<Map<String, dynamic>> categories = [
    {
      'image': 'assets/images/fun_onb.png',
      'title': 'Player',
      'selected': false,
    },
    {
      'image': 'assets/images/gun_onb.png',
      'title': 'Weapons',
      'selected': false,
    },
    {
      'image': 'assets/images/world_onb.png',
      'title': 'World',
      'selected': false,
    },
    {
      'image': 'assets/images/car_onb.png',
      'title': 'Vehicle',
      'selected': false,
    },
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Choose Your\nFavorite Categories",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Tailor your cheat code experience. We'll make your favorite types easier to find.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(200, 196, 196, 1),
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 1.4,
                  letterSpacing: 0.32,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white12, height: 1),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Image.asset(item['image'], height: 24, width: 24),
                    title: Text(
                      item['title'],
                      style: const TextStyle(
                        color: Color.fromRGBO(222, 222, 222, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.32,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        item['selected']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: item['selected']
                            ? AppColors.primaryButton
                            : Colors.white38,
                      ),
                      onPressed: () {
                        setState(() {
                          item['selected'] = !item['selected'];
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        item['selected'] = !item['selected'];
                      });
                    },
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => ReviewOnboard()),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.white60, fontSize: 11),
                children: [
                  const TextSpan(
                    text:
                        "We won't share this information with anyone. Go to GTA cheat codes's ",
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
                          'https://arleven.com/projects/ALL%20GTA%20Cheats/tnc',
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
                          'https://arleven.com/projects/ALL%20GTA%20Cheats/privacy',
                        );
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
