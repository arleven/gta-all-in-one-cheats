import 'package:flutter/material.dart';
import 'package:all_gta/Models/bottom_bar.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewOnboard extends StatefulWidget {
  const ReviewOnboard({super.key});

  @override
  State<ReviewOnboard> createState() => _ReviewOnboardState();
}

class _ReviewOnboardState extends State<ReviewOnboard> {
  int selectedStars = 5;

  Future<void> _showReviewAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final inAppReview = InAppReview.instance;
    String? savedGame = prefs.getString('selectedGame') ?? 'sanandreas';
    String? savedPlatform = prefs.getString('selectedPlatform') ?? 'pc';

    // Save that user clicked Rate
    await prefs.setBool('userClickedRate', true);

    if (await inAppReview.isAvailable()) {
      // Await until the system attempts to show review popup
      await inAppReview.requestReview();
    } else {
      // Optional: open store listing or do nothing
      // await inAppReview.openStoreListing(appStoreId: 'YOUR_IOS_APP_ID');
    }

    // After popup closed or dismissed by user (approximate),
    // navigate to next screen
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BottomBars(
            initialGame: savedGame,
            initialPlatform: savedPlatform,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0E0E0E),
              const Color(0xFF0E0E0E),
              AppColors.bottomGradiant,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.85, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              const Text('😊', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '⭐️ Help Us Keep It ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Free!',
                      style: TextStyle(
                        color: AppColors.primaryButton,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "We’re a small team keeping this app 100% free for you. We don't want to interrupt you while you play and quick rating helps us stay alive without interrupting your game. If you ever face an issue, reach out — we’ll do our best to improve!",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 60,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⭐️ ⭐️ ⭐️ ⭐️ ⭐️', style: TextStyle(fontSize: 30)),
                  ],
                ),
              ),

              const SizedBox(height: 88),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildReviewCard(
                      username: "CheatMaster99  ⭐️⭐️⭐️⭐️⭐️",
                      review:
                          "Love the cheat code dictation! Makes entering codes so much faster and easier.",
                    ),
                    const SizedBox(height: 16),
                    _buildReviewCard(
                      username: "GamerOnTheGo  ⭐️⭐️⭐️⭐️⭐️",
                      review:
                          "Offline support is a lifesaver — I can use it anywhere, even without internet.",
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColors.primaryButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    _showReviewAndNavigate(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Rate",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    String savedGame =
                        prefs.getString('selectedGame') ?? 'sanandreas';
                    String savedPlatform =
                        prefs.getString('selectedPlatform') ?? 'pc';

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (ctx) => BottomBars(
                          initialGame: savedGame,
                          initialPlatform: savedPlatform,
                        ),
                      ),
                    );
                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "I will rate later",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.grey,
                        ),
                      ),
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

  Widget _buildReviewCard({required String username, required String review}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[900],
        border: Border.all(color: Colors.grey[700]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "\"$review\"",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
