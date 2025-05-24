import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class UjjayiBreathingScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;
  final String imagePath;
  final String inhaleAudioPath;
  final String exhaleAudioPath;
  final int countdownDuration; // Added countdown duration parameter

  const UjjayiBreathingScreen({
    Key? key,
    this.inhaleDuration = 4,
    this.exhaleDuration = 6,
    this.rounds = 5,
    this.imagePath = 'assets/images/option3.png',
    this.inhaleAudioPath = 'music/inhale_bell1.mp3',
    this.exhaleAudioPath = 'music/exhale_bell.mp3',
    this.countdownDuration = 3, // Default countdown of 3 seconds
  }) : super(key: key);

  @override
  _UjjayiBreathingScreenState createState() => _UjjayiBreathingScreenState();
}

class _UjjayiBreathingScreenState extends State<UjjayiBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _bellPlayer;
  late AudioCache _audioCache;

  bool isRunning = false;
  int completedRounds = 0;
  int totalRounds = 0;
  bool lastPhaseWasInhale = false;
  double bellVolume = 1.0;

  String breathingText = "Press Start";
  bool isCountingDown = false;
  int countdownValue = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    totalRounds = widget.rounds;
    countdownValue = widget.countdownDuration;

    _audioCache = AudioCache();

    _controller = AnimationController(
      duration: Duration(seconds: widget.inhaleDuration + widget.exhaleDuration),
      vsync: this,
    );

    _controller.addListener(() {
      double inhaleThreshold = widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration);

      if (_controller.value <= inhaleThreshold && (!lastPhaseWasInhale || _controller.value < 0.01)) {
        setState(() {
          breathingText = "Inhale";
          lastPhaseWasInhale = true;
        });
        _playBellSound(true);
      } else if (_controller.value > inhaleThreshold && lastPhaseWasInhale) {
        setState(() {
          breathingText = "Exhale";
          lastPhaseWasInhale = false;
        });
        _playBellSound(false);
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

    _bellPlayer = AudioPlayer();

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

    _bellPlayer.setAudioContext(audioContext);
    _setupBellPlayer();
    _preloadAudioFiles();
  }

  Future<void> _preloadAudioFiles() async {
    try {
      await _audioCache.loadAsFile(widget.inhaleAudioPath);
      await _audioCache.loadAsFile(widget.exhaleAudioPath);
      print('Audio files preloaded successfully');
    } catch (e) {
      print('Error preloading audio files: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sound files: $e')),
        );
      }
    }
  }

  Future<void> _setupBellPlayer() async {
    try {
      await _bellPlayer.setReleaseMode(ReleaseMode.release);
      await _bellPlayer.setVolume(bellVolume);
      print('Bell player setup complete');
    } catch (e) {
      print('Error setting up bell player: $e');
    }
  }

  Future<void> _playBellSound(bool isInhale) async {
    try {
      await _bellPlayer.stop();
      print('Playing ${isInhale ? "inhale" : "exhale"} bell sound');
      print('Audio path: ${isInhale ? widget.inhaleAudioPath : widget.exhaleAudioPath}');

      if (isInhale) {
        await _bellPlayer.play(AssetSource(widget.inhaleAudioPath));
      } else {
        await _bellPlayer.play(AssetSource(widget.exhaleAudioPath));
      }
    } catch (e) {
      print('Error playing bell sound: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing bell sound: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startCountdown() {
    setState(() {
      isCountingDown = true;
      countdownValue = widget.countdownDuration;
      breathingText = countdownValue.toString();
    });

    // Start countdown timer - NO sound during countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownValue > 1) {
        setState(() {
          countdownValue--;
          breathingText = countdownValue.toString();
        });
        // No sound played here anymore!
      } else {
        timer.cancel();
        _countdownTimer = null;
        setState(() {
          isCountingDown = false;
          breathingText = "Inhale";
        });
        _startBreathingCycle();
      }
    });
  }

  void _startBreathingCycle() {
    _controller.forward();
    // Play initial bell sound when starting
    if (_controller.value < 0.01) {
      _playBellSound(true);
    }
  }

  void toggleBreathing() {
    if (isRunning) {
      // Cancel countdown if it's running
      if (isCountingDown && _countdownTimer != null) {
        _countdownTimer!.cancel();
        _countdownTimer = null;
        setState(() {
          isCountingDown = false;
          breathingText = "Press Start";
        });
      } else {
        _controller.stop();
      }
      setState(() {
        isRunning = false;
      });
    } else {
      setState(() {
        isRunning = true;
        // Reset if completed
        if (breathingText == "Complete") {
          completedRounds = 0;
          lastPhaseWasInhale = false;
        }
      });

      // Start countdown before breathing
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bellPlayer.stop();
    _bellPlayer.dispose();
    if (_countdownTimer != null) {
      _countdownTimer!.cancel();
    }
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
          "Ujjayi Pranayama (${_getBreathingRatio()})",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: _showVolumeControl,
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

  void _showVolumeControl() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Bell Volume"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: bellVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        bellVolume = value;
                      });
                      _bellPlayer.setVolume(value);
                    },
                  ),
                ),
                Icon(Icons.volume_up),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text("Test Sound"),
              onPressed: () => _playBellSound(true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close"),
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
            style: TextStyle(
              fontSize: isCountingDown ? 50 : 30,  // Larger text for countdown
              fontWeight: FontWeight.bold,
              color: isCountingDown ? Colors.orange : Colors.white,  // Different color for countdown
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

          // During countdown, use a pulsing animation
          if (isCountingDown) {
            // Create a pulse effect during countdown
            scale = 1.0 + 0.2 * (countdownValue % 2 == 0 ? 1 : 0);
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
                color: isCountingDown
                    ? Colors.orange.withOpacity(0.75)  // Orange glow during countdown
                    : Colors.blue.shade600.withOpacity(0.75),
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
              ? "Get Ready..."
              : "Round ${completedRounds + (isRunning && !isCountingDown ? 1 : 0)} of $totalRounds",
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
                  ? 1 - (countdownValue / widget.countdownDuration)  // Countdown progress
                  : totalRounds > 0 ? (completedRounds / totalRounds) : 0,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isCountingDown ? Colors.orange : Colors.blue
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
        backgroundColor: isRunning ? Colors.red : Colors.blue,
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