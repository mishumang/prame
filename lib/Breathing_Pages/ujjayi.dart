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

  const UjjayiBreathingScreen({
    Key? key,
    this.inhaleDuration = 4,
    this.exhaleDuration = 6,
    this.rounds = 5,
    this.imagePath = 'assets/images/option3.png',
    this.inhaleAudioPath = 'assets/music/inhale_bell1.mp3',
    this.exhaleAudioPath = 'assets/music/exhale_bell1.mp3',
  }) : super(key: key);

  @override
  _UjjayiBreathingScreenState createState() => _UjjayiBreathingScreenState();
}

class _UjjayiBreathingScreenState extends State<UjjayiBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _bellPlayer;

  bool isRunning = false;
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

    // Set AudioContext for bell sounds
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
  }

  Future<void> _setupBellPlayer() async {
    try {
      await _bellPlayer.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      print('Error setting up bell player: $e');
    }
  }

  Future<void> _playBellSound(bool isInhale) async {
    try {
      // Stop any current playing to avoid overlap
      await _bellPlayer.stop();
      // Play different bell sounds for inhale and exhale
      if (isInhale) {
        await _bellPlayer.play(AssetSource(widget.inhaleAudioPath));
      } else {
        await _bellPlayer.play(AssetSource(widget.exhaleAudioPath));
      }
    } catch (e) {
      print('Error playing bell sound: $e');
    }
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

  @override
  void dispose() {
    _controller.dispose();
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
          "Ujjayi Pranayama (${_getBreathingRatio()})",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
        backgroundColor: Colors.blue,
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

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Ujjayi Breathing Tips:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff98bad5),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "• Breathe through your nose\n"
                "• Constrict the back of your throat slightly\n"
                "• Create an ocean-like sound when breathing\n"
                "• Keep your shoulders relaxed\n"
                "• Focus on the breath sensation and sound",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Main entry point for Ujjayi Pranayama exercise page
class UjjayiPranayamaPage extends StatefulWidget {
  @override
  _UjjayiPranayamaPageState createState() => _UjjayiPranayamaPageState();
}

class _UjjayiPranayamaPageState extends State<UjjayiPranayamaPage> {
  String _selectedTechnique = '4:6';
  String _selectedImage = 'assets/images/option3.png'; // Default image
  final Map<String, String> _techniques = {
    '4:6': '4:6 Breathing (Recommended)',
    '2:3': '2:3 Breathing',
  };
  final List<Map<String, String>> _imageOptions = [
    {'name': 'Option 1', 'path': 'assets/images/option3.png'},
    {'name': 'Option 2', 'path': 'assets/images/option1.png'},
    {'name': 'Option 3', 'path': 'assets/images/option2.png'},
  ];

  bool _isMinutesMode = false;
  int _selectedDuration = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ujjayi Pranayama"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xff98bad5),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("Breathing Technique"),
            SizedBox(height: 8),
            _buildTechniqueButtons(),
            SizedBox(height: 24),
            _buildSectionTitle("Visualization Image"),
            SizedBox(height: 8),
            _buildImageSelector(),
            SizedBox(height: 24),
            _buildSectionTitle("Duration"),
            _buildDurationControls(),
            SizedBox(height: 24),
            _buildCustomizeButton(),
            SizedBox(height: 16),
            _buildBeginButton(),
            SizedBox(height: 24),
            // Steps dropdown
            ExpansionTile(
              title: Text(
                "How To Practice",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              children: _buildInstructionSteps(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Learn more button
  Widget _buildLearnMoreButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: TextButton(
          onPressed: () {
            // You can implement the "Learn More" page navigation here
          },
          child: Text(
            "Learn More →",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // Technique selection buttons
  Widget _buildTechniqueButtons() {
    return Row(
      children: _techniques.entries.map((entry) {
        bool isSelected = _selectedTechnique == entry.key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Color(0xff98bad5) : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () => setState(() => _selectedTechnique = entry.key),
              child: Column(
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (entry.key == '4:6') SizedBox(height: 4),
                  if (entry.key == '4:6')
                    Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Image selector
  Widget _buildImageSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _imageOptions.map((image) {
        bool isSelected = _selectedImage == image['path'];
        return GestureDetector(
          onTap: () => setState(() => _selectedImage = image['path']!),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Color(0xff98bad5) : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(image['path']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black54,
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  image['name']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Duration controls
  Widget _buildDurationControls() {
    final List<int> options = _isMinutesMode
        ? [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
        : [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleOption("Rounds", !_isMinutesMode),
            SizedBox(width: 20),
            _buildToggleOption("Minutes", _isMinutesMode),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDuration = options[index]);
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _selectedDuration == options[index]
                        ? Color(0xff98bad5)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      options[index].toString(),
                      style: TextStyle(
                        fontSize: 20,
                        color: _selectedDuration == options[index]
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        _buildDurationHint(),
      ],
    );
  }

  // Toggle option for duration mode
  Widget _buildToggleOption(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isMinutesMode = text == "Minutes"),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Color(0xff98bad5) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Color(0xff98bad5) : Colors.grey[400]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Duration hint text
  Widget _buildDurationHint() {
    final inhale = _selectedTechnique == '4:6' ? 4 : 2;
    final exhale = _selectedTechnique == '4:6' ? 6 : 3;
    final totalSeconds = _isMinutesMode
        ? _selectedDuration * 60
        : _selectedDuration * (inhale + exhale);

    return Text(
      _isMinutesMode
          ? "≈ ${(_selectedDuration * 60 / (inhale + exhale)).toStringAsFixed(0)} rounds"
          : "≈ ${(totalSeconds / 60).toStringAsFixed(1)} minutes",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  // Customize button
  Widget _buildCustomizeButton() {
    return OutlinedButton.icon(
      icon: Icon(Icons.settings, size: 20, color: Colors.black),
      label: Text("Customize Breathing Pattern"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Color(0xff98bad5)),
      ),
      onPressed: () async {
        // Here you would implement the customization dialog
        // For now, we'll just use the defaults
      },
    );
  }

  // Begin exercise button
  Widget _buildBeginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          final inhale = _selectedTechnique == '4:6' ? 4 : 2;
          final exhale = _selectedTechnique == '4:6' ? 6 : 3;
          final rounds = _isMinutesMode
              ? (_selectedDuration * 60) ~/ (inhale + exhale)
              : _selectedDuration;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UjjayiBreathingScreen(
                inhaleDuration: inhale,
                exhaleDuration: exhale,
                rounds: rounds,
                imagePath: _selectedImage,
                inhaleAudioPath: 'assets/music/inhale_bell1.mp3',
                exhaleAudioPath: 'assets/music/exhale_bell1.mp3',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff98bad5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "BEGIN EXERCISE",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Instruction steps
  List<Widget> _buildInstructionSteps() {
    return [
      _buildStepCard(1, "Sit comfortably with your spine straight and shoulders relaxed."),
      _buildStepCard(2, "Inhale slowly through your nose, constricting the back of your throat to create a soft sound."),
      _buildStepCard(3, "Exhale through your nose while maintaining that gentle constriction."),
      _buildStepCard(4, "Continue for your selected duration, focusing on the sound and rhythm."),
      _buildStepCard(5, "When finished, relax the throat and resume normal breathing."),
    ];
  }

  // Step card widget
  Widget _buildStepCard(int num, String text) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xff98bad5),
              child: Text(
                num.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}