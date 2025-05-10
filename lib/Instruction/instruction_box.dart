import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../Breathing_Pages/boxbreathing_screen.dart';
import '../common_widgets/timer_widget.dart';

class BoxBreathingLearnMorePage extends StatelessWidget {
  const BoxBreathingLearnMorePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn More: Box Breathing")),
      body: const Center(
        child: Text(
          "Detailed information about Box Breathing goes here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

enum DurationMode { rounds, minutes }

class BoxBreathingPage extends StatefulWidget {
  const BoxBreathingPage({Key? key}) : super(key: key);
  @override
  _BoxBreathingPageState createState() => _BoxBreathingPageState();
}

class _BoxBreathingPageState extends State<BoxBreathingPage> {
  static const Color _brandColor = Color(0xff98bad5);

  String _selectedTechnique = '4:4:4:4';
  final Map<String, String> _techniques = {
    '4:4:4:4': '4:4:4:4 (Recommended)',
    '4:4:6:4': '4:4:6:4',
  };

  final String _videoUrl = "https://www.youtube.com/watch?v=tEmt1Znux58";
  late YoutubePlayerController _ytController;

  bool _isMinutesMode = false;
  int _selectedDuration = 5;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_videoUrl)!,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  int get _roundSeconds {
    final parts = _selectedTechnique.split(":").map(int.parse).toList();
    return parts.fold(0, (sum, v) => sum + v);
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Box Breathing"),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: _brandColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("Breathing Technique"),
            const SizedBox(height: 8),
            _buildTechniqueButtons(),
            const SizedBox(height: 24),

            _buildSectionTitle("Duration"),
            const SizedBox(height: 8),
            _buildDurationControls(),
            const SizedBox(height: 8),
            _buildDurationHint(),
            const SizedBox(height: 24),

            _buildBeginButton(),
            const SizedBox(height: 32),

            _buildSectionTitle("About Box Breathing"),
            _buildDescriptionText(),
            const SizedBox(height: 24),

            _buildSectionTitle("Video Demonstration"),
            const SizedBox(height: 12),
            _buildVideoPlayer(),
            const SizedBox(height: 24),

            _buildSectionTitle("How To Practice"),
            const SizedBox(height: 12),
            ..._buildInstructionSteps(),
          ],
        ),
      ),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTechniqueButtons() {
    return Row(
      children: _techniques.entries.map((e) {
        final isSelected = _selectedTechnique == e.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? _brandColor : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () => setState(() => _selectedTechnique = e.key),
              child: Column(
                children: [
                  Text(e.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (e.key == '4:4:4:4') const SizedBox(height: 4),
                  if (e.key == '4:4:4:4')
                    Text('Recommended',
                        style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.green)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationControls() {
    final options = _isMinutesMode
        ? [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
        : [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleOption("Rounds", !_isMinutesMode),
            const SizedBox(width: 20),
            _buildToggleOption("Minutes", _isMinutesMode),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (_, i) {
              final val = options[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = val),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _selectedDuration == val ? _brandColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text("$val", style: TextStyle(fontSize: 20, color: _selectedDuration == val ? Colors.white : Colors.black87)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isMinutesMode = text == "Minutes"),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? _brandColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? _brandColor : Colors.grey.shade400),
        ),
        child: Text(text, style: TextStyle(color: isActive ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildDurationHint() {
    final seconds = _isMinutesMode ? _selectedDuration * 60 : _selectedDuration * _roundSeconds;
    final hint = _isMinutesMode
        ? "≈ ${(seconds / _roundSeconds).toStringAsFixed(0)} rounds"
        : "≈ ${(seconds / 60).toStringAsFixed(1)} minutes";
    return Text(hint, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]));
  }

  Widget _buildBeginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          final rounds = _isMinutesMode ? (_selectedDuration * 60) ~/ _roundSeconds : _selectedDuration;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BoxBreathingScreen(
                inhaleDuration: int.parse(_selectedTechnique.split(":")[0]),
                hold1Duration: int.parse(_selectedTechnique.split(":")[1]),
                exhaleDuration: int.parse(_selectedTechnique.split(":")[2]),
                hold2Duration: int.parse(_selectedTechnique.split(":")[3]),
                rounds: rounds,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("BEGIN EXERCISE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildDescriptionText() {
    return const Text(
      "Box Breathing is a powerful technique of inhaling, holding, exhaling, and holding again for equal counts. "
          "It calms the mind, reduces stress, and enhances focus.",
      style: TextStyle(fontSize: 15, height: 1.5),
    );
  }

  List<Widget> _buildInstructionSteps() {
    final steps = [
      "Inhale for the first count (e.g. 4 seconds).",
      "Hold your breath for the second count.",
      "Exhale for the third count.",
      "Hold again for the fourth count.",
      "Repeat this box cycle for your selected duration.",
    ];
    return List.generate(steps.length, (i) => _buildStepCard(i + 1, steps[i]));
  }

  Widget _buildStepCard(int num, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 14, backgroundColor: _brandColor, child: Text("$num", style: const TextStyle(color: Colors.white, fontSize: 12))),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(controller: _ytController, aspectRatio: 16 / 9, showVideoProgressIndicator: true),
    );
  }

  Widget _buildLearnMoreButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BoxBreathingLearnMorePage())),
          child: const Text("Learn More →", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
