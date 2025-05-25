// chandra_bhedana_pranayama_page.dart
import 'package:flutter/material.dart';

class ChandraBhedanaPranayamaLearnMorePage extends StatelessWidget {
  const ChandraBhedanaPranayamaLearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chandra Bhedana Pranayama")),
      body: const Center(
        child: Text(
          "Dummy content for Chandra Bhedana Pranayama.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
