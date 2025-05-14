import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Breathing technique configuration
  String _selectedTechnique = '4:4';
  final Map<String, String> _techniques = {
    '4:4': '4:4 Sheetkari Pranayama (Standard)',
    'custom': 'Customize Technique',
  };

  // Duration settings
  bool _isMinutesMode = false;
  int _selectedDuration = 5;

  // Custom breathing pattern
  int? _customInhale;
  int? _customExhale;

  // Video player
  final String _videoUrl = 'https://www.youtube.com/watch?v=YOUR_SHEETKARI_VIDEO_ID';
  late YoutubePlayerController _ytController;

  // Visualization options
  String _selectedImage = 'assets/images/option3.png';
  static const _imageOptions = [
    {'name': 'Mountain', 'path': 'assets/images/option3.png'},
    {'name': 'Wave', 'path': 'assets/images/option1.png'},
    {'name': 'Sunset', 'path': 'assets/images/option2.png'},
  ];

  // Audio options
  String _selectedSound = 'None';
  static const _soundOptions = [
    {'name': 'None', 'imagePath': 'assets/images/sound_none.png', 'audioPath': ''},
    {'name': 'Birds', 'imagePath': 'assets/images/sound_sitar.png', 'audioPath': '../assets/music/birds.mp3'},
    {'name': 'Rain', 'imagePath': 'assets/images/sound_mountain.png', 'audioPath': '../assets/music/rain.mp3'},
    {'name': 'Waves', 'imagePath': 'assets/images/sound_waves.png', 'audioPath': ''},
    {'name': 'AUM', 'imagePath': 'assets/images/sound_om.png', 'audioPath': ''},
    {'name': 'Flute', 'imagePath': 'assets/images/sound_gong.png', 'audioPath': '../assets/music/flute.mp3'},
  ];

  // Scroll controllers
  final ScrollController _soundController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_videoUrl)!,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    _precacheImages();
  }

  Future<void> _precacheImages() async {
    final futures = <Future>[];
    for (final img in _imageOptions) {
      futures.add(precacheImage(AssetImage(img['path']!), context));
    }
    for (final snd in _soundOptions) {
      futures.add(precacheImage(AssetImage(snd['imagePath']!), context));
    }
    await Future.wait(futures);
  }

  @override
  void dispose() {
    _ytController.dispose();
    _soundController.dispose();
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
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87
      ),
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

  Widget _buildVisualizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Visualization'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageOptions.length,
            itemBuilder: (_, i) => _buildVisualizationOption(_imageOptions[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualizationOption(Map<String, String> image) {
    final isSelected = _selectedImage == image['path'];
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => setState(() => _selectedImage = image['path']!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _brandColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(image['path']!, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: Text(
                      image['name']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ambient Sound'),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.builder(
            controller: _soundController,
            scrollDirection: Axis.horizontal,
            itemCount: _soundOptions.length,
            itemBuilder: (_, i) => _buildSoundOption(_soundOptions[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundOption(Map<String, String> sound) {
    final isSelected = _selectedSound == sound['name'];
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedSound = sound['name']!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _brandColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? _brandColor : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note_rounded,
                  size: 16,
                  color: isSelected ? Colors.white : _brandColor),
              const SizedBox(width: 6),
              Text(
                sound['name']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.blueGrey[800],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeginButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
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

    // Get the selected audio path
    final selected = _soundOptions.firstWhere(
          (s) => s['name'] == _selectedSound,
      orElse: () => {'audioPath': ''},
    );
    final audioPath = selected['audioPath']!;

    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => BilateralScreen(
          inhaleDuration: inhale,
          exhaleDuration: exhale,
          rounds: rounds,
          imagePath: _selectedImage,
          audioPath: audioPath,
          inhaleAudioPath: 'music/inhale_bell1.mp3',
          exhaleAudioPath: 'music/exhale_bell1.mp3',
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
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

            _buildSectionTitle('Visualization'),
            const SizedBox(height: 12),
            _buildVisualizationSection(),
            const SizedBox(height: 24),

            _buildSectionTitle('Ambient Sound'),
            const SizedBox(height: 12),
            _buildSoundSection(),
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