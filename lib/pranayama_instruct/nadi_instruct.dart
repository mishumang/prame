import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Import your breathing exercise screen.
import '../Breathing_Pages/bilateral_screen.dart';
// Import the modified TimerPickerWidget.
import '../common_widgets/timer_widget.dart';

enum DurationMode { rounds, minutes }

class NadiShodhanaPage extends StatefulWidget {
  @override
  _NadiShodhanaPageState createState() => _NadiShodhanaPageState();
}

class _NadiShodhanaPageState extends State<NadiShodhanaPage> {
  // Hardcoded YouTube video URL.
  final String _videoUrl = "https://www.youtube.com/watch?v=HhDUXFJDgB4";
  late YoutubePlayerController _youtubePlayerController;

  // Default mode: rounds.
  DurationMode _durationMode = DurationMode.rounds;
  // The picker value represents rounds or minutes. (Default set to 5)
  double _pickerValue = 5.0;

  @override
  void initState() {
    super.initState();
    // Initialize the YouTube player controller.
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_videoUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  /// Returns the total seconds for one round.
  int _getRoundSeconds() {
    // Assuming each round of Nadi Shodhana takes 10 seconds (inhale + exhale).
    return 10;
  }

  /// Calculates total minutes from the selected rounds.
  int _calculateTotalMinutesFromRounds() {
    int secondsPerRound = _getRoundSeconds();
    int totalSeconds = (secondsPerRound * _pickerValue).toInt();
    return (totalSeconds / 60).round();
  }

  /// Calculates maximum rounds possible from the selected minutes.
  int _calculateRoundsFromMinutes() {
    int secondsPerRound = _getRoundSeconds();
    if (secondsPerRound == 0) return 0;
    int totalSeconds = (_pickerValue * 60).toInt();
    return totalSeconds ~/ secondsPerRound;
  }

  /// Navigates to the breathing exercise screen.
  void _navigateToTechnique() {
    int rounds;
    if (_durationMode == DurationMode.rounds) {
      rounds = _pickerValue.toInt();
    } else {
      rounds = _calculateRoundsFromMinutes();
    }

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BilateralScreen(
    //       inhaleDuration: 4,
    //       exhaleDuration: 6,
    //       rounds: rounds,
    //     ),
    //   ),
    // );
  }

  Widget _buildInstructionCard(int step, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Text(
            "$step",
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(content),
      ),
    );
  }

  Widget _buildDurationModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<DurationMode>(
          value: DurationMode.rounds,
          groupValue: _durationMode,
          onChanged: (value) {
            setState(() {
              _durationMode = value!;
              // Reset the picker value for the new mode.
              _pickerValue = 5.0;
            });
          },
        ),
        Text("Rounds"),
        Radio<DurationMode>(
          value: DurationMode.minutes,
          groupValue: _durationMode,
          onChanged: (value) {
            setState(() {
              _durationMode = value!;
              _pickerValue = 5.0;
            });
          },
        ),
        Text("Minutes"),
      ],
    );
  }

  // Build the picker with dynamic options.
  Widget _buildPicker() {
    // If rounds mode: increments of 5 up to 100.
    // If minutes mode: increments of 5 up to 60.
    final List<int> options = _durationMode == DurationMode.rounds
        ? List<int>.generate(20, (index) => (index + 1) * 5)
        : List<int>.generate(12, (index) => (index + 1) * 5);

    final String titleLabel = _durationMode == DurationMode.rounds
        ? "Select Rounds"
        : "Select Duration";
    final String bottomLabel = _durationMode == DurationMode.rounds
        ? "rounds"
        : "minutes";

    return TimerPickerWidget(
      durations: options,
      initialDuration: _pickerValue.toInt(),
      titleLabel: titleLabel,
      bottomLabel: bottomLabel,
      onDurationSelected: (selectedValue) {
        setState(() {
          _pickerValue = selectedValue.toDouble();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int roundSeconds = _getRoundSeconds();

    return Scaffold(
      appBar: AppBar(
        title: Text("Nadi Shodhana"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Duration controls.
            if (roundSeconds > 0) ...[
              _buildDurationModeToggle(),
              SizedBox(height: 8.0),
              _buildPicker(),
              SizedBox(height: 8.0),
              _durationMode == DurationMode.rounds
                  ? Text(
                "Total Time: ${_calculateTotalMinutesFromRounds()} minute(s)",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
                textAlign: TextAlign.center,
              )
                  : Text(
                "Maximum Rounds Possible: ${_calculateRoundsFromMinutes()}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              // Begin button below the timer widget.
              ElevatedButton(
                onPressed: _navigateToTechnique,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: Text("Begin"),
              ),
            ],
            SizedBox(height: 24.0),
            Text(
              "What is Nadi Shodhana?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(
              "Nadi Shodhana, also known as Alternate Nostril Breathing, is a powerful breathing technique that helps balance the body's energy channels, calm the mind, and improve focus.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text(
              "Watch a Demonstration",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            YoutubePlayer(
              controller: _youtubePlayerController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.teal,
            ),
            SizedBox(height: 24.0),
            Text(
              "Step-by-Step Instructions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            _buildInstructionCard(
                1, "Sit in a comfortable, upright posture."),
            _buildInstructionCard(
                2, "Use your right thumb to close your right nostril."),
            _buildInstructionCard(
                3, "Inhale through your left nostril."),
            _buildInstructionCard(
                4, "Exhale through your left nostril."),
            _buildInstructionCard(
                5, "Use your ring finger to close your left nostril."),
            _buildInstructionCard(
                6, "Inhale through your right nostril."),
            _buildInstructionCard(
                7, "Exhale through your right nostril."),
            _buildInstructionCard(
                8, "Repeat the cycle."),
            SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}