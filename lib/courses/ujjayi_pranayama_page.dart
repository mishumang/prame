// ujjayi_pranayama_page.dart
import 'package:flutter/material.dart';

class UjjayiPranayamaLearnMorePage extends StatelessWidget {
  const UjjayiPranayamaLearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ujjayi Pranayama")),
      body: const Center(
        child: Text(
          "Dummy content for Ujjayi Pranayama.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
