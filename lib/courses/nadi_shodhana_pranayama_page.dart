// nadi_shodhana_pranayama_page.dart
import 'package:flutter/material.dart';

class NadiShodhanaPranayamaPage extends StatelessWidget {
  const NadiShodhanaPranayamaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nadi Shodhana Pranayama")),
      body: const Center(
        child: Text(
          "Dummy content for Nadi Shodhana Pranayama.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
