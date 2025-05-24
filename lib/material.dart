import 'package:flutter/material.dart';
import 'utils/routes.dart'; // Import the centralized routes file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'Breathing Techniques App',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Theme color
      ),
      initialRoute: AppRoutes.start, // Set this to 'start' to show StartScreen first
      routes: AppRoutes.routes, // Register all routes from AppRoutes
    );
  }
}
