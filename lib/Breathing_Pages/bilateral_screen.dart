import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class BilateralScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;
  final String imagePath;
  final String audioPath;
  final String inhaleAudioPath;
  final String exhaleAudioPath;

  const BilateralScreen({
    Key? key,
    required this.inhaleDuration,
    required this.exhaleDuration,
    required this.rounds,
    required this.imagePath,
    required this.audioPath,
    this.inhaleAudioPath = 'assets/music/inhale_bell1.mp3', // Default value added
    this.exhaleAudioPath = 'assets/music/exhale_bell1.mp3', // Default value added
  }) : super(key: key);

  @override
  _BilateralScreenState createState() => _BilateralScreenState();
}

class _BilateralScreenState extends State<BilateralScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> sizeTween;
  late AudioPlayer _ambientPlayer;
  late AudioPlayer _inhalePlayer;  // Separate player for inhale sound
  late AudioPlayer _exhalePlayer;  // Separate player for exhale sound

  int _countdown = 3;
  bool _isCountingDown = true;
  bool isRunning = false;
  bool isAudioPlaying = true;
  int currentRound = 0;

  String breathingText = "Get Ready";
  Timer? _countdownTimer;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();

    _ambientPlayer = AudioPlayer()..setVolume(1.0); // Slightly lower volume for ambient
    _inhalePlayer = AudioPlayer()..setVolume(0.5);  // Full volume for bells
    _exhalePlayer = AudioPlayer()..setVolume(0.5);
    // Preload audio files to reduce latency
    _preloadAudio();

    // Start countdown
    _startCountdown();

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
      setState(() {
        double totalDuration = widget.inhaleDuration.toDouble() + widget.exhaleDuration.toDouble();
        double inhalePortion = widget.inhaleDuration.toDouble() / totalDuration;

        if (_controller.value <= inhalePortion) {
          breathingText = "Inhale";
        } else {
          breathingText = "Exhale";
        }
      });
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        currentRound++;
        if (currentRound >= widget.rounds) {
          // Session completed
          setState(() {
            breathingText = "Session Complete";
            isRunning = false;
          });
          return;
        }

        _controller.reset();
        await Future.delayed(const Duration(milliseconds: 5));
        if (isRunning) {
          _startBreathingCycle();
        }
      }
    });
  }

  // Preload audio to reduce latency
  Future<void> _preloadAudio() async {
    try {
      await _inhalePlayer.setSource(AssetSource(widget.inhaleAudioPath));
      await _exhalePlayer.setSource(AssetSource(widget.exhaleAudioPath));
      debugPrint('Audio files preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading audio: $e');
    }
  }

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
      breathingText = "$_countdown";
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 1) {
          _countdown--;
          breathingText = "$_countdown";
        } else {
          _countdownTimer?.cancel();
          _isCountingDown = false;
          isRunning = true;
          _playAmbientSound();
          _startBreathingCycle();
        }
      });
    });
  }

  void _startBreathingCycle() {
    if (isRunning) {
      // Cancel any existing phase timer
      _phaseTimer?.cancel();

      // Play inhale bell immediately
      _playInhaleBell();

      // Start the animation
      _controller.forward(from: 0.0);

      // Schedule exhale bell sound using a timer instead of relying on animation
      _phaseTimer = Timer(Duration(seconds: widget.inhaleDuration), () {
        if (isRunning) {
          _playExhaleBell();
        }
      });
    }
  }

  Future<void> _playInhaleBell() async {
    try {
      debugPrint('Playing inhale bell');
      // Always reset position and play from the beginning
      await _inhalePlayer.play(AssetSource(widget.inhaleAudioPath));
    } catch (e) {
      debugPrint('Error playing inhale bell: $e');
    }
  }

  Future<void> _playExhaleBell() async {
    try {
      debugPrint('Playing exhale bell');
      // Always reset position and play from the beginning
      await _exhalePlayer.play(AssetSource(widget.exhaleAudioPath));

    } catch (e) {
      debugPrint('Error playing exhale bell: $e');

    }
  }

  Future<void> _playAmbientSound() async {
    if (isAudioPlaying && widget.audioPath.isNotEmpty) {
      try {
        await _ambientPlayer.play(AssetSource(widget.audioPath));
        await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      } catch (e) {
        debugPrint('Error playing ambient sound: $e');
      }
    }
  }

  void toggleBreathing() {
    if (_isCountingDown) {
      _countdownTimer?.cancel();
      _phaseTimer?.cancel();
      setState(() {
        _isCountingDown = false;
        isRunning = false;
        breathingText = "Paused";
      });
      return;
    }

    if (isRunning) {
      _controller.stop();
      _ambientPlayer.pause();
      _phaseTimer?.cancel();
      setState(() {
        isRunning = false;
        breathingText = "Paused";
      });
    } else {
      setState(() {
        isRunning = true;
        if (_controller.value > 0) {
          _controller.forward();
          if (isAudioPlaying && widget.audioPath.isNotEmpty) {
            _ambientPlayer.resume();
          }

          // If we're in the exhale phase and resuming
          double totalDuration = widget.inhaleDuration.toDouble() + widget.exhaleDuration.toDouble();
          double inhalePortion = widget.inhaleDuration.toDouble() / totalDuration;

          if (_controller.value > inhalePortion) {
            // We're in the exhale phase, schedule the next inhale
            double remainingExhaleTime = (1 - _controller.value) * totalDuration;
            _phaseTimer = Timer(Duration(milliseconds: (remainingExhaleTime * 1000).round()), () {
              if (isRunning) {
                // This will be called when the current cycle completes
              }
            });
          } else {
            // We're in the inhale phase, schedule the exhale
            double remainingInhaleTime = (inhalePortion - _controller.value) * totalDuration;
            _phaseTimer = Timer(Duration(milliseconds: (remainingInhaleTime * 1000).round()), () {
              if (isRunning) {
                _playExhaleBell();
              }
            });
          }
        } else {
          _startBreathingCycle();
          if (isAudioPlaying && widget.audioPath.isNotEmpty) {
            _playAmbientSound();
          }
        }
      });
    }
  }

  Future<void> toggleAudio() async {
    if (isAudioPlaying) {
      await _ambientPlayer.pause();
    } else if (isRunning && widget.audioPath.isNotEmpty) {
      await _ambientPlayer.resume();
    }

    setState(() {
      isAudioPlaying = !isAudioPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ambientPlayer.dispose();
    _inhalePlayer.dispose();
    _exhalePlayer.dispose();
    _countdownTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Breathing Session (${widget.inhaleDuration}:${widget.exhaleDuration})",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 10,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTextDisplay(breathingText),
                const SizedBox(height: 20),
                _isCountingDown
                    ? _buildCountdownDisplay()
                    : _buildBreathingAnimation(),
                const SizedBox(height: 50),
                _buildControlButtons(),
              ],
            ),
          ),
          Positioned(
            top: kToolbarHeight + 10,
            right: 15,
            child: IconButton(
              icon: Icon(
                isAudioPlaying ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
                size: 36.0,
              ),
              onPressed: toggleAudio,
            ),
          ),
          // Session progress indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Round: ${currentRound + 1}/${widget.rounds}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Debug button for testing bell sounds (can be removed in production)
          Positioned(
            top: kToolbarHeight + 10,
            left: 15,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _playInhaleBell,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text("Test Inhale Bell", style: TextStyle(fontSize: 10)),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: _playExhaleBell,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text("Test Exhale Bell", style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextDisplay(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black38.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCountdownDisplay() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          _countdown.toString(),
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = _controller.value;
        double scale;

        // Calculate scale based on breathing phase
        if (progress <= widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)) {
          // Inhale phase - expand from 1.0 to 1.5
          scale = 1.0 + 0.5 * (progress / (widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)));
        } else {
          // Exhale phase - contract from 1.5 to 1.0
          scale = 1.5 - 0.5 * ((progress - widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)) /
              (widget.exhaleDuration / (widget.inhaleDuration + widget.exhaleDuration)));
        }

        return Transform.scale(
          scale: scale,
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return ElevatedButton.icon(
      onPressed: toggleBreathing,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
      label: Text(
        isRunning ? "Pause" : "Start",
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}