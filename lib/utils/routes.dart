import 'package:flutter/material.dart';
import 'package:meditation_app/start.dart';
import '../Breathing_Pages/abdominal_46.dart'; // Replace with actual file path
import '../Breathing_Pages/abdominal_23.dart'; // Replace with actual file path

class AppRoutes {
  static const String start = '/start';
  static const String abdominalBreathing = '/abdominal';
  static const String breathing24 = '/breathing24';
  static const String breathing46 = '/breathing46';

  static final Map<String, WidgetBuilder> routes = {
    '/start': (context) => StartScreen(),
    // Replace with actual widget
    '/breathing46': (context) => Abdominal46Screen(),// 4:6 Breathing Technique Screen
    // Add more routes for other techniques
    // Example: meditationBreathing: (context) => MeditationScreen(),
  };
}
