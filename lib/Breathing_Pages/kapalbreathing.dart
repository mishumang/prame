import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math' as math;

class KapalBreathingScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleInterval;
  final int rounds;
  final String imagePath;
  final String audioPath;
  final String inhaleAudioPath;
  final String exhaleAudioPath;

  const KapalBreathingScreen({
    Key? key,
    required this.inhaleDuration,
    required this.exhaleInterval,
    required this.rounds,
    required this.imagePath,
    required this.audioPath,
    required this.inhaleAudioPath,
    required this.exhaleAudioPath,
  }) : super(key: key);

  @override
  _KapalBreathingScreenState createState() => _KapalBreathingScreenState();
}

class _KapalBreathingScreenState extends State<KapalBreathingScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();
  double ambientVolume = 0.3;
  double bellVolume = 0.7;

  // Breathing State
  bool isRunning = false;
  bool isPaused = false;
  bool isCountingDown = false;
  bool isInhalePhase = false;
  bool isExhalePhase = false;
  bool isHoldPhase = false;
  int countdownValue = 3;

  // Kapal Bhati specific
  int totalRounds = 3;
  int completedRounds = 0;
  int totalExhalesPerRound = 30;
  int currentExhaleCount = 0;
  double currentScale = 1.0;

  // Timers
  Timer? _breathingTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    totalRounds = widget.rounds;
    _initializeAnimations();
    _preloadAudio();
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: Duration(milliseconds: widget.inhaleDuration * 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: widget.exhaleInterval * 500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _breathingController.addListener(() {
      setState(() {
        currentScale = _scaleAnimation.value;
      });
    });
  }

  Future<void> _preloadAudio() async {
    try {
      if (widget.audioPath.isNotEmpty) {
        await _audioPlayer.setSource(AssetSource(widget.audioPath));
        await _audioPlayer.setVolume(ambientVolume);
      }

      if (widget.inhaleAudioPath.isNotEmpty) {
        await _bellPlayer.setSource(AssetSource(widget.inhaleAudioPath));
        await _bellPlayer.setVolume(bellVolume);
      }
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  void _startBreathing() {
    if (!isRunning) {
      setState(() {
        isCountingDown = true;
        countdownValue = 3;
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countdownValue--;
      });

      if (countdownValue <= 0) {
        timer.cancel();
        _beginBreathingSequence();
      }
    });
  }

  void _beginBreathingSequence() {
    setState(() {
      isCountingDown = false;
      isRunning = true;
      completedRounds = 0;
      currentExhaleCount = 0;
    });

    _playAmbientSound();
    _startKapalBhatiCycle();
  }

  void _startKapalBhatiCycle() {
    if (completedRounds >= totalRounds) {
      _completeSession();
      return;
    }

    // Start with inhale phase
    setState(() {
      isInhalePhase = true;
      isExhalePhase = false;
      currentExhaleCount = 0;
    });

    // Long inhale (use configured duration)
    _breathingController.forward();
    _playInhaleSound();

    Timer(Duration(seconds: widget.inhaleDuration), () {
      if (mounted) {
        _startExhaleSequence();
      }
    });
  }

  void _startExhaleSequence() {
    setState(() {
      isInhalePhase = false;
      isExhalePhase = true;
      currentExhaleCount = 1;
    });

    _performSharpExhales();
  }

  void _performSharpExhales() {
    if (currentExhaleCount > totalExhalesPerRound) {
      _completeRound();
      return;
    }

    // Sharp exhale animation
    _pulseController.forward().then((_) {
      if (mounted) {
        _pulseController.reset();
        _playExhaleSound();

        setState(() {
          currentExhaleCount++;
        });

        if (currentExhaleCount <= totalExhalesPerRound) {
          Timer(Duration(milliseconds: widget.exhaleInterval * 500), () {
            if (mounted && isRunning && !isPaused) {
              _performSharpExhales();
            }
          });
        } else {
          _completeRound();
        }
      }
    });
  }

  void _completeRound() {
    setState(() {
      completedRounds++;
      isExhalePhase = false;
      isInhalePhase = false;
    });

    _playBellSound();
    _breathingController.reset();

    // Pause between rounds
    Timer(Duration(seconds: 3), () {
      if (mounted && isRunning && !isPaused) {
        if (completedRounds < totalRounds) {
          _startKapalBhatiCycle();
        } else {
          _completeSession();
        }
      }
    });
  }

  void _completeSession() {
    setState(() {
      isRunning = false;
      isInhalePhase = false;
      isExhalePhase = false;
      completedRounds = 0;
      currentExhaleCount = 0;
    });

    _stopAmbientSound();
    _playBellSound();
    _breathingController.reset();

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Session Complete'),
            ],
          ),
          content: Text('Great job! You have completed your Kapal Bhati breathing session.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _pauseBreathing() {
    setState(() {
      isPaused = !isPaused;
    });

    if (isPaused) {
      _breathingController.stop();
      _audioPlayer.pause();
      _breathingTimer?.cancel();
    } else {
      _audioPlayer.resume();
      // Resume the current phase
      if (isInhalePhase) {
        _breathingController.forward();
      } else if (isExhalePhase) {
        _performSharpExhales();
      }
    }
  }

  void _stopBreathing() {
    setState(() {
      isRunning = false;
      isPaused = false;
      isInhalePhase = false;
      isExhalePhase = false;
      completedRounds = 0;
      currentExhaleCount = 0;
    });

    _breathingController.reset();
    _pulseController.reset();
    _stopAmbientSound();
    _breathingTimer?.cancel();
    _countdownTimer?.cancel();
  }

  Future<void> _playAmbientSound() async {
    try {
      if (widget.audioPath.isNotEmpty) {
        await _audioPlayer.resume();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      }
    } catch (e) {
      debugPrint('Error playing ambient sound: $e');
    }
  }

  void _stopAmbientSound() {
    try {
      _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping ambient sound: $e');
    }
  }

  Future<void> _playInhaleSound() async {
    try {
      if (widget.inhaleAudioPath.isNotEmpty) {
        await _bellPlayer.setSource(AssetSource(widget.inhaleAudioPath));
        await _bellPlayer.resume();
      }
    } catch (e) {
      debugPrint('Error playing inhale sound: $e');
    }
  }

  Future<void> _playExhaleSound() async {
    try {
      if (widget.exhaleAudioPath.isNotEmpty) {
        await _bellPlayer.setSource(AssetSource(widget.exhaleAudioPath));
        await _bellPlayer.resume();
      }
    } catch (e) {
      debugPrint('Error playing exhale sound: $e');
    }
  }

  Future<void> _playBellSound() async {
    try {
      await _bellPlayer.setSource(AssetSource('sounds/inhale_bell.mp3'));
      await _bellPlayer.resume();
    } catch (e) {
      debugPrint('Error playing bell sound: $e');
    }
  }

  String _getPhaseText() {
    if (isCountingDown) {
      return 'Get Ready';
    } else if (isInhalePhase) {
      return 'Deep Inhale';
    } else if (isExhalePhase) {
      return 'Sharp Exhales';
    } else if (isRunning) {
      return 'Rest';
    } else {
      return 'Kapal Bhati Breathing';
    }
  }

  String _getInstructionText() {
    if (isCountingDown) {
      return 'Prepare for your breathing session';
    } else if (isInhalePhase) {
      return 'Take a deep, slow breath in through your nose';
    } else if (isExhalePhase) {
      return 'Make sharp, forceful exhales through your nose';
    } else if (isRunning) {
      return 'Rest and breathe normally';
    } else {
      return 'Tap the button below to begin your practice';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Kapal Bhati Breathing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Progress indicator
            if (isRunning && !isCountingDown)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      'Round ${completedRounds + 1} of $totalRounds',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: completedRounds / totalRounds,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    if (isExhalePhase) ...[
                      SizedBox(height: 16),
                      Text(
                        'Exhale $currentExhaleCount of $totalExhalesPerRound',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Countdown or breathing animation
                    if (isCountingDown)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            countdownValue > 0 ? '$countdownValue' : 'Begin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                    // Breathing circle animation
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ripple effect
                              Container(
                                width: 300 + (math.sin(_waveController.value * 2 * math.pi) * 20),
                                height: 300 + (math.sin(_waveController.value * 2 * math.pi) * 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Main breathing circle
                              Transform.scale(
                                scale: isInhalePhase ? currentScale :
                                isExhalePhase ? (1.0 + _pulseAnimation.value * 0.1) : 1.0,
                                child: Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.orange.withOpacity(0.8),
                                        Colors.orange.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 3,
                                    ),
                                  ),
                                  child: widget.imagePath.isNotEmpty
                                      ? ClipOval(
                                    child: Image.asset(
                                      widget.imagePath,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : Icon(
                                    Icons.self_improvement,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    SizedBox(height: 40),

                    // Phase text
                    Text(
                      _getPhaseText(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Instruction text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _getInstructionText(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Control buttons
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isRunning && !isCountingDown) ...[
                    // Pause/Resume button
                    FloatingActionButton(
                      onPressed: _pauseBreathing,
                      backgroundColor: Colors.orange,
                      child: Icon(
                        isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    // Stop button
                    FloatingActionButton(
                      onPressed: _stopBreathing,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ] else if (!isCountingDown) ...[
                    // Start button
                    FloatingActionButton.extended(
                      onPressed: _startBreathing,
                      backgroundColor: Colors.orange,
                      label: Text(
                        'Start Practice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _audioPlayer.dispose();
    _bellPlayer.dispose();
    _breathingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}