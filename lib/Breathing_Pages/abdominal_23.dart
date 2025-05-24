// import 'package:flutter/material.dart';
// import '../start.dart'; // Assuming this is your StartScreen widget.
// import 'dart:async';
// import 'package:audioplayers/audioplayers.dart';
//
// void main() {
//   runApp(const BilateralApp());
// }
//
// class BilateralApp extends StatelessWidget {
//   const BilateralApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Meditation App',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//       ),
//       home: const StartScreen(),
//     );
//   }
// }
//
// class BilateralScreen extends StatefulWidget {
//   const BilateralScreen({Key? key}) : super(key: key);
//
//   @override
//   _BilateralScreenState createState() => _BilateralScreenState();
// }
//
// class _BilateralScreenState extends State<BilateralScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> sizeTween;
//   late AudioPlayer _audioPlayer;
//
//   bool isRunning = false;
//   bool isAudioPlaying = false;
//
//   String breathingText = "Inhale";
//   int inhaleDuration = 2; // In seconds
//   int exhaleDuration = 3; // In seconds
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Animation setup
//     _controller = AnimationController(
//       duration: Duration(seconds: inhaleDuration + exhaleDuration),
//       vsync: this,
//     );
//
//     sizeTween = Tween<double>(begin: 1.0, end: 1.5).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 1.0, curve: Curves.easeInOut), // Smooth transition
//       ),
//     );
//
//     _controller.addListener(() {
//       setState(() {
//         if (_controller.value <= inhaleDuration / (inhaleDuration + exhaleDuration)) {
//           breathingText = "Inhale";
//         } else {
//           breathingText = "Exhale";
//         }
//       });
//     });
//
//     _controller.addStatusListener((status) async {
//       if (status == AnimationStatus.completed) {
//         _controller.reset();
//
//         // 5-millisecond pause after inhale before starting exhale
//         if (breathingText == "Inhale") {
//           await Future.delayed(const Duration(milliseconds: 5));
//         }
//
//         _startBreathingCycle();
//       }
//     });
//
//     _audioPlayer = AudioPlayer();
//   }
//
//   void _startBreathingCycle() {
//     _controller.forward();
//   }
//
//   void toggleBreathing() {
//     if (isRunning) {
//       _controller.stop();
//       setState(() {
//         isRunning = false;
//       });
//     } else {
//       setState(() {
//         isRunning = true;
//       });
//       _startBreathingCycle();
//     }
//   }
//
//   Future<void> toggleAudio() async {
//     if (isAudioPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       try {
//         await _audioPlayer.play(AssetSource('music/relaxing_audioo.mp3'));
//       } catch (e) {
//         print('Error playing audio: $e');
//       }
//     }
//     setState(() {
//       isAudioPlaying = !isAudioPlaying;
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Abdominal Breathing (2:3)",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blueGrey,
//         elevation: 10,
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.black, Colors.black],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildTextDisplay(breathingText),
//                   const SizedBox(height: 20),
//                   _buildBreathingImage(),
//                   const SizedBox(height: 50),
//                   _buildControlButtons(),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: kToolbarHeight + 10,
//             right: 15,
//             child: IconButton(
//               icon: Icon(
//                 isAudioPlaying ? Icons.music_note : Icons.music_off,
//                 color: Colors.teal,
//                 size: 36.0,
//               ),
//               onPressed: toggleAudio,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextDisplay(String text) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.black38.withOpacity(0.7),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black,
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Text(
//             text,
//             style: const TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildBreathingImage() {
//     return RepaintBoundary(
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           double progress = _controller.value;
//           double scale;
//           if (progress <= inhaleDuration / (inhaleDuration + exhaleDuration)) {
//             scale = 1.0 + 0.5 * (progress / (inhaleDuration / (inhaleDuration + exhaleDuration)));
//           } else {
//             scale = 1.5 - 0.5 * ((progress - inhaleDuration / (inhaleDuration + exhaleDuration)) /
//                 (exhaleDuration / (inhaleDuration + exhaleDuration)));
//           }
//
//           return Transform.scale(
//             scale: scale,
//             child: child,
//           );
//         },
//         child: Container(
//           height: 150,
//           width: 250,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             image: const DecorationImage(
//               image: AssetImage('assets/images/muladhara_chakra3.png'),
//               fit: BoxFit.cover,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.red.shade600.withOpacity(0.75),
//                 blurRadius: 10,
//                 spreadRadius: 10,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildControlButtons() {
//     return ElevatedButton.icon(
//       onPressed: toggleBreathing,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.black,
//         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         elevation: 10,
//       ),
//       icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
//       label: Text(
//         isRunning ? "Pause" : "Start",
//         style: const TextStyle(fontSize: 20),
//       ),
//     );
//   }
// }
