import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditation_app/courses/sheetali_pranayama_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../Breathing_Pages/bilateral_screen.dart';
import '../Customization/customize.dart';

class SheetaliPranayamaPage extends StatefulWidget {
  @override
  _SheetaliPranayamaPageState createState() => _SheetaliPranayamaPageState();
}

class _SheetaliPranayamaPageState extends State<SheetaliPranayamaPage> {
  static const Color _brandColor = Color(0xff98bad5);

  // Configuration state
  String _selectedTechnique = '4:4';
  String _selectedImage = 'assets/images/option3.png';
  int _selectedDuration = 5;
  String _selectedSound = 'None';
  bool _isMinutesMode = false;
  int? _customInhale;
  int? _customExhale;
  final ScrollController _soundController = ScrollController();

  // Video Player
  final String _videoUrl = "https://www.youtube.com/watch?v=YOUR_SHEETALI_VIDEO_ID";
  late YoutubePlayerController _ytController;

  // Constants
  final Map<String, String> _techniques = {
    '4:4': '4:4 Sheetali Pranayama (Recommended)',
    'custom': 'Customize Technique',
  };

  static const _imageOptions = [
    {'name': 'Mountain', 'path': 'assets/images/option3.png'},
    {'name': 'Wave', 'path': 'assets/images/option1.png'},
    {'name': 'Sunset', 'path': 'assets/images/option2.png'},
  ];

  static const _soundOptions = [
    {'name': 'None', 'imagePath': 'assets/images/sound_none.png', 'audioPath': ''},
    {'name': 'Birds', 'imagePath': 'assets/images/sound_sitar.png', 'audioPath': '../assets/music/birds.mp3'},
    {'name': 'Rain', 'imagePath': 'assets/images/sound_mountain.png', 'audioPath': '../assets/music/rain.mp3'},
    {'name': 'Waves', 'imagePath': 'assets/images/sound_waves.png', 'audioPath': ''},
    {'name': 'AUM', 'imagePath': 'assets/images/sound_om.png', 'audioPath': ''},
    {'name': 'Flute', 'imagePath': 'assets/images/sound_gong.png', 'audioPath': '../assets/music/flute.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_videoUrl)!,
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
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
    // default 4:4
    return 4 + 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContent(),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Text(
        "Sheetali Pranayama",
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: _brandColor,
      toolbarHeight: 60,
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),

          _buildSectionTitle("Breathing Technique"),
          SizedBox(height: 8),
          _buildTechniqueButtons(),
          SizedBox(height: 24),

          _buildSectionTitle("Duration"),
          SizedBox(height: 8),
          _buildDurationControls(),
          SizedBox(height: 24),

          _buildSectionTitle("Visualization"),
          SizedBox(height: 12),
          _buildVisualizationSection(),
          SizedBox(height: 24),

          _buildSectionTitle("Ambient Sound"),
          SizedBox(height: 12),
          _buildSoundSection(),
          SizedBox(height: 24),

          _buildCustomizeButton(),
          SizedBox(height: 16),

          _buildBeginButton(),
          SizedBox(height: 32),

          _buildSectionTitle("About Sheetali Pranayama"),
          _buildDescriptionText(),
          SizedBox(height: 24),

          _buildSectionTitle("Video Demonstration"),
          SizedBox(height: 12),
          _buildVideoPlayer(),
          SizedBox(height: 24),

          _buildSectionTitle("How To Practice"),
          SizedBox(height: 12),
          ..._buildInstructionSteps(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prepare Your Session',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customize your Sheetali Pranayama experience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Colors.blueGrey[600],
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTechniqueButtons() {
    return Row(
      children: _techniques.entries.map((entry) {
        final isSelected = _selectedTechnique == entry.key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? _brandColor : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () {
                setState(() => _selectedTechnique = entry.key);
                if (entry.key == 'custom') _showCustomDialog();
              },
              child: Column(
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (entry.key == '4:4') SizedBox(height: 4),
                  if (entry.key == '4:4')
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
            itemBuilder: (_, i) {
              final val = options[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = val),
                child: Container(
                  width: 80,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _selectedDuration == val ? _brandColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "$val",
                      style: TextStyle(
                        fontSize: 20,
                        color: _selectedDuration == val ? Colors.white : Colors.black87,
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

  Widget _buildToggleOption(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isMinutesMode = text == "Minutes"),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? _brandColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            bottom: BorderSide(
              color: isActive ? _brandColor : Colors.grey.shade400,
              width: 2.0,
            ),
          ),
        ),
        child: Text(text, style: TextStyle(color: isActive ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildDurationHint() {
    final totalSeconds = _isMinutesMode
        ? _selectedDuration * 60
        : _selectedDuration * _roundSeconds;
    final hint = _isMinutesMode
        ? "≈ ${(totalSeconds / _roundSeconds).toStringAsFixed(0)} rounds"
        : "≈ ${(totalSeconds / 60).toStringAsFixed(1)} minutes";
    return Text(hint, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]));
  }

  Widget _buildVisualizationSection() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageOptions.length,
        itemBuilder: (_, i) => _buildVisualizationOption(_imageOptions[i]),
      ),
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
    return SizedBox(
      height: 48,
      child: ListView.builder(
        controller: _soundController,
        scrollDirection: Axis.horizontal,
        itemCount: _soundOptions.length,
        itemBuilder: (_, i) => _buildSoundOption(_soundOptions[i]),
      ),
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
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : Colors.blueGrey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizeButton() {
    return OutlinedButton.icon(
      icon: Icon(Icons.settings, size: 20, color: Colors.black),
      label: Text("Customize Breathing Pattern"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: _brandColor),
      ),
      onPressed: _showCustomDialog,
    );
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
        _selectedTechnique = 'custom';
      });
    }
  }

  Widget _buildBeginButton() {
    final inhale = _selectedTechnique == 'custom' ? _customInhale ?? 4 : 4;
    final exhale = _selectedTechnique == 'custom' ? _customExhale ?? 4 : 4;
    final rounds = _isMinutesMode
        ? (_selectedDuration * 60) ~/ (inhale + exhale)
        : _selectedDuration;

    final selected = _soundOptions.firstWhere(
          (s) => s['name'] == _selectedSound,
      orElse: () => {'audioPath': ''},
    );
    final audioPath = selected['audioPath']!;

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BilateralScreen(
                inhaleDuration: inhale,
                exhaleDuration: exhale,
                rounds: rounds,
                imagePath: _selectedImage,
                audioPath: audioPath,
                inhaleAudioPath: 'music/inhale_bell1.mp3',
                exhaleAudioPath: 'music/exhale_bell1.mp3',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
        child: Text(
          "BEGIN EXERCISE",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Text(
      "Sheetali Pranayama is a cooling breath where you roll or curl your tongue into a tube (if possible), "
          "inhale through the mouth, then exhale through the nose. It soothes the mind and cools the body.",
      style: TextStyle(fontSize: 15, height: 1.5),
    );
  }

  List<Widget> _buildInstructionSteps() {
    final steps = [
      "Sit comfortably with spine straight and shoulders relaxed.",
      "Roll your tongue into a tube (if possible).",
      "Inhale slowly through the tongue tube, feeling cool air.",
      "Close your mouth and exhale gently through the nose.",
      "Repeat for your selected duration, focusing on the cooling effect.",
    ];
    return List.generate(steps.length, (i) => _buildStepCard(i + 1, steps[i]));
  }

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
          children: [
            CircleAvatar(radius: 14, backgroundColor: _brandColor, child: Text("$num", style: TextStyle(color: Colors.white, fontSize: 12))),
            SizedBox(width: 12),
            Expanded(child: Text(text, style: TextStyle(height: 1.4))),
          ],
        ),
      ),
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

  Widget _buildLearnMoreButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SheetaliPranayamaLearnMorePage()),
            );
          },
          child: Text(
            "Learn More →",
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}