// surya_bhedana_pranayama_page.dart
import 'package:flutter/material.dart';

class SuryaBhedanaPranayamaLearnMorePage extends StatelessWidget {
  const SuryaBhedanaPranayamaLearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Surya Bhedana Pranayama")),
      body: const Center(
        child: Text(
          "Dummy content for Surya Bhedana Pranayama.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
