import 'package:flutter/material.dart';
import 'package:meditation_app/onbaording_screen.dart';
import 'package:meditation_app/common_widgets/round_button.dart'; // Adjust the path as needed
// Ensure correct import

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffc2e0e8),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            "assets/images/welcome.png", // Corrected the path
            width: MediaQuery.of(context).size.width, // Corrected the width usage
            fit: BoxFit.fitWidth,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "WELCOME",
                    style: TextStyle(
                      color: TColor.primaryTextW, // Ensure TColor is defined
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "To Prame",
                    style: TextStyle(
                      color: TColor.primaryTextW, // Ensure TColor is defined
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Explore the app, Find some peace of mind to prepare for meditation.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.primaryTextW, // Ensure TColor is defined
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  RoundButton(
                    title: "GET STARTED",
                    type: RoundButtonType.secondary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OnboardingScreen()),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TColor {
  static const primaryTextW = Colors.white; // Example color definition
}
