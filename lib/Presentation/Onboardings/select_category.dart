import 'package:flutter/material.dart';

class SelectCategory extends StatefulWidget {
  const SelectCategory({super.key});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.directions_car,
      'title': 'Vehicle Spawns',
      'selected': false,
    },
    {
      'icon': Icons.sports_kabaddi,
      'title': 'Weapons & Combat',
      'selected': true,
    },
    {'icon': Icons.person, 'title': 'Player Enhancements', 'selected': false},
    {'icon': Icons.warning, 'title': 'Wanted Level', 'selected': true},
    {'icon': Icons.public, 'title': 'World & Environment', 'selected': false},
    {'icon': Icons.emoji_emotions, 'title': 'Fun & Misc', 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Choose Your\nFavorite Categories",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tailor your cheat code experience. We'll make your favorite types easier to find.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white12, height: 1),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(item['icon'], color: Colors.white),
                    title: Text(
                      item['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        item['selected']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: item['selected']
                            ? const Color(0xFF00FF9D)
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF9D),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Continue",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text.rich(
                TextSpan(
                  text: "We won’t share this information with anyone. Go to\n",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: "GTA cheat code’s Terms of Use",
                      style: const TextStyle(color: Color(0xFF00FF9D)),
                    ),
                    const TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: const TextStyle(color: Color(0xFF00FF9D)),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
