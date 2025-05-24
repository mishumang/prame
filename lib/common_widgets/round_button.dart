import 'package:flutter/material.dart';

enum RoundButtonType { primary, secondary }

class RoundButton extends StatelessWidget {
  final String title;
  final RoundButtonType type;
  final VoidCallback onPressed;

  const RoundButton({
    super.key,
    required this.title,
    this.type = RoundButtonType.primary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: double.maxFinite,
        elevation: 0,
        color:
        type == RoundButtonType.primary ? TColor.primary : TColor.tertiary,
        height: 60,
        shape: RoundedRectangleBorder(
            side: BorderSide.none, borderRadius: BorderRadius.circular(30)),
        child: Text(
          title,
          style: TextStyle(
            color: type == RoundButtonType.primary
                ? Colors.white
                : TColor.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class TColor {
  static const primary = Color(0xFF8E97FD); // Example primary color
  static const tertiary = Colors.white; // Example tertiary color
  static const primaryText = Color(0xFF3E3E3E); // Example primary text color
  static const primaryTextW = Colors.white; // Example color definition
}