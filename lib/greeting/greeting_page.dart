import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart'; // For animated text
import 'package:meditation_app/relax.dart'; // Relax page
import 'package:lottie/lottie.dart'; // For animations like confetti

class GreetingPage extends StatelessWidget {
  final String userName;

  GreetingPage({required this.userName});

  @override
  Widget build(BuildContext context) {
    // Navigate to RelaxScreen after 2 seconds with a smooth transition
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const RelaxScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade transition
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.deepOrange,
                  Colors.yellow,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Confetti Animation
          Align(
            alignment: Alignment.topCenter,
            child: Lottie.asset(
              'assets/animations/confetti.json', // Replace with your Lottie animation path
              height: 400,
              repeat: false, // Play once
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Text
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText('Hello, $userName!'),
                      FadeAnimatedText('Welcome!'),
                    ],
                    totalRepeatCount: 1, // Play text animation once
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
