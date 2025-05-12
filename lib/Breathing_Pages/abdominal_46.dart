import 'package:flutter/material.dart';
import '../start.dart'; // Assuming this is your StartScreen widget.
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const AbdominalApp());
}

class AbdominalApp extends StatelessWidget {
  const AbdominalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meditation App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const AbdominalScreen(),
    );
  }
}

class AbdominalScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;
  final String imagePath;
  final String audioPath;

  const AbdominalScreen({
    Key? key,
    this.inhaleDuration = 4,
    this.exhaleDuration = 6,
    this.rounds = 5,
    this.imagePath = 'assets/images/option3.png',
    this.audioPath = '',
  }) : super(key: key);

  @override
  _AbdominalScreenState createState() => _AbdominalScreenState();
}

class _AbdominalScreenState extends State<AbdominalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> sizeTween;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _bellPlayer;

  bool isRunning = false;
  bool isAudioPlaying = false;
  int completedRounds = 0;
  int totalRounds = 0;
  bool lastPhaseWasInhale = false;

  String breathingText = "Inhale";

  @override
  void initState() {
    super.initState();
    totalRounds = widget.rounds;

    // Animation setup
    _controller = AnimationController(
      duration: Duration(seconds: widget.inhaleDuration + widget.exhaleDuration),
      vsync: this,
    );

    sizeTween = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.addListener(() {
      double inhaleThreshold = widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration);

      if (_controller.value <= inhaleThreshold && (!lastPhaseWasInhale || _controller.value < 0.01)) {
        setState(() {
          breathingText = "Inhale";
          lastPhaseWasInhale = true;
        });
        _playBellSound();
      } else if (_controller.value > inhaleThreshold && lastPhaseWasInhale) {
        setState(() {
          breathingText = "Exhale";
          lastPhaseWasInhale = false;
        });
        _playBellSound();
      }
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        completedRounds++;

        if (completedRounds >= totalRounds && totalRounds > 0) {
          _controller.stop();
          setState(() {
            isRunning = false;
            breathingText = "Complete";
          });
          return;
        }

        _controller.reset();
        setState(() {
          lastPhaseWasInhale = false;
        });

        await Future.delayed(const Duration(milliseconds: 5));

        if (isRunning) {
          _startBreathingCycle();
        }
      }
    });

    _audioPlayer = AudioPlayer();
    _bellPlayer = AudioPlayer();

    // ✅ Set AudioContext to allow simultaneous playback
    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
    );

    _audioPlayer.setAudioContext(audioContext);
    _bellPlayer.setAudioContext(audioContext);

    // Setup players
    if (widget.audioPath.isNotEmpty) {
      _setupAudioPlayer();
    }

    _setupBellPlayer();
  }



  Future<void> _setupAudioPlayer() async {
    try {
      await _audioPlayer.setSourceAsset(widget.audioPath);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error setting up audio player: $e');
    }
  }

  Future<void> _setupBellPlayer() async {
    try {
      await _bellPlayer.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      print('Error setting up bell player: $e');
    }
  }

  Future<void> _playBellSound() async {
    try {
      // Stop any current playing to avoid overlap
      await _bellPlayer.stop();
      // Play different bell sounds for inhale and exhale
      if (breathingText == "Inhale") {
        await _bellPlayer.play(AssetSource('music/inhale_bell1.mp3'));
      } else {
        await _bellPlayer.play(AssetSource('music/exhale_bell1.mp3'));
      }
    } catch (e) {
      print('Error playing bell sound: $e');
    }
  }

  void _startBreathingCycle() {
    _controller.forward();
    // Play initial bell sound when starting
    if (_controller.value < 0.01) {
      _playBellSound();
    }
  }

  void toggleBreathing() {
    if (isRunning) {
      _controller.stop();
      setState(() {
        isRunning = false;
      });
    } else {
      setState(() {
        isRunning = true;
        // Reset if completed
        if (breathingText == "Complete") {
          completedRounds = 0;
          breathingText = "Inhale";
          lastPhaseWasInhale = false;
        }
      });
      _startBreathingCycle();
    }
  }

  Future<void> toggleAudio() async {
    if (widget.audioPath.isEmpty) {
      // No audio file selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ambient sound selected')),
      );
      return;
    }

    if (isAudioPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        await _audioPlayer.resume();
      } catch (e) {
        // Try to play if resume fails
        try {
          await _audioPlayer.play(AssetSource(widget.audioPath));
        } catch (e) {
          print('Error playing audio: $e');
        }
      }
    }
    setState(() {
      isAudioPlaying = !isAudioPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _bellPlayer.dispose();
    super.dispose();
  }

  String _getBreathingRatio() {
    return "${widget.inhaleDuration}:${widget.exhaleDuration}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Abdominal Breathing (${_getBreathingRatio()})",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 10,
        actions: [
          if (widget.audioPath.isNotEmpty)
            IconButton(
              icon: Icon(
                isAudioPlaying ? Icons.music_note : Icons.music_off,
                color: Colors.white,
                size: 28.0,
              ),
              onPressed: toggleAudio,
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTextDisplay(breathingText),
                  const SizedBox(height: 20),
                  _buildBreathingImage(),
                  const SizedBox(height: 20),
                  _buildProgressIndicator(),
                  const SizedBox(height: 30),
                  _buildControlButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextDisplay(String text) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black38.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreathingImage() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double progress = _controller.value;
          double scale;
          if (progress <= widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)) {
            scale = 1.0 + 0.5 * (progress / (widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)));
          } else {
            scale = 1.5 - 0.5 * ((progress - widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)) /
                (widget.exhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)));
          }

          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          height: 150,
          width: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(widget.imagePath),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade600.withOpacity(0.75),
                blurRadius: 10,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Text(
          "Round ${completedRounds + (isRunning ? 1 : 0)} of $totalRounds",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalRounds > 0 ? (completedRounds / totalRounds) : 0,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              minHeight: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return ElevatedButton.icon(
      onPressed: toggleBreathing,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
      label: Text(
        isRunning ? "Pause" : (completedRounds >= totalRounds && totalRounds > 0) ? "Restart" : "Start",
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}