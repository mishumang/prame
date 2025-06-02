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
  final String inhaleAudioPath;
  final String exhaleAudioPath;

  const AbdominalScreen({
    Key? key,
    this.inhaleDuration = 4,
    this.exhaleDuration = 6,
    this.rounds = 5,
    this.imagePath = 'assets/images/option3.png',
    this.audioPath = '',
    this.inhaleAudioPath = 'music/inhale_bell1.mp3',
    this.exhaleAudioPath = 'music/exhale_bell.mp3',
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
  bool isPaused = false;
  bool isAudioPlaying = false;
  bool wasAudioPlayingBeforePause = false; // Track audio state before pause
  int completedRounds = 0;
  int totalRounds = 0;
  bool lastPhaseWasInhale = false;

  // Volume control variables
  double ambientVolume = 0.7;
  double bellVolume = 1.0;
  bool showVolumeControls = false;

  // Countdown variables
  bool isCountingDown = false;
  int countdownValue = 3;
  Timer? _countdownTimer;

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
          await _pauseAllAudio(); // Pause audio when exercise completes
          setState(() {
            isRunning = false;
            isPaused = false;
            breathingText = "Complete";
          });
          return;
        }

        _controller.reset();
        setState(() {
          lastPhaseWasInhale = false;
        });

        await Future.delayed(const Duration(milliseconds: 5));

        if (isRunning && !isPaused) {
          _controller.forward();
        }
      }
    });

    _audioPlayer = AudioPlayer();
    _bellPlayer = AudioPlayer();

    // Set AudioContext to allow simultaneous playback
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
      await _audioPlayer.setVolume(ambientVolume);
    } catch (e) {
      print('Error setting up audio player: $e');
    }
  }

  Future<void> _setupBellPlayer() async {
    try {
      await _bellPlayer.setReleaseMode(ReleaseMode.release);
      await _bellPlayer.setVolume(bellVolume);
    } catch (e) {
      print('Error setting up bell player: $e');
    }
  }

  Future<void> _playBellSound() async {
    try {
      // Don't play bell sounds when paused
      if (isPaused) return;

      // Stop any current playing to avoid overlap
      await _bellPlayer.stop();

      // Add debug statement
      print('Playing bell sound for: $breathingText');

      // Play different bell sounds for inhale and exhale
      if (breathingText == "Inhale") {
        await _bellPlayer.play(AssetSource(widget.inhaleAudioPath));
        print('Attempted to play inhale bell');
      } else {
        await _bellPlayer.play(AssetSource(widget.exhaleAudioPath));
        print('Attempted to play exhale bell');
      }
    } catch (e) {
      // More detailed error logging
      print('Error playing bell sound: $e');
      // Show a snackbar or toast to alert the user of the issue
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing bell sound: $e')),
        );
      }
    }
  }

  // NEW: Method to pause all audio
  Future<void> _pauseAllAudio() async {
    if (isAudioPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isAudioPlaying = false;
      });
    }
    // Also stop any playing bell sounds
    await _bellPlayer.stop();
  }

  // NEW: Method to resume audio if it was playing before pause
  Future<void> _resumeAudioIfNeeded() async {
    if (wasAudioPlayingBeforePause && widget.audioPath.isNotEmpty) {
      try {
        await _audioPlayer.resume();
        setState(() {
          isAudioPlaying = true;
        });
      } catch (e) {
        // Try to play if resume fails
        try {
          await _audioPlayer.play(AssetSource(widget.audioPath));
          setState(() {
            isAudioPlaying = true;
          });
        } catch (e) {
          print('Error resuming audio: $e');
        }
      }
    }
  }

  // Update ambient sound volume
  Future<void> _updateAmbientVolume(double value) async {
    setState(() {
      ambientVolume = value;
    });
    await _audioPlayer.setVolume(value);
  }

  // Update bell sound volume
  Future<void> _updateBellVolume(double value) async {
    setState(() {
      bellVolume = value;
    });
    await _bellPlayer.setVolume(value);
  }

  // Toggle volume controls visibility
  void _toggleVolumeControls() {
    setState(() {
      showVolumeControls = !showVolumeControls;
    });
  }

  // Countdown logic
  void _startCountdown() {
    setState(() {
      isCountingDown = true;
      countdownValue = 3;
      breathingText = countdownValue.toString();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdownValue--;
        if (countdownValue > 0) {
          breathingText = countdownValue.toString();
        } else {
          _countdownTimer?.cancel();
          isCountingDown = false;
          breathingText = "Inhale";
          _startBreathingCycle();
          if (widget.audioPath.isNotEmpty) {
            toggleAudio(); // Auto start ambient audio
          }
        }
      });
    });
  }

  void _startBreathingCycle() {
    setState(() {
      isRunning = true;
      isPaused = false;
    });
    _controller.forward();
    // Play initial bell sound when starting
    if (_controller.value < 0.01) {
      _playBellSound();
    }
  }

  void toggleBreathing() {
    if (isCountingDown) {
      // Cancel countdown if it's in progress
      _countdownTimer?.cancel();
      // MODIFIED: Also pause audio when canceling countdown
      _pauseAllAudio();
      setState(() {
        isCountingDown = false;
        breathingText = "Inhale";
      });
    } else if (isRunning && !isPaused) {
      // MODIFIED: Pause the breathing exercise AND audio
      _controller.stop(); // This stops the animation at current position
      // Remember if audio was playing before pause
      wasAudioPlayingBeforePause = isAudioPlaying;
      _pauseAllAudio(); // Pause all audio
      setState(() {
        isPaused = true;
        // Keep the current breathing text when paused
      });
    } else if (isPaused) {
      // MODIFIED: Resume from pause AND resume audio if it was playing
      setState(() {
        isPaused = false;
      });
      _controller.forward(); // Continue from current position
      _resumeAudioIfNeeded(); // Resume audio if it was playing before pause
    } else {
      // Start or restart
      if (breathingText == "Complete") {
        // Reset everything for restart
        setState(() {
          completedRounds = 0;
          lastPhaseWasInhale = false;
          isPaused = false;
          wasAudioPlayingBeforePause = false;
        });
        _controller.reset();
        // Stop any playing audio
        _pauseAllAudio();
      }
      // Start countdown before actual breathing
      _startCountdown();
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
    _audioPlayer.stop();
    _bellPlayer.dispose();
    _bellPlayer.stop();
    _countdownTimer?.cancel();
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
          // Volume control button
          IconButton(
            icon: const Icon(
              Icons.volume_up,
              color: Colors.white,
              size: 28.0,
            ),
            onPressed: _toggleVolumeControls,
          ),
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
                  if (showVolumeControls) _buildVolumeControls(),
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

  // Volume controls widget
  Widget _buildVolumeControls() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueGrey, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.lightBlueAccent),
              const SizedBox(width: 8),
              const Text(
                "Ambient Volume:",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Slider(
                  value: ambientVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  activeColor: Colors.lightBlueAccent,
                  inactiveColor: Colors.grey.shade700,
                  label: (ambientVolume * 100).round().toString(),
                  onChanged: (value) => _updateAmbientVolume(value),
                ),
              ),
              Text(
                "${(ambientVolume * 100).round()}%",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.amberAccent),
              const SizedBox(width: 8),
              const Text(
                "Bell Volume:",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Slider(
                  value: bellVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  activeColor: Colors.amberAccent,
                  inactiveColor: Colors.grey.shade700,
                  label: (bellVolume * 100).round().toString(),
                  onChanged: (value) => _updateBellVolume(value),
                ),
              ),
              Text(
                "${(bellVolume * 100).round()}%",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextDisplay(String text) {
    // Special animation styles for countdown
    final bool isCountdown = isCountingDown && int.tryParse(text) != null;

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
            isPaused ? "$text (Paused)" : text, // Show paused status
            style: TextStyle(
              fontSize: isCountdown ? 50 : 30, // Larger font for countdown
              fontWeight: FontWeight.bold,
              color: isPaused ? Colors.orange : (isCountdown ? Colors.amber : Colors.white), // Orange color when paused
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

          // Don't animate during countdown or when paused
          if (isCountingDown || isPaused) {
            scale = 1.0;
          } else if (progress <= widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)) {
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
                color: (isPaused ? Colors.orange : Colors.red).shade600.withOpacity(0.75),
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
          isCountingDown
              ? "Preparing to start..."
              : isPaused
              ? "Paused - Round ${completedRounds + 1} of $totalRounds"
              : "Round ${completedRounds + (isRunning ? 1 : 0)} of $totalRounds",
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
              value: isCountingDown
                  ? (3 - countdownValue) / 3  // Show countdown progress
                  : (totalRounds > 0 ? (completedRounds / totalRounds) : 0),
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isCountingDown ? Colors.amber : (isPaused ? Colors.orange : Colors.teal)
              ),
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
        backgroundColor: isCountingDown
            ? Colors.amber
            : isPaused
            ? Colors.green
            : isRunning
            ? Colors.orange
            : Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      icon: Icon(
          isCountingDown
              ? Icons.cancel
              : isPaused
              ? Icons.play_arrow
              : (isRunning ? Icons.pause : Icons.play_arrow)
      ),
      label: Text(
        isCountingDown
            ? "Cancel"
            : isPaused
            ? "Resume"
            : (isRunning ? "Pause" : (completedRounds >= totalRounds && totalRounds > 0) ? "Restart" : "Start"),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}