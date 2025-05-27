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
    this.inhaleDuration = 4,
    this.exhaleDuration = 6,
    this.rounds = 5,
    this.imagePath = 'assets/images/option3.png',
    this.audioPath = '',
    this.inhaleAudioPath = 'assets/music/inhale-bell1.mp3',
    this.exhaleAudioPath = 'assets/music/exhale_bell.mp3',
  }) : super(key: key);

  @override
  _BilateralScreenState createState() => _BilateralScreenState();
}

class _BilateralScreenState extends State<BilateralScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> sizeTween;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _bellPlayer;

  bool isRunning = false;
  bool isAudioPlaying = false;
  bool shouldPlayAudio = false; // Track if audio should be playing
  int completedRounds = 0;
  int totalRounds = 0;
  bool lastPhaseWasInhale = false;

  // Volume control variables
  double ambientVolume = 0.7; // Default volume (0.0 to 1.0)
  double bellVolume = 1.0; // Default volume (0.0 to 1.0)
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
          setState(() {
            isRunning = false;
            breathingText = "Complete";
          });
          // Pause audio when exercise completes
          await _pauseAmbientAudio();
          return;
        }

        _controller.reset();
        setState(() {
          lastPhaseWasInhale = false;
        });

        await Future.delayed(const Duration(milliseconds: 5));

        if (isRunning) {
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
      // Stop any current playing to avoid overlap
      await _bellPlayer.stop();
      // Play different bell sounds for inhale and exhale
      if (breathingText == "Inhale") {
        await _bellPlayer.play(AssetSource(widget.inhaleAudioPath));
      } else {
        await _bellPlayer.play(AssetSource(widget.exhaleAudioPath));
      }
    } catch (e) {
      print('Error playing bell sound: $e');
    }
  }

  // Helper method to pause ambient audio
  Future<void> _pauseAmbientAudio() async {
    if (isAudioPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isAudioPlaying = false;
      });
    }
  }

  // Helper method to resume ambient audio if it should be playing
  Future<void> _resumeAmbientAudio() async {
    if (shouldPlayAudio && !isAudioPlaying && widget.audioPath.isNotEmpty) {
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
          print('Error playing audio: $e');
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
          // Resume audio if it should be playing
          _resumeAmbientAudio();
        }
      });
    });
  }

  void _startBreathingCycle() {
    setState(() {
      isRunning = true;
    });
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
      // Pause ambient audio when breathing is paused
      _pauseAmbientAudio();
    } else if (isCountingDown) {
      // Cancel countdown if it's in progress
      _countdownTimer?.cancel();
      setState(() {
        isCountingDown = false;
        breathingText = "Inhale";
      });
      // Pause audio when canceling countdown
      _pauseAmbientAudio();
    } else {
      // Reset if completed
      if (breathingText == "Complete") {
        setState(() {
          completedRounds = 0;
          lastPhaseWasInhale = false;
        });
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

    setState(() {
      shouldPlayAudio = !shouldPlayAudio;
    });

    if (shouldPlayAudio) {
      // Only start audio if breathing is actually running (not paused)
      if (isRunning || isCountingDown) {
        try {
          if (isAudioPlaying) {
            await _audioPlayer.resume();
          } else {
            await _audioPlayer.play(AssetSource(widget.audioPath));
            setState(() {
              isAudioPlaying = true;
            });
          }
        } catch (e) {
          print('Error playing audio: $e');
        }
      }
    } else {
      // Always pause audio when toggled off
      await _pauseAmbientAudio();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _bellPlayer.dispose();
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
          "Bilateral Breathing (${_getBreathingRatio()})",
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
                shouldPlayAudio ? Icons.music_note : Icons.music_off,
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
            text,
            style: TextStyle(
              fontSize: isCountdown ? 50 : 30, // Larger font for countdown
              fontWeight: FontWeight.bold,
              color: isCountdown ? Colors.amber : Colors.white, // Amber color for countdown
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

          // Don't animate during countdown
          if (isCountingDown) {
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
                color: Colors.blue.shade600.withOpacity(0.75),
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
                  isCountingDown ? Colors.amber : Colors.blue
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
        backgroundColor: isCountingDown ? Colors.amber : Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      icon: Icon(
          isCountingDown ? Icons.cancel : (isRunning ? Icons.pause : Icons.play_arrow)
      ),
      label: Text(
        isCountingDown
            ? "Cancel"
            : (isRunning ? "Pause" : (completedRounds >= totalRounds && totalRounds > 0) ? "Restart" : "Start"),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}