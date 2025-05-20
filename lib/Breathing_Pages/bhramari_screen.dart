import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';

class BhramariScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;
  final String imagePath;

  const BhramariScreen({
    Key? key,
    required this.inhaleDuration,
    required this.exhaleDuration,
    required this.rounds,
    required this.imagePath,
  }) : super(key: key);

  @override
  _BhramariScreenState createState() => _BhramariScreenState();
}

class _BhramariScreenState extends State<BhramariScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _hummingPlayer;

  bool isRunning = false;
  bool isAudioEnabled = true;
  String breathingText = "Get Ready";
  int _currentRound = 0;
  String _currentPhase = "prepare";

  // Countdown variables
  bool _isCountingDown = true;
  int _countdownSeconds = 3;
  Timer? _countdownTimer;

  // Humming sound file path (place this in your assets/audio folder)
  final String _hummingSoundPath = 'assets/music/hmmsound_.mp3';

  // Phase boundary
  late final double _inhaleFraction;

  @override
  void initState() {
    super.initState();

    // Total duration = inhale + exhale (in seconds)
    final totalDuration = widget.inhaleDuration + widget.exhaleDuration;
    _inhaleFraction = widget.inhaleDuration / totalDuration;

    // Initialize the audio player
    _hummingPlayer = AudioPlayer();
    _loadAudio();

    _controller = AnimationController(
      duration: Duration(seconds: totalDuration),
      vsync: this,
    );

    _controller.addListener(_handleAnimationProgress);
    _controller.addStatusListener(_handleAnimationStatus);

    // Start countdown
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdownSeconds = 3;
      breathingText = "$_countdownSeconds";
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
          breathingText = "$_countdownSeconds";
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
          isRunning = true;
        });
        _startBreathingCycle();
      }
    });
  }

  Future<void> _loadAudio() async {
    try {
      await _hummingPlayer.setAsset(_hummingSoundPath);
      await _hummingPlayer.setVolume(1.0); // Always play at full volume
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  void _handleAnimationProgress() {
    double progress = _controller.value;
    String newPhase;

    if (progress <= _inhaleFraction) {
      newPhase = "inhale";
    } else {
      newPhase = "exhale";
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      setState(() {
        breathingText = _currentPhase.capitalize();
      });
      _handlePhaseChange(_currentPhase);
    }
  }

  void _handlePhaseChange(String phase) async {
    if (phase == "inhale") {
      await _stopHumming();
    } else if (phase == "exhale" && isAudioEnabled) {
      await _playHumming();
    }
  }

  Future<void> _playHumming() async {
    try {
      await _hummingPlayer.seek(Duration.zero);
      await _hummingPlayer.play();
    } catch (e) {
      debugPrint('Error playing humming: $e');
    }
  }

  Future<void> _stopHumming() async {
    try {
      await _hummingPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping humming: $e');
    }
  }

  void _handleAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _currentRound++;
      if (_currentRound < widget.rounds) {
        _controller.reset();
        await Future.delayed(const Duration(milliseconds: 2));
        if (isRunning) {
          _startBreathingCycle();
        }
      } else {
        setState(() {
          isRunning = false;
          breathingText = "Complete";
        });
        await _stopHumming();
      }
    }
  }

  void _startBreathingCycle() {
    setState(() {
      breathingText = "Inhale";
      _currentPhase = "inhale";
    });
    _controller.forward();
  }

  Future<void> toggleBreathing() async {
    if (isRunning) {
      _controller.stop();
      await _stopHumming();
      setState(() {
        isRunning = false;
      });
    } else {
      if (_currentRound >= widget.rounds) {
        _currentRound = 0;
      }

      if (_isCountingDown) {
        // If currently counting down, cancel it
        _countdownTimer?.cancel();
      }

      setState(() {
        isRunning = true;
      });
      _startBreathingCycle();
    }
  }

  Future<void> toggleAudio() async {
    setState(() {
      isAudioEnabled = !isAudioEnabled;
    });
    if (!isAudioEnabled && _currentPhase == "exhale") {
      await _stopHumming();
    } else if (isAudioEnabled && _currentPhase == "exhale") {
      await _playHumming();
    }
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = _controller.value;
        double scale;

        if (_isCountingDown) {
          // Pulse animation during countdown
          final pulseValue = DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
          scale = 1.0 + 0.1 * (pulseValue < 0.5 ? pulseValue * 2 : (1 - pulseValue) * 2);
        } else if (progress <= _inhaleFraction) {
          scale = 1.0 + 0.5 * (progress / _inhaleFraction);
        } else {
          scale = 1.5 - 0.5 * ((progress - _inhaleFraction) / (1 - _inhaleFraction));
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
    );
  }

  Widget _buildControlButtons() {
    if (_isCountingDown) {
      return ElevatedButton(
        onPressed: () {
          _countdownTimer?.cancel();
          setState(() {
            _isCountingDown = false;
            isRunning = false;
            breathingText = "Get Ready";
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
        ),
        child: const Text(
          "Skip",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else if (_currentRound >= widget.rounds) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _currentRound = 0;
            isRunning = false;
          });
          _startCountdown();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
        ),
        child: const Text(
          "Repeat",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
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
          isRunning ? "Pause" : "Start",
          style: const TextStyle(fontSize: 20),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _hummingPlayer.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bhramari Breathing",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 10,
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
                  _buildTextDisplay(_isCountingDown ? "$_countdownSeconds" : breathingText),
                  const SizedBox(height: 20),
                  _buildBreathingImage(),
                  const SizedBox(height: 50),
                  _buildControlButtons(),
                  Text(
                    _isCountingDown
                        ? "Prepare to begin"
                        : "Round: ${_currentRound < widget.rounds ? _currentRound + 1 : widget.rounds} / ${widget.rounds}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + 10,
            right: 15,
            child: IconButton(
              icon: Icon(
                isAudioEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.teal,
                size: 36.0,
              ),
              onPressed: toggleAudio,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}