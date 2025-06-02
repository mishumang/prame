import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:meditation_app/Customization/customize.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:meditation_app/Breathing_Pages/kapalbreathing.dart';


class KapalbhatiPranayamaPage extends StatefulWidget {
  const KapalbhatiPranayamaPage({super.key});

  @override
  State<KapalbhatiPranayamaPage> createState() => _KapalbhatiPranayamaPageState();
}

class _KapalbhatiPranayamaPageState extends State<KapalbhatiPranayamaPage> {
  // Configuration state
  int _selectedExhaleSpeed = 2; // Default to beginner (2 seconds)
  String _selectedImage = 'assets/images/option3.png';
  int _selectedDuration = 5;
  String _selectedSound = 'None';
  final ScrollController _soundController = ScrollController();

  // Constants
  static const _imageOptions = [
    {'name': '', 'path': 'assets/images/option3.png'},
    {'name': '', 'path': 'assets/images/option1.png'},
    {'name': '', 'path': 'assets/images/option2.png'},
  ];

  static const _soundOptions = [
    {'name': 'None', 'imagePath': 'assets/images/sound_none.png', 'audioPath': ''},
    {'name': 'Birds', 'imagePath': 'assets/images/sound_sitar.png', 'audioPath': 'music/birds.mp3'},
    {'name': 'Rain', 'imagePath': 'assets/images/sound_mountain.png', 'audioPath': 'music/rain.mp3'},
    {'name': 'Waves', 'imagePath': 'assets/images/sound_waves.png', 'audioPath': 'music/waves.mp3'},
    {'name': 'Flute', 'imagePath': 'assets/images/sound_gong.png', 'audioPath': 'music/flute.mp3'},
  ];

  static const _exhaleSpeedOptions = [
    {'value': 2, 'label': 'Beginner', 'description': 'Slower pace'},
    {'value': 1, 'label': 'Advanced', 'description': 'Faster pace'},
  ];

  static const _durationOptions = [1, 3, 5, 10, 15, 20, 30, 45, 60];

  // Practice instruction steps
  static const _instructionSteps = [
    "Sit comfortably with your spine straight and shoulders relaxed.",
    "Place your hands on your knees with palms facing upward.",
    "Take a deep breath in and then forcefully exhale through your nose.",
    "Allow your abdomen to contract quickly during the forceful exhalation.",
    "Let inhalation happen passively and naturally without effort.",
    "Maintain a steady rhythm, focusing on the sharp, forceful exhalations.",
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
        'Kapalbhati Pranayama',
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
          _buildExhaleSpeedSection(),
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
          'Customize your Kapalbhati pranayama experience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildExhaleSpeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('EXHALE SPEED'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: _exhaleSpeedOptions.map(_buildExhaleSpeedOption).toList(),
        ),
      ],
    );
  }

  Widget _buildExhaleSpeedOption(Map<String, dynamic> option) {
    final bool isSelected = _selectedExhaleSpeed == option['value'];
    final bool isBeginner = option['value'] == 2;

    return GestureDetector(
      onTap: () => setState(() => _selectedExhaleSpeed = option['value']),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue[600]!
                : isBeginner
                ? Colors.green[600]!
                : Colors.orange[600]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              option['label'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.blue[800] : Colors.blueGrey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              option['description'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.blue[600] : Colors.blueGrey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${option['value']} sec exhale',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.blue[600] : Colors.blueGrey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
    final selectedSoundOption = _soundOptions.firstWhere(
          (sound) => sound['name'] == _selectedSound,
      orElse: () => {'name': 'None', 'imagePath': '', 'audioPath': ''},
    );
    final audioPath = selectedSoundOption['audioPath']!;
    final rounds = _calculateRounds();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  KapalBreathingScreen(
                    inhaleDuration: 4, // Fixed 4 seconds for deep inhale
                    exhaleInterval: _selectedExhaleSpeed, // Pass correct parameter name
                    rounds: rounds,
                    imagePath: _selectedImage,
                    audioPath: audioPath,
                    inhaleAudioPath: '', // Remove separate inhale audio
                    exhaleAudioPath: '', // Remove separate exhale audio
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

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ABOUT KAPALBHATI PRANAYAMA'),
        const SizedBox(height: 12),
        Text(
          "Kapalbhati Pranayama, known as the 'skull shining breath', is an energizing technique that involves forceful, rapid exhalations through the nose with passive inhalations. It stimulates the abdominal organs, enhances digestive fire, clears the respiratory passages, and revitalizes the mind and body.",
          style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.blueGrey[700]
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
                backgroundColor: Colors.blue[600],
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

  int _calculateRounds() {
    // For Kapalbhati: Each round = 4 second inhale + 10 rapid exhales (at selected interval)
    // Total cycle time = 4 seconds + (10 * exhale_interval) + 2 seconds rest
    final cycleTime = 4 + (10 * _selectedExhaleSpeed) + 2;
    final rounds = (_selectedDuration * 60) ~/ cycleTime;
    return rounds < 1 ? 1 : rounds;
  }
}