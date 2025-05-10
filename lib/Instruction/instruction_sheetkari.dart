import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:meditation_app/Breathing_Pages/bilateral_screen.dart';
import 'package:meditation_app/Customization/customize.dart';

class SheetkariPranayamaLearnMorePage extends StatelessWidget {
  const SheetkariPranayamaLearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn More: Sheetkari Pranayama")),
      body: const Center(
        child: Text(
          "Detailed information about Sheetkari Pranayama goes here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SheetkariPranayamaPage extends StatefulWidget {
  @override
  _SheetkariPranayamaPageState createState() => _SheetkariPranayamaPageState();
}

class _SheetkariPranayamaPageState extends State<SheetkariPranayamaPage> {
  static const Color _brandColor = Color(0xff98bad5);

  String _selectedTechnique = '4:4';
  final Map<String, String> _techniques = {
    '4:4': '4:4 Sheetkari Pranayama (Standard)',
    'custom': 'Customize Technique',
  };

  final String _videoUrl = 'https://www.youtube.com/watch?v=YOUR_SHEETKARI_VIDEO_ID';
  late YoutubePlayerController _ytController;

  bool _isMinutesMode = false;
  int _selectedDuration = 5;

  int? _customInhale;
  int? _customExhale;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_videoUrl)!,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  int get _roundSeconds {
    if (_selectedTechnique == 'custom' && _customInhale != null && _customExhale != null) {
      return _customInhale! + _customExhale!;
    }
    return 4 + 4; // default 4:4
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTechniqueButtons() {
    return Row(
      children: _techniques.entries.map((entry) {
        final isSelected = _selectedTechnique == entry.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? _brandColor : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () {
                setState(() {
                  _selectedTechnique = entry.key;
                  _selectedDuration = 5;
                });
                if (entry.key == 'custom') _showCustomDialog();
              },
              child: Text(entry.value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggleOption(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() {
        _isMinutesMode = label == 'Minutes';
        _selectedDuration = 5;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? _brandColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _brandColor : Colors.grey.shade400),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildDurationControls() {
    final options = [5, 10, 15, 20, 25, 30];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleOption('Rounds', !_isMinutesMode),
            const SizedBox(width: 20),
            _buildToggleOption('Minutes', _isMinutesMode),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (_, i) {
              final val = options[i];
              final selected = _selectedDuration == val;
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = val),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected ? _brandColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text("$val", style: TextStyle(fontSize: 20, color: selected ? Colors.white : Colors.black87)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationHint() {
    final seconds = _isMinutesMode ? _selectedDuration * 60 : _selectedDuration * _roundSeconds;
    final hint = _isMinutesMode
        ? "≈ ${(seconds / _roundSeconds).toStringAsFixed(0)} rounds"
        : "≈ ${(seconds / 60).toStringAsFixed(1)} minutes";
    return Text(hint, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]));
  }

  Future<void> _showCustomDialog() async {
    final result = await showCustomizationDialog(
      context,
      initialInhale: _customInhale ?? 4,
      initialExhale: _customExhale ?? 4,
      initialHold: 0,
    );
    if (result != null) {
      setState(() {
        _customInhale = result['inhale'];
        _customExhale = result['exhale'];
      });
    }
  }

  Widget _buildCustomizeButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.settings, size: 20, color: Colors.black),
      label: const Text("Customize Breathing Pattern"),
      onPressed: _showCustomDialog,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _brandColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildBeginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _navigateToTechnique,
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("BEGIN EXERCISE",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _navigateToTechnique() {
    final rounds = _isMinutesMode ? (_selectedDuration * 60) ~/ _roundSeconds : _selectedDuration;
    int inhale, exhale;
    if (_selectedTechnique == 'custom') {
      if (_customInhale == null || _customExhale == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please set custom values')));
        return;
      }
      inhale = _customInhale!;
      exhale = _customExhale!;
    } else {
      inhale = 4;
      exhale = 4;
    }
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => BilateralScreen(inhaleDuration: inhale, exhaleDuration: exhale, rounds: rounds),
    //   ),
    // );
  }

  Widget _buildDescriptionText() {
    return const Text(
      "Sheetkari Pranayama is a cooling breath where you part your lips slightly and inhale through your teeth, producing a hissing sound, then exhale through your nose.",
      style: TextStyle(fontSize: 15, height: 1.5),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _ytController,
        aspectRatio: 16 / 9,
        showVideoProgressIndicator: true,
      ),
    );
  }

  List<Widget> _buildInstructionSteps() {
    final steps = [
      "Sit comfortably with your spine straight and shoulders relaxed.",
      "Part your lips slightly and press your tongue gently against your palate.",
      "Inhale through your teeth, creating a soft hissing sound.",
      "Close your mouth and exhale slowly through your nose.",
      "Repeat for your selected duration, focusing on the cooling sensation.",
    ];
    return List.generate(steps.length, (i) => _buildStepCard(i + 1, steps[i]));
  }

  Widget _buildStepCard(int num, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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

  Widget _buildLearnMoreButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SheetkariPranayamaLearnMorePage())),
          child: const Text("Learn More →", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // <— Only one build method, no recursion!
    return Scaffold(
      appBar: AppBar(title: const Text('Sheetkari Pranayama'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Breathing Technique'),
            const SizedBox(height: 8),
            _buildTechniqueButtons(),
            const SizedBox(height: 24),

            _buildSectionTitle('Duration'),
            const SizedBox(height: 8),
            _buildDurationControls(),
            const SizedBox(height: 8),
            _buildDurationHint(),
            const SizedBox(height: 24),

            _buildCustomizeButton(),
            const SizedBox(height: 16),
            _buildBeginButton(),
            const SizedBox(height: 32),

            _buildSectionTitle('About Sheetkari Pranayama'),
            const SizedBox(height: 8),
            _buildDescriptionText(),
            const SizedBox(height: 24),

            _buildSectionTitle('Video Demonstration'),
            const SizedBox(height: 12),
            _buildVideoPlayer(),
            const SizedBox(height: 24),

            _buildSectionTitle('How To Practice'),
            const SizedBox(height: 12),
            ..._buildInstructionSteps(),
          ],
        ),
      ),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }
}
