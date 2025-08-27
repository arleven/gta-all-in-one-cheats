import 'package:flutter/material.dart';
import 'package:all_gta/l10n/app_localizations.dart';

class CheatsHelpSheet extends StatelessWidget {
  const CheatsHelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    final steps = [
      local.cheatStep1,
      local.cheatStep2,
      local.cheatStep3,
      local.cheatStep4,
      local.cheatStep5,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.cheatHelpTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/gta.jpg',
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: steps.length + 1,
                  itemBuilder: (context, index) {
                    if (index < steps.length) {
                      return NumberedStep(
                        number: index + 1,
                        text: steps[index],
                      );
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SmallDot(number: 1),
                              SizedBox(width: 16),
                              SmallDot(number: 2),
                              SizedBox(width: 16),
                              SmallDot(number: 3),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              AppLocalizations.of(context)!.cheatHelpNote,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SmallDot extends StatelessWidget {
  final int number;

  const SmallDot({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.greenAccent,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class NumberedStep extends StatelessWidget {
  final int number;
  final String text;

  const NumberedStep({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.greenAccent,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}
