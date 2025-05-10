import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class BilateralScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;
  final String imagePath;
  final String audioPath;

  const BilateralScreen({
    Key? key,
    required this.inhaleDuration,
    required this.exhaleDuration,
    required this.rounds,
    required this.imagePath,
    required this.audioPath,
  }) : super(key: key);

  @override
  _BilateralScreenState createState() => _BilateralScreenState();
}

class _BilateralScreenState extends State<BilateralScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer; // For guide audios and bell sounds
  late AudioPlayer _backgroundAudioPlayer; // For ambient background audio
  late AudioPlayer _bellPlayer; // New separate player for bell sounds
  bool isRunning = false;
  bool isAudioPlaying = true;
  String breathingText = "Starting Session...";
  int _currentRound = 0;
  String _currentPhase = "prepare";
  bool _guidesCompleted = false; // Track guide audio completion

  // Guide states
  bool _isGuide1Playing = false;
  bool _isGuide2Playing = false;
  bool _showSkipGuide1 = false;
  late Timer _skipButtonTimer;

  late final AssetSource _inhaleSound;
  late final AssetSource _exhaleSound;
  late final AssetSource _guide1Sound;
  late final AssetSource _guide2Sound;
  late final AssetSource? _backgroundSound;

  late final double _inhaleFraction;
  late final double _gapFraction;

  @override
  void initState() {
    super.initState();

    // Initialize audio sources
    _inhaleSound = AssetSource('../assets/music/inhale_bell1.mp3');
    _exhaleSound = AssetSource('../assets/music/exhale_bell1.mp3');
    _guide1Sound = AssetSource('../assets/music/guide-calm1.mp3');
    _guide2Sound = AssetSource('../assets/music/guide_calm2.mp3');
    _backgroundSound = widget.audioPath.isNotEmpty ? AssetSource(widget.audioPath) : null;

    debugPrint('Received audioPath: ${widget.audioPath}');
    debugPrint('Background sound initialized: ${_backgroundSound?.path}');

    if (_backgroundSound == null && widget.audioPath.isNotEmpty) {
      debugPrint('Warning: Failed to initialize background sound for audioPath: ${widget.audioPath}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No ambient audio selected or invalid audio path')),
        );
      }
    }

    // Calculate animation fractions
    final totalDuration = widget.inhaleDuration + 0.10 + widget.exhaleDuration;
    _inhaleFraction = widget.inhaleDuration / totalDuration;
    _gapFraction = (widget.inhaleDuration + 0.10) / totalDuration;

    // Initialize audio players
    _audioPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..setVolume(isAudioPlaying ? 0.5 : 0.0); // For guide sounds

    _bellPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..setVolume(isAudioPlaying ? 0.5 : 0.0); // For bell sounds

    _backgroundAudioPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.loop)
      ..setVolume(isAudioPlaying ? 1.0 : 0.0); // Set to full volume for background

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: totalDuration.toInt()),
      vsync: this,
    );

    _controller.addListener(_handleAnimationProgress);
    _controller.addStatusListener(_handleAnimationStatus);

    // Start background audio immediately if available
    if (_backgroundSound != null && isAudioPlaying) {
      _startBackgroundAudio();
    }

    // Preload audio and start guide audios
    _preloadAudio().then((_) {
      debugPrint('Audio preloaded, starting guides');
      _startGuides();
    });
  }

  // New method to start background audio
  Future<void> _startBackgroundAudio() async {
    if (_backgroundSound == null) return;

    try {
      debugPrint('Attempting to start background audio...');
      await _backgroundAudioPlayer.setSource(_backgroundSound!);
      await _backgroundAudioPlayer.play(_backgroundSound!);
      debugPrint('Background audio started successfully');
    } catch (e) {
      debugPrint('Error starting background audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting background audio: $e')),
        );
      }
    }
  }

  // Preload audio sources
  Future<void> _preloadAudio() async {
    try {
      debugPrint('Starting audio preload...');
      await Future.wait([
        _audioPlayer.setSource(_guide1Sound),
        _audioPlayer.setSource(_guide2Sound),
        _bellPlayer.setSource(_inhaleSound),
        _bellPlayer.setSource(_exhaleSound),
      ]);
      debugPrint('All audio sources preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
  }

  // Start guide audio sequence
  Future<void> _startGuides() async {
    debugPrint('Starting guide audio sequence');
    await _playGuide1();
    if (mounted && !_isGuide2Playing) {
      await _playGuide2();
    }
    if (mounted) {
      setState(() {
        _guidesCompleted = true;
        _isGuide2Playing = false;
        isRunning = true;
        breathingText = "Inhale";
        _currentPhase = "inhale";
      });
      debugPrint('Guides completed, starting breathing cycle');
      _startBreathingCycle();
    }
  }

  // Play first guide audio (guide-calm1.mp3)
  Future<void> _playGuide1() async {
    try {
      setState(() {
        _isGuide1Playing = true;
        breathingText = "Relax and Prepare";
        _showSkipGuide1 = false;
      });

      debugPrint('Playing Guide 1');
      _skipButtonTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isGuide1Playing) {
          setState(() => _showSkipGuide1 = true);
        }
      });

      await _audioPlayer.stop();
      await _audioPlayer.play(_guide1Sound);
      await _audioPlayer.onPlayerComplete.first; // Wait for completion
      debugPrint('Guide 1 completed');
    } catch (e) {
      debugPrint('Error playing Guide 1: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing Guide 1: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGuide1Playing = false);
        _skipButtonTimer.cancel();
      }
    }
  }

  // Skip first guide audio
  Future<void> _skipGuide1() async {
    if (!_isGuide1Playing) return;

    debugPrint('Skipping Guide 1');
    await _audioPlayer.stop();
    _skipButtonTimer.cancel();
    if (mounted) {
      setState(() => _isGuide1Playing = false);
      _playGuide2();
    }
  }

  // Play second guide audio (guide-calm2.mp3)
  Future<void> _playGuide2() async {
    try {
      setState(() {
        _isGuide2Playing = true;
        breathingText = "    Focus on\nYour Breathing";
        _showSkipGuide1 = false;
      });

      debugPrint('Playing Guide 2');
      await _audioPlayer.stop();
      await _audioPlayer.play(_guide2Sound);
      await _audioPlayer.onPlayerComplete.first; // Wait for completion
      debugPrint('Guide 2 completed');
    } catch (e) {
      debugPrint('Error playing Guide 2: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing Guide 2: $e')),
        );
      }
    }
  }

  // Handle animation progress for breathing phases
  void _handleAnimationProgress() {
    if (!_guidesCompleted || _isGuide1Playing || _isGuide2Playing) return;

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
      if (isAudioPlaying && isRunning) {
        _playPhaseSound(_currentPhase);
      }

      setState(() {
        breathingText = _currentPhase == "gap" ? "" : _currentPhase.capitalize();
      });
    }
  }

  // Handle animation status (e.g., cycle completion)
  Future<void> _handleAnimationStatus(AnimationStatus status) async {
    if (!_guidesCompleted || _isGuide1Playing || _isGuide2Playing) return;

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
        // Stop both bell and ambient audio when session completes
        await _audioPlayer.stop();
        debugPrint('Stopping background audio on session completion');
        await _backgroundAudioPlayer.stop();
        debugPrint('Session completed, all audio stopped');
      }
    }
  }

  // Play bell sounds for inhale/exhale phases
  Future<void> _playPhaseSound(String phase) async {
    if (phase == "gap") return; // No sound for gap phase

    try {
      debugPrint('Before playing $phase sound, background state: ${_backgroundAudioPlayer.state}');
      // Don't stop previous bell sound, just play the new one
      if (phase == "inhale") {
        debugPrint('Playing inhale bell sound');
        await _bellPlayer.play(_inhaleSound);
      } else if (phase == "exhale") {
        debugPrint('Playing exhale bell sound');
        await _bellPlayer.play(_exhaleSound);
      }
      debugPrint('After playing $phase sound, background state: ${_backgroundAudioPlayer.state}');
    } catch (e) {
      debugPrint('Error playing phase sound: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing bell sound: $e')),
        );
      }
    }
  }

  // Start breathing cycle with bell sounds
  Future<void> _startBreathingCycle() async {
    if (!_guidesCompleted || _isGuide1Playing || _isGuide2Playing) {
      debugPrint('Cannot start breathing cycle: guides not completed');
      return;
    }

    setState(() {
      breathingText = "Inhale";
      _currentPhase = "inhale";
    });
    _controller.forward();

    if (isAudioPlaying) {
      // Play bell sound for current phase
      debugPrint('Starting breathing cycle, playing bell sound for $_currentPhase');
      _playPhaseSound(_currentPhase);
    } else {
      debugPrint('Audio muted, skipping bell audio');
    }
  }

  // Toggle breathing cycle (pause/resume)
  Future<void> toggleBreathing() async {
    if (!_guidesCompleted || _isGuide1Playing || _isGuide2Playing) return;

    if (isRunning) {
      _controller.stop();
      // Don't stop any audio players when pausing
      setState(() => isRunning = false);
      debugPrint('Breathing paused');
    } else {
      if (_currentRound >= widget.rounds) {
        _currentRound = 0;
      }
      setState(() => isRunning = true);
      debugPrint('Resuming breathing');
      _startBreathingCycle();
    }
  }

  // Toggle audio (mute/unmute both bell and ambient)
  Future<void> toggleAudio() async {
    final newVolume = isAudioPlaying ? 0.0 : 1.0;
    await _audioPlayer.setVolume(newVolume);
    await _bellPlayer.setVolume(newVolume);
    await _backgroundAudioPlayer.setVolume(newVolume);
    setState(() => isAudioPlaying = !isAudioPlaying);
    debugPrint('Audio ${isAudioPlaying ? 'unmuted' : 'muted'}');

    // If unmuting and background audio is not playing, start it
    if (isAudioPlaying && _backgroundSound != null) {
      if (_backgroundAudioPlayer.state != PlayerState.playing) {
        debugPrint('Resuming background audio after unmute');
        await _startBackgroundAudio();
      }
    }
  }

  Widget _buildTextDisplay(String text) {
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
        textAlign: TextAlign.center,
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
        height: 300,
        width: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(widget.imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    if (_isGuide1Playing || _isGuide2Playing) {
      return const SizedBox.shrink();
    }

    if (_currentRound >= widget.rounds) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _currentRound = 0;
            isRunning = true;
          });
          _controller.reset();
          _startBreathingCycle();
          if (isAudioPlaying && _backgroundSound != null && _backgroundAudioPlayer.state != PlayerState.playing) {
            debugPrint('Restarting background audio for repeat');
            _backgroundAudioPlayer.play(_backgroundSound!);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
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
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
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

  Widget _buildTimeProgressBar() {
    if (_isGuide1Playing || _isGuide2Playing) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = _controller.value;
        int totalSeconds = _controller.duration?.inSeconds ?? 1;
        int remainingSeconds = totalSeconds - (progress * totalSeconds).toInt();
        int minutes = remainingSeconds ~/ 60;
        int seconds = remainingSeconds % 60;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: 1 - progress,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _bellPlayer.dispose();
    _backgroundAudioPlayer.dispose();
    _skipButtonTimer.cancel();
    debugPrint('BilateralScreen disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Breathing",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  const SizedBox(height: 50),
                  _buildControlButtons(),
                  const SizedBox(height: 20),
                  _buildTimeProgressBar(),
                ],
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + 10,
            right: 15,
            child: IconButton(
              icon: Icon(
                isAudioPlaying ? Icons.music_note : Icons.music_off,
                color: Colors.teal,
                size: 36.0,
              ),
              onPressed: toggleAudio,
            ),
          ),
          if (_showSkipGuide1)
            Positioned(
              bottom: 100,
              right: 20,
              child: ElevatedButton(
                onPressed: _skipGuide1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Skip Guide",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}