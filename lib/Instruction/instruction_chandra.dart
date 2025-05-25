import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditation_app/courses/chandra_bhedana_pranayama_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../Breathing_Pages/bilateral_screen.dart';
import '../Customization/customize.dart';

class ChandraBhedanaPranayamaPage extends StatefulWidget {
  @override
  _ChandraBhedanaPranayamaPageState createState() => _ChandraBhedanaPranayamaPageState();
}

class _ChandraBhedanaPranayamaPageState extends State<ChandraBhedanaPranayamaPage> {
  // Configuration state
  String _selectedTechnique = '4:4';
  String _selectedImage = 'assets/images/option3.png';
  String _selectedSound = 'None';
  int _selectedDuration = 5;
  bool _isMinutesMode = false;
  int? _customInhale = 4;
  int? _customExhale = 4;
  final ScrollController _soundController = ScrollController();

  // Constants
  static const Color _brandColor = Color(0xff1e88e5);

  // Technique options
  final Map<String, String> _techniques = {
    '4:4': '4:4 Chandra Bhedana (Standard)',
    'custom': 'Customize Technique',
  };



  // Visualization options
  static const _imageOptions = [
    {'name': '', 'path': 'assets/images/option3.png'},
    {'name': '', 'path': 'assets/images/option1.png'},
    {'name': '', 'path': 'assets/images/option2.png'},
  ];

  // Sound options
  static const _soundOptions = [
    {'name': 'None', 'imagePath': 'assets/images/sound_none.png', 'audioPath': ''},
    {'name': 'Birds', 'imagePath': 'assets/images/sound_sitar.png', 'audioPath': '../assets/music/birds.mp3'},
    {'name': 'Rain', 'imagePath': 'assets/images/sound_mountain.png', 'audioPath': '../assets/music/rain.mp3'},
    {'name': 'Waves', 'imagePath': 'assets/images/sound_waves.png', 'audioPath': '../assets/music/waves.mp3'},
    {'name': 'Flute', 'imagePath': 'assets/images/sound_gong.png', 'audioPath': '../assets/music/flute.mp3'},
  ];

  // Practice instruction steps
  static const _instructionSteps = [
    "Sit comfortably with your spine straight and shoulders relaxed.",
    "Close your right nostril gently with your finger, inhale slowly through the left.",
    "Close your left nostril, exhale gently through the right.",
    "Continue alternating, focusing on the cooling lunar energy.",
    "Maintain a smooth, steady rhythm for your selected duration.",
  ];

  @override
  void initState() {
    super.initState();

    _precacheImages();
  }

  Future<void> _precacheImages() async {
    final futures = <Future>[];
    for (final image in _imageOptions) {
      futures.add(precacheImage(AssetImage(image['path']!), context));
    }
    for (final sound in _soundOptions) {
      futures.add(precacheImage(AssetImage(sound['imagePath']!), context));
    }
    await Future.wait(futures);
  }

  @override
  void dispose() {

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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Text(
        'Chandra Bhedana Pranayama',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey[900],
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: IconThemeData(color: Colors.blueGrey[800]),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildTechniqueSection(),
          const SizedBox(height: 24),
          _buildDurationSection(),
          const SizedBox(height: 24),
          _buildVisualizationSection(),
          const SizedBox(height: 24),
          _buildSoundSection(),
          const SizedBox(height: 32),
          _buildBeginButton(),
          const SizedBox(height: 32),
          _buildAboutSection(),
          const SizedBox(height: 24),

          _buildPracticeGuide(),
          const SizedBox(height: 24),
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
          'Customize your Chandra Bhedana experience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTechniqueSection() {
    const techniques = [
      {'value': '4:4', 'label': 'Standard', 'inhale': 4, 'exhale': 4, 'recommended': true},
      {'value': 'custom', 'label': 'Custom', 'inhale': 0, 'exhale': 0, 'recommended': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('BREATHING PATTERN'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: techniques.map(_buildTechniqueOption).toList(),
        ),
        if (_selectedTechnique == 'custom') ...[
          const SizedBox(height: 16),
          _buildCustomPatternDisplay(),
        ],
      ],
    );
  }

  Widget _buildTechniqueOption(Map<String, dynamic> technique) {
    final bool isSelected = _selectedTechnique == technique['value'];
    final bool isRecommended = technique['recommended'] == true;

    return GestureDetector(
      onTap: () => _handleTechniqueSelection(technique),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE3EBF2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _brandColor
                : isRecommended
                ? Colors.amber[600]!
                : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              technique['label'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? _brandColor.withOpacity(0.8) : Colors.blueGrey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            if (technique['value'] != 'custom') ...[
              const SizedBox(height: 4),
              Text(
                '${technique['inhale']}:${technique['exhale']}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? _brandColor : Colors.blueGrey[600],
                ),
              ),
            ],
            if (isRecommended) ...[
              const SizedBox(height: 4),
              Text(
                'Recommended',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleTechniqueSelection(Map<String, dynamic> technique) async {
    if (technique['value'] == 'custom') {
      final result = await showCustomizationDialog(
        context,
        initialInhale: _customInhale ?? 4,
        initialExhale: _customExhale ?? 4,
        initialHold: 0,
      );
      if (result != null && mounted) {
        setState(() {
          _selectedTechnique = 'custom';
          _customInhale = result['inhale'];
          _customExhale = result['exhale'];
        });
      }
    } else if (mounted) {
      setState(() => _selectedTechnique = technique['value']);
    }
  }

  Widget _buildCustomPatternDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFE3EBF2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _brandColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBreathPhase('INHALE', '$_customInhale sec'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.compare_arrows_rounded,
                color: Colors.blueGrey, size: 24),
          ),
          _buildBreathPhase('EXHALE', '$_customExhale sec'),
        ],
      ),
    );
  }

  Widget _buildBreathPhase(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.blueGrey[600],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: _brandColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('SESSION DURATION'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleOption("Rounds", !_isMinutesMode),
            SizedBox(width: 20),
            _buildToggleOption("Minutes", _isMinutesMode),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _isMinutesMode
                ? [5,10,15,20,25,30,35,40,45,50,55,60].length
                : [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75].length,
            itemBuilder: (context, index) {
              final options = _isMinutesMode
                  ? [5,10,15,20,25,30,35,40,45,50,55,60]
                  : [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75];
              final duration = options[index];
              return _buildDurationOption(duration);
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
          border: Border.all(color: isActive ? _brandColor : Colors.grey[400]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationOption(int duration) {
    final isSelected = _selectedDuration == duration;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedDuration = duration),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE3EBF2) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _brandColor : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                duration.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected ? _brandColor : Colors.blueGrey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _isMinutesMode ? 'min' : 'rounds',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? _brandColor : Colors.blueGrey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationHint() {
    final totalSeconds = _isMinutesMode
        ? _selectedDuration * 60
        : _selectedDuration * _roundSeconds;
    final hint = _isMinutesMode
        ? "≈ ${(totalSeconds/_roundSeconds).toStringAsFixed(0)} rounds"
        : "≈ ${(totalSeconds/60).toStringAsFixed(1)} minutes";
    return Text(
        hint,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600])
    );
  }

  Widget _buildVisualizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('VISUALIZATION'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageOptions.length,
            itemBuilder: (context, index) {
              final image = _imageOptions[index];
              return _buildVisualizationOption(image);
            },
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
                  child: Image.asset(
                    image['path']!,
                    fit: BoxFit.cover,
                  ),
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
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      image['name']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
        _buildSectionTitle('AMBIENT SOUND'),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.builder(
            controller: _soundController,
            scrollDirection: Axis.horizontal,
            itemCount: _soundOptions.length,
            itemBuilder: (context, index) {
              final sound = _soundOptions[index];
              return _buildSoundOption(sound);
            },
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
              Icon(
                Icons.music_note_rounded,
                size: 16,
                color: isSelected ? Colors.white : _brandColor,
              ),
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

  Widget _buildBeginButton() {
    final inhale = _selectedTechnique == '4:4' ? 4 : (_customInhale ?? 4);
    final exhale = _selectedTechnique == '4:4' ? 4 : (_customExhale ?? 4);
    final rounds = _isMinutesMode
        ? (_selectedDuration * 60) ~/ (inhale + exhale)
        : _selectedDuration;

    // Get selected audio path
    final selected = _soundOptions.firstWhere(
          (s) => s['name'] == _selectedSound,
      orElse: () => {'audioPath': ''},
    );
    final audioPath = selected['audioPath']!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  BilateralScreen(
                    inhaleDuration: inhale,
                    exhaleDuration: exhale,
                    rounds: rounds,
                    imagePath: _selectedImage,
                    audioPath: audioPath,
                    inhaleAudioPath: 'music/inhale-bell1_.mp3',
                    exhaleAudioPath: 'music/exhale_bell.mp3',
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'BEGIN SESSION',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ABOUT CHANDRA BHEDANA'),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            "Chandra Bhedana Pranayama involves inhaling through the left nostril "
                "and exhaling through the right. It is said to calm the mind, cool the body, "
                "and balance lunar energy.",
            style: TextStyle(fontSize: 15, height: 1.5, color: Colors.blueGrey[800]),
          ),
        ),
      ],
    );
  }



  Widget _buildPracticeGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('HOW TO PRACTICE'),
        const SizedBox(height: 12),
        ..._buildInstructionSteps(),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChandraBhedanaPranayamaLearnMorePage()),
              );
            },
            child: Text(
              "Learn More →",
              style: TextStyle(
                  color: _brandColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInstructionSteps() {
    return List.generate(
        _instructionSteps.length,
            (i) => _buildStepCard(i + 1, _instructionSteps[i])
    );
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
            CircleAvatar(
                radius: 14,
                backgroundColor: _brandColor,
                child: Text(
                    "$num",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    )
                )
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    text,
                    style: const TextStyle(height: 1.4)
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Colors.blueGrey[600],
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}