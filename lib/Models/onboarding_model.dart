import 'package:flutter/material.dart';

class OnboardingScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Widget child;

  const OnboardingScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentStep / totalSteps;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
