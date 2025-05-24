// chest_breathing_page.dart
import 'package:flutter/material.dart';

class ChestBreathingLearnMorePage extends StatelessWidget {
  const ChestBreathingLearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chest Breathing")),
      body: const Center(
        child: Text(
          "Dummy content for Chest Breathing.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
