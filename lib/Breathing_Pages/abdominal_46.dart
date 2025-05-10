import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class Abdominal46Screen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;
  final String imagePath;
  final String audioPath;

  const Abdominal46Screen({
    Key? key,
    this.inhaleDuration = 4,
    this.exhaleDuration = 6,
    this.rounds = 5,
    this.imagePath = 'assets/images/option3.png',
    this.audioPath = '',
  }) : super(key: key);

  @override
  _Abdominal46ScreenState createState() => _Abdominal46ScreenState();
}

class _Abdominal46ScreenState extends State<Abdominal46Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;
  late AudioPlayer _ambientPlayer;
  late AudioPlayer _bellPlayer;

  bool _isRunning = false;
  bool _isAmbientPlaying = false;
  int _completedRounds = 0;
  int _totalRounds = 0;
  bool _isInhalePhase = true;
  String _breathPhaseText = "Prepare";
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _totalRounds = widget.rounds;

    // Initialize audio players
    _ambientPlayer = AudioPlayer();
    _bellPlayer = AudioPlayer();

    // Set up audio context for simultaneous playback
    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    );

    _ambientPlayer.setAudioContext(audioContext);
    _bellPlayer.setAudioContext(audioContext);

    // Configure ambient sound if provided
    if (widget.audioPath.isNotEmpty) {
      _setupAmbientSound();
    }

    // Configure bell player
    _setupBellPlayer();

    // Set up animation controller
    _controller = AnimationController(
      duration: Duration(seconds: widget.inhaleDuration + widget.exhaleDuration),
      vsync: this,
    );

    // Define breathing animation
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Add listener to update UI and play sounds at appropriate times
    _controller.addListener(_updateBreathingState);

    // Handle animation completion and round tracking
    _controller.addStatusListener(_handleAnimationStatus);

    // Start with a short delay to allow screen to fully load
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _breathPhaseText = "Ready";
      });
    });
  }

  Future<void> _setupAmbientSound() async {
    try {
      await _ambientPlayer.setSourceAsset(widget.audioPath);
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setVolume(0.5); // Set ambient sound at 50% volume
    } catch (e) {
      debugPrint('Error setting up ambient sound: $e');
    }
  }

  Future<void> _setupBellPlayer() async {
    try {
      await _bellPlayer.setReleaseMode(ReleaseMode.release);
      await _bellPlayer.setVolume(1.0); // Bell sounds at full volume
    } catch (e) {
      debugPrint('Error setting up bell player: $e');
    }
  }

  void _updateBreathingState() {
    // Calculate normalized progress within the current breathing cycle
    final cycleProgress = _controller.value;
    final inhaleThreshold = widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration);

    // Update the progress for UI display
    setState(() {
      _progress = cycleProgress;
    });

    // Handle phase transitions
    if (cycleProgress <= inhaleThreshold) {
      // Inhale phase
      if (!_isInhalePhase) {
        _isInhalePhase = true;
        setState(() {
          _breathPhaseText = "Inhale";
        });
        _playBellSound(true);
      }
    } else {
      // Exhale phase
      if (_isInhalePhase) {
        _isInhalePhase = false;
        setState(() {
          _breathPhaseText = "Exhale";
        });
        _playBellSound(false);
      }
    }
  }

  void _handleAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _completedRounds++;

      // Check if we've completed all rounds
      if (_completedRounds >= _totalRounds) {
        setState(() {
          _isRunning = false;
          _breathPhaseText = "Complete";
        });

        // Give haptic feedback on completion
        HapticFeedback.mediumImpact();

        return;
      }

      // Reset and start next round
      _controller.reset();

      // Small delay before next round
      await Future.delayed(const Duration(milliseconds: 300));

      if (_isRunning) {
        _controller.forward();
      }
    }
  }

  Future<void> _playBellSound(bool isInhale) async {
    try {
      await _bellPlayer.stop();

      if (isInhale) {
        await _bellPlayer.play(AssetSource('music/inhale_bell.mp3'));
      } else {
        await _bellPlayer.play(AssetSource('music/exhale_bell.mp3'));
      }
    } catch (e) {
      debugPrint('Error playing bell sound: $e');
    }
  }

  void _toggleExercise() {
    HapticFeedback.lightImpact();

    if (_isRunning) {
      _controller.stop();
      setState(() {
        _isRunning = false;
      });
    } else {
      // If exercise was completed, reset rounds
      if (_breathPhaseText == "Complete") {
        setState(() {
          _completedRounds = 0;
          _breathPhaseText = "Inhale";
          _isInhalePhase = true;
        });
        _controller.reset();
      }

      setState(() {
        _isRunning = true;
      });

      // Play initial bell sound
      _playBellSound(true);

      // Start animation
      _controller.forward();
    }
  }

  Future<void> _toggleAmbientSound() async {
    if (widget.audioPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ambient sound selected')),
      );
      return;
    }

    if (_isAmbientPlaying) {
      await _ambientPlayer.pause();
    } else {
      try {
        await _ambientPlayer.resume();
      } catch (e) {
        // If resume fails, try playing from the beginning
        try {
          await _ambientPlayer.play(AssetSource(widget.audioPath));
        } catch (e) {
          debugPrint('Error playing ambient sound: $e');
        }
      }
    }

    setState(() {
      _isAmbientPlaying = !_isAmbientPlaying;
    });
  }

  String _getRemainingTime() {
    final totalSeconds = _totalRounds * (widget.inhaleDuration + widget.exhaleDuration);
    final remainingRounds = _totalRounds - _completedRounds;
    final currentRoundRemaining = _isRunning
        ? (1 - _controller.value) * (widget.inhaleDuration + widget.exhaleDuration)
        : widget.inhaleDuration + widget.exhaleDuration;

    final remainingSeconds = (remainingRounds - 1) * (widget.inhaleDuration + widget.exhaleDuration) + currentRoundRemaining;

    final minutes = (remainingSeconds / 60).floor();
    final seconds = (remainingSeconds % 60).floor();

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.removeListener(_updateBreathingState);
    _controller.dispose();
    _ambientPlayer.dispose();
    _bellPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Abdominal 4:6',
          style: TextStyle(
            color: Colors.blue[200],
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.audioPath.isNotEmpty)
            IconButton(
              icon: Icon(
                _isAmbientPlaying ? Icons.music_note : Icons.music_off,
                color: Colors.white,
              ),
              onPressed: _toggleAmbientSound,
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.blueGrey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Breath phase text display
              _buildBreathPhaseText(),

              // Breathing visualization
              _buildBreathingVisualization(),

              // Progress display
              _buildProgressIndicator(),

              // Control buttons
              _buildControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreathPhaseText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _breathPhaseText,
        style: TextStyle(
          color: _isInhalePhase ? Colors.blue[200] : Colors.teal[200],
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildBreathingVisualization() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale;

        // Calculate current scale based on the breathing phase
        if (_isInhalePhase) {
          final inhaleThreshold = widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration);
          final phaseProgress = _progress / inhaleThreshold;
          scale = 1.0 + (0.6 * phaseProgress);
        } else {
          final inhaleThreshold = widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration);
          final phaseProgress = (_progress - inhaleThreshold) / (1 - inhaleThreshold);
          scale = 1.6 - (0.6 * phaseProgress);
        }

        if (!_isRunning) {
          scale = 1.0;
        }

        return Container(
          height: 300,
          width: 300,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 260 * scale,
                height: 260 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isInhalePhase
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.teal.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),

              // Inner breathing circle with image
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isInhalePhase
                            ? Colors.blue.withOpacity(0.7)
                            : Colors.teal.withOpacity(0.7),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Round ${_completedRounds + (_isRunning ? 1 : 0)} of $_totalRounds',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getRemainingTime(),
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              // Total progress bar
              FractionallySizedBox(
                widthFactor: _totalRounds > 0 ? _completedRounds / _totalRounds : 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.teal[400]!],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Current round progress indicator
              if (_isRunning && _totalRounds > 0)
                Positioned(
                  left: (_completedRounds / _totalRounds) *
                      MediaQuery.of(context).size.width * 0.8,
                  child: FractionallySizedBox(
                    widthFactor: (1 / _totalRounds) * _progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isInhalePhase ? Colors.blue[400] : Colors.teal[400],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _toggleExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRunning ? Colors.teal[600] : Colors.blue[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            shadowColor: _isRunning ? Colors.teal[300] : Colors.blue[300],
          ),
          icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 30),
          label: Text(
            _isRunning ? 'PAUSE' :
            (_breathPhaseText == "Complete" ? 'RESTART' : 'START'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}