import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditation_app/courses/nadi_shodhana_pranayama_page.dart';
import 'package:meditation_app/Breathing_Pages/bilateral_screen.dart';
import 'package:meditation_app/Customization/customize.dart';

class NadiShodhanaPage extends StatefulWidget {
  @override
  _NadiShodhanaPageState createState() => _NadiShodhanaPageState();
}

class _NadiShodhanaPageState extends State<NadiShodhanaPage> {
  // Configuration state
  String _selectedTechnique = '4:6';
  String _selectedImage = 'assets/images/muladhara_chakra3.png';
  int _selectedDuration = 5;
  String _selectedSound = 'None';
  bool _isMinutesMode = false;

  // Custom breathing pattern values
  int _customInhale = 4;
  int _customExhale = 6;

  // Scroll controller for sound options
  final ScrollController _soundController = ScrollController();

  // Constants
  final Map<String, String> _techniques = {
    '4:6': '4:6 Breathing (Recommended)',
    '2:3': '2:3 Breathing',
  };

  final List<Map<String, String>> _imageOptions = [
    {'name': 'Option 1', 'path': 'assets/images/muladhara_chakra3.png'},
    {'name': 'Option 2', 'path': 'assets/images/option1.png'},
    {'name': 'Option 3', 'path': 'assets/images/option2.png'},
  ];

  // Sound options added from second file
  final List<Map<String, String>> _soundOptions = [
    {'name': 'None', 'imagePath': 'assets/images/sound_none.png', 'audioPath': ''},
    {'name': 'Birds', 'imagePath': 'assets/images/sound_sitar.png', 'audioPath': '../assets/music/birds.mp3'},
    {'name': 'Rain', 'imagePath': 'assets/images/sound_mountain.png', 'audioPath': '../assets/music/rain.mp3'},
    {'name': 'Waves', 'imagePath': 'assets/images/sound_waves.png', 'audioPath': '../assets/music/waves.mp3'},
    {'name': 'AUM', 'imagePath': 'assets/images/sound_om.png', 'audioPath': '../assets/music/aum.mp3'},
    {'name': 'Flute', 'imagePath': 'assets/images/sound_gong.png', 'audioPath': '../assets/music/flute.mp3'},
  ];

  @override
  void initState() {
    super.initState();
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
    _soundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nadi Shodhana Pranayama"),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            SizedBox(height: 24),
            _buildSectionTitle("Breathing Technique"),
            SizedBox(height: 8),
            _buildTechniqueButtons(),
            SizedBox(height: 24),
            _buildSectionTitle("Duration"),
            _buildDurationControls(),
            SizedBox(height: 24),
            _buildSectionTitle("Visualization Image"),
            SizedBox(height: 8),
            _buildImageSelector(),
            SizedBox(height: 24),
            _buildSectionTitle("Ambient Sound"),
            SizedBox(height: 8),
            _buildSoundSection(),
            SizedBox(height: 24),
            _buildCustomizeButton(),
            SizedBox(height: 16),
            _buildBeginButton(),
            SizedBox(height: 24),
            _buildPracticeGuide(),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }

  // Header widget
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prepare Your Nadi Shodhana Session',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey[900],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Customize your alternate nostril breathing experience',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey[600],
        letterSpacing: 0.8,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NadiShodhanaPranayamaPage(),
              ),
            );
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
              color: isSelected ? Color(0xff98bad5) : Colors.transparent,
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

  // Sound section
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
            color: isSelected ? Color(0xff98bad5) : Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? Color(0xff98bad5) : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note_rounded,
                  size: 16,
                  color: isSelected ? Colors.white : Color(0xff98bad5)),
              const SizedBox(width: 6),
              Text(
                sound['name']!,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.blueGrey[800],
                ),
              ),
            ],
          ),
        ),
      ),
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
        final result = await showCustomizationDialog(
          context,
          initialInhale: _selectedTechnique == '4:6' ? 4 : 2,
          initialExhale: _selectedTechnique == '4:6' ? 6 : 3,
          initialHold: 0,
        );

        if (result != null) {
          setState(() {
            _customInhale = result['inhale']!;
            _customExhale = result['exhale']!;
            _selectedTechnique = 'custom';
          });
        }
      },
    );
  }

  // Begin exercise button
  Widget _buildBeginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();

          // Get breathing pattern values
          final (inhale, exhale) = _parseBreathingPattern();
          final rounds = _calculateRounds(inhale, exhale);

          // Get selected audio path
          final selected = _soundOptions.firstWhere(
                (s) => s['name'] == _selectedSound,
            orElse: () => {'audioPath': ''},
          );
          final audioPath = selected['audioPath']!;

          // Navigate to breathing exercise screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BilateralScreen(
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

  // Practice guide/instructions
  Widget _buildPracticeGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How To Practice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff98bad5),
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionSteps(),
        ],
      ),
    );
  }

  // Instruction steps
  Widget _buildInstructionSteps() {
    return Column(
      children: [
        _buildStepCard(1, "Sit comfortably with spine straight and shoulders relaxed."),
        _buildStepCard(2, "Close your right nostril with your thumb; inhale slowly through the left."),
        _buildStepCard(3, "Close left nostril with ring finger, release thumb, exhale via right."),
        _buildStepCard(4, "Inhale through right, close it, then exhale through left."),
        _buildStepCard(5, "Continue alternating for your selected duration."),
      ],
    );
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

  // Helper method to parse breathing pattern
  (int inhale, int exhale) _parseBreathingPattern() {
    if (_selectedTechnique == 'custom') {
      return (_customInhale, _customExhale);
    }
    final parts = _selectedTechnique.split(':');
    final inh = int.tryParse(parts[0]) ?? 4;
    final exh = parts.length > 1 ? int.tryParse(parts[1]) ?? 6 : 6;
    return (inh, exh);
  }

  // Helper method to calculate rounds
  int _calculateRounds(int inhale, int exhale) {
    if (!_isMinutesMode) {
      return _selectedDuration;
    }
    final rounds = (_selectedDuration * 60) ~/ (inhale + exhale);
    return rounds < 1 ? 1 : rounds;
  }
}