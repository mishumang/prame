// sheetkari_pranayama_page.dart
import 'package:flutter/material.dart';

class SheetkariPranayamaLearnMorePage extends StatelessWidget {
  const SheetkariPranayamaLearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sheetkari Pranayama")),
      body: const Center(
        child: Text(
          "Dummy content for Sheetkari Pranayama.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
