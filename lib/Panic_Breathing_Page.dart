import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class PanicBreathingPage extends StatefulWidget {
  const PanicBreathingPage({Key? key}) : super(key: key);

  @override
  _PanicBreathingPageState createState() => _PanicBreathingPageState();
}

class _PanicBreathingPageState extends State<PanicBreathingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _instructionPlayer;
  late AudioPlayer _inhalePlayer;
  late AudioPlayer _exhalePlayer;
  bool isRunning = false;
  String breathingText = "Preparing...";
  int _currentRound = 0;
  String _currentPhase = "prepare";
  final int totalDurationSeconds = 300; // 5 minutes in seconds
  late int rounds;
  bool _isCalmAudioPlaying = false;
  bool _showSkipButton = true;

  // Breathing durations (4:6 ratio)
  final int inhaleDuration = 4;
  final int exhaleDuration = 6;
  final double gapDuration = 0.10;

  // Precalculated timing values
  late final double _inhaleFraction;
  late final double _gapFraction;
  late final double _cycleDuration;

  @override
  void initState() {
    super.initState();

    // Calculate cycle duration and rounds
    _cycleDuration = inhaleDuration + gapDuration + exhaleDuration;
    rounds = (totalDurationSeconds / _cycleDuration).ceil();

    // Precalculate timing fractions
    _inhaleFraction = inhaleDuration / _cycleDuration;
    _gapFraction = (inhaleDuration + gapDuration) / _cycleDuration;

    // Initialize audio players
    _instructionPlayer = AudioPlayer();
    _inhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _exhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    // Setup controller
    _controller = AnimationController(
      duration: Duration(seconds: _cycleDuration.toInt()),
      vsync: this,
    );

    // Start the calming audio immediately
    _playCalmAudio();
  }

  Future<void> _playCalmAudio() async {
    try {
      setState(() {
        _isCalmAudioPlaying = true;
        _showSkipButton = true;
        breathingText = "Stay calm and follow the meditation...";
      });

      await _instructionPlayer.play(AssetSource('../assets/music/calm_instruction1.mp3'));

      // Preload breathing sounds while calm audio is playing
      await _preloadAudio();

      _instructionPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isCalmAudioPlaying = false;
            _showSkipButton = false;
            breathingText = "Inhale";
            _currentPhase = "inhale";
          });
          _startBreathingCycle();
        }
      });
    } catch (e) {
      debugPrint('Error playing calm audio: $e');
      // If calm audio fails, start breathing immediately
      if (mounted) {
        setState(() {
          _isCalmAudioPlaying = false;
          _showSkipButton = false;
          breathingText = "Inhale";
          _currentPhase = "inhale";
        });
        _startBreathingCycle();
      }
    }
  }

  Future<void> _skipIntro() async {
    if (_isCalmAudioPlaying) {
      await _instructionPlayer.stop();
      if (mounted) {
        setState(() {
          _isCalmAudioPlaying = false;
          _showSkipButton = false;
          breathingText = "Inhale";
          _currentPhase = "inhale";
        });
      }
      _startBreathingCycle();
    }
  }

  Future<void> _preloadAudio() async {
    try {
      await Future.wait([
        _inhalePlayer.setSource(AssetSource('../assets/music/inhale_bell1.mp3')),
        _exhalePlayer.setSource(AssetSource('../assets/music/exhale_bell1.mp3')),
      ]);
    } catch (e) {
      debugPrint('Error preloading audio: $e');
    }
  }

  void _setupAnimationListeners() {
    _controller.addListener(_handleAnimationProgress);
    _controller.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationProgress() {
    double progress = _controller.value;
    String newPhase;

    if (progress <= _inhaleFraction) {
      newPhase = "inhale";
    } else if (progress <= _gapFraction) {
      newPhase = "gap";
    } else {
      newPhase = "exhale";
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      _playPhaseSound(_currentPhase);

      if (mounted) {
        setState(() {
          breathingText = _currentPhase == "gap" ? "" : _currentPhase.capitalize();
        });
      }
    }
  }

  void _handleAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _currentRound++;
      if (_currentRound < rounds) {
        // Reset to inhale for next round
        setState(() {
          _currentPhase = "inhale";
          breathingText = "Inhale";
        });
        _controller.reset();
        await Future.delayed(const Duration(milliseconds: 2));
        if (isRunning && mounted) {
          _controller.forward();
          _playPhaseSound(_currentPhase);
        }
      } else {
        if (mounted) {
          setState(() {
            isRunning = false;
            breathingText = "Session Complete";
          });
        }
        await _stopAllAudio();
      }
    }
  }

  Future<void> _playPhaseSound(String phase) async {
    try {
      if (phase == "inhale") {
        await _exhalePlayer.stop();
        await _inhalePlayer.seek(Duration.zero);
        await _inhalePlayer.resume();
      } else if (phase == "exhale") {
        await _inhalePlayer.stop();
        await _exhalePlayer.seek(Duration.zero);
        await _exhalePlayer.resume();
      } else {
        await _inhalePlayer.stop();
        await _exhalePlayer.stop();
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _startBreathingCycle() {
    if (!isRunning) {
      setState(() => isRunning = true);
      _setupAnimationListeners();
    }
    _controller.forward();
    _playPhaseSound(_currentPhase);
  }

  Future<void> _toggleSession() async {
    if (isRunning) {
      // Pause the session
      _controller.stop();
      await _stopAllAudio();
      setState(() {
        isRunning = false;
        breathingText = "Paused";
      });
    } else if (_isCalmAudioPlaying) {
      // Skip the intro
      await _skipIntro();
    } else {
      // Resume the session - always start from inhale
      if (_currentRound >= rounds) {
        // If session was complete, restart it
        _restartSession();
      } else {
        // Reset to inhale phase when resuming
        setState(() {
          isRunning = true;
          _currentPhase = "inhale";
          breathingText = "Inhale";
        });
        _controller.reset();
        _controller.forward();
        _playPhaseSound(_currentPhase);
      }
    }
  }

  Future<void> _exitSession() async {
    bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Session?'),
          content: const Text('Are you sure you want to exit the breathing session?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Exit', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldExit == true && mounted) {
      await _stopAllAudio();
      Navigator.of(context).pop();
    }
  }

  Future<void> _restartSession() async {
    setState(() {
      _currentRound = 0;
      isRunning = false;
      _currentPhase = "prepare";
      breathingText = "Preparing...";
    });
    _controller.reset();
    await _stopAllAudio();
    _playCalmAudio();
  }

  Future<void> _stopAllAudio() async {
    try {
      await Future.wait([
        _instructionPlayer.stop(),
        _inhalePlayer.stop(),
        _exhalePlayer.stop(),
      ]);
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Widget _buildTextDisplay(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800]?.withOpacity(0.7),
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
  }

  Widget _buildBreathingImage() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = _controller.value;
        double scale;

        if (progress <= _inhaleFraction) {
          scale = 1.0 + 0.5 * (progress / _inhaleFraction);
        } else if (progress <= _gapFraction) {
          scale = 1.5;
        } else {
          scale = 1.5 - 0.5 * ((progress - _gapFraction) / (1 - _gapFraction));
        }

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: AssetImage('assets/images/calmingchakra1.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.75),
              blurRadius: 15,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton() {
    IconData icon;
    String label;

    if (isRunning) {
      icon = Icons.pause;
      label = "Pause";
    } else if (_isCalmAudioPlaying) {
      icon = Icons.skip_next;
      label = "Skip";
    } else if (_currentRound >= rounds) {
      icon = Icons.replay;
      label = "Restart";
    } else {
      icon = Icons.play_arrow;
      label = "Resume";
    }

    return ElevatedButton.icon(
      onPressed: _toggleSession,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 10,
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _skipIntro,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Text(
        "",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildTimeProgressBar() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = _controller.value;
        int elapsedSeconds = (_currentRound * _cycleDuration + progress * _cycleDuration).toInt();
        int remainingSeconds = totalDurationSeconds - elapsedSeconds;
        if (remainingSeconds < 0) remainingSeconds = 0;

        int minutes = remainingSeconds ~/ 60;
        int seconds = remainingSeconds % 60;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: elapsedSeconds / totalDurationSeconds,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Round ${_currentRound + 1} of $rounds',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _instructionPlayer.dispose();
    _inhalePlayer.dispose();
    _exhalePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calm Breathing",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _exitSession,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF131313),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTextDisplay(breathingText),
              const SizedBox(height: 20),
              _buildBreathingImage(),
              const SizedBox(height: 30),
              _buildControlButton(),
              if (_showSkipButton) _buildSkipButton(),
              const SizedBox(height: 20),
              if (!_isCalmAudioPlaying) _buildTimeProgressBar(),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}