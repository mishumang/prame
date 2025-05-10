import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditation_app/Breathing_Pages/bilateral_screen.dart';
import 'package:meditation_app/Customization/customize.dart';

class AbdominalBreathingPage extends StatefulWidget {
  const AbdominalBreathingPage({super.key});

  @override
  State<AbdominalBreathingPage> createState() => _AbdominalBreathingPageState();
}

class _AbdominalBreathingPageState extends State<AbdominalBreathingPage> {
  // Configuration state
  String _selectedTechnique = '4:6';
  String _selectedImage = 'assets/images/option3.png';
  int _selectedDuration = 5;
  String _selectedSound = 'None';
  int _customInhale = 4;
  int _customExhale = 6;
  final ScrollController _soundController = ScrollController();

  // Constants
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

  static const _techniques = [
    {'value': '4:6', 'label': 'Recommended', 'inhale': 4, 'exhale': 6},
    {'value': '4:8', 'label': 'Extended', 'inhale': 4, 'exhale': 8},
    {'value': '5:5', 'label': 'Balanced', 'inhale': 5, 'exhale': 5},
    {'value': 'custom', 'label': 'Custom', 'inhale': 0, 'exhale': 0},
  ];

  static const _durationOptions = [1, 3, 5, 10, 15, 20, 30, 45, 60];

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
        'Abdominal Breathing',
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
          'Customize your abdominal breathing experience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTechniqueSection() {
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
          children: _techniques.map(_buildTechniqueOption).toList(),
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
    final bool isRecommended = technique['value'] == '4:6';

    return GestureDetector(
      onTap: () => _handleTechniqueSelection(technique),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue[600]!
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
            if (isRecommended) ...[
              const SizedBox(height: 4),
            ],
            Text(
              technique['label'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.blue[800] : Colors.blueGrey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            if (technique['value'] != 'custom') ...[
              const SizedBox(height: 4),
              Text(
                '${technique['inhale']}:${technique['exhale']}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.blue[600] : Colors.blueGrey[600],
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
        initialInhale: _customInhale,
        initialExhale: _customExhale,
        initialHold: _customExhale,
      );
      if (result != null && mounted) {
        setState(() {
          _selectedTechnique = 'custom';
          _customInhale = result['inhale'] ?? 4;
          _customExhale = result['exhale'] ?? 6;
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
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue[200]!,
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
            color: Colors.blue[800],
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
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _durationOptions.length,
            itemBuilder: (context, index) {
              final duration = _durationOptions[index];
              return _buildDurationOption(duration);
            },
          ),
        ),
      ],
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
            color: isSelected ? Colors.blue[50] : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                duration.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected ? Colors.blue[800] : Colors.blueGrey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'min',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? Colors.blue[600] : Colors.blueGrey[500],
                ),
              ),
            ],
          ),
        ),
      ),
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
              color: isSelected ? Colors.blue[600]! : Colors.transparent,
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
            color: isSelected ? Colors.blue[600] : Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 16,
                color: isSelected ? Colors.white : Colors.blue[600],
              ),
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

  Widget _buildBeginButton() {
    final (inhale, exhale) = _parseBreathingPattern();
    final rounds = _calculateRounds(inhale, exhale);
    final selectedSoundOption = _soundOptions.firstWhere(
          (sound) => sound['name'] == _selectedSound,
      orElse: () => {'name': 'None', 'imagePath': '', 'audioPath': ''},
    );
    final audioPath = selectedSoundOption['audioPath']!;

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
          backgroundColor: Colors.blue[600],
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

  Widget _buildPracticeGuide() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Instructions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(1, 'Find a quiet space and sit comfortably', theme),
          _buildInstructionStep(2, 'Place hands on chest and abdomen', theme),
          _buildInstructionStep(3, 'Inhale deeply through nose (4 seconds)', theme),
          _buildInstructionStep(4, 'Exhale slowly through mouth (6 seconds)', theme),
          _buildInstructionStep(5, 'Focus on abdominal movement', theme),
          _buildInstructionStep(6, 'Maintain relaxed, steady rhythm', theme),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.9),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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

  (int inhale, int exhale) _parseBreathingPattern() {
    if (_selectedTechnique == 'custom') {
      return (_customInhale, _customExhale);
    }

    final parts = _selectedTechnique.split(':');
    final inhale = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 4 : 4;
    final exhale = parts.length > 1 ? int.tryParse(parts[1]) ?? 6 : 6;
    return (inhale, exhale);
  }

  int _calculateRounds(int inhale, int exhale) {
    final rounds = (_selectedDuration * 60) ~/ (inhale + exhale);
    return rounds < 1 ? 1 : rounds;
  }
}