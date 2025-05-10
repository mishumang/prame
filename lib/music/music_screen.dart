import 'package:flutter/material.dart';
import 'package:meditation_app/common//color_extension.dart'; // Adjust the path accordingly
// Adjust the path accordingly
 // Make sure the TColor extension is defined here

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  List listArr = [
    {
      "image": "assets/image/image1.png",
      "title": "Night Island",
      "subtitle": "45 MIN . SLEEP MUSIC"
    },
    {
      "image": "assets/image/image1.png",
      "title": "Sweet Sleep",
      "subtitle": "45 MIN . SLEEP MUSIC"
    },
    {
      "image": "assets/image/image1.png",
      "title": "Good Night",
      "subtitle": "45 MIN . SLEEP MUSIC"
    },
    {
      "image": "assets/image/image1.png",
      "title": "Moon Clouds",
      "subtitle": "45 MIN . SLEEP MUSIC"
    },
    {
      "image": "assets/image/image1.png",
      "title": "Night Island",
      "subtitle": "45 MIN . SLEEP MUSIC"
    },
    {
      "image": "assets/image/image1.png",
      "title": "Sweet Sleep",
      "subtitle": "45 MIN . SLEEP MUSIC"
    },
    {
      "image": "assets/image/image1.png",
      "title": "Good Night",
      "subtitle": "45 MIN . SLEEP MUSIC"
    },
    {
      "image": "assets/image/image1.png",
      "title": "Moon Clouds",
      "subtitle": "45 MIN . SLEEP MUSIC"
    },
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width; // Get the width using MediaQuery

    return Scaffold(
      backgroundColor: TColor.sleep, // Assuming TColor is defined in the color_extension.dart
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: Text(
          "Music",
          style: TextStyle(
            color: TColor.sleepText, // Ensure this is defined
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.08,
        ),
        itemBuilder: (context, index) {
          var cObj = listArr[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  cObj["image"],
                  width: width, // Use the screen width
                  height: width * 0.3, // Calculate height based on width
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                cObj["title"],
                maxLines: 1,
                style: TextStyle(
                  color: TColor.sleepText, // Ensure this is defined
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                cObj["subtitle"],
                maxLines: 1,
                style: TextStyle(
                  color: TColor.sleepText, // Ensure this is defined
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
        itemCount: listArr.length,
      ),
    );
  }
}
