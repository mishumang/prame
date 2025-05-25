import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class BoxBreathingPage extends StatefulWidget {
  const BoxBreathingPage({Key? key}) : super(key: key);
  @override
  _BoxBreathingPageState createState() => _BoxBreathingPageState();
}

class _BoxBreathingPageState extends State<BoxBreathingPage> {
  // Configuration state
  String _selectedTechnique = '4:4:4:4';
  String _selectedMantra = 'Hanuman Chalisa'; // Default mantra selection
  int _customInhale = 4;
  int _customHold1 = 4;
  int _customExhale = 4;
  int _customHold2 = 4;
  final ScrollController _soundController = ScrollController();

  // Constants
  static const _techniques = [
    {'value': '4:4:4:4', 'label': 'Recommended', 'inhale': 4, 'hold1': 4, 'exhale': 4, 'hold2': 4},
    {'value': '4:4:6:4', 'label': 'Extended', 'inhale': 4, 'hold1': 4, 'exhale': 6, 'hold2': 4},
    {'value': '5:5:5:5', 'label': 'Balanced', 'inhale': 5, 'hold1': 5, 'exhale': 5, 'hold2': 5},
    {'value': 'custom', 'label': 'Custom', 'inhale': 0, 'hold1': 0, 'exhale': 0, 'hold2': 0},
  ];

  static const _mantraOptions = [
    {'value': 'Hanuman Chalisa', 'label': 'Hanuman Chalisa'},
    {'value': 'Aditya Hrudayam', 'label': 'Aditya Hrudayam'},
    {'value': 'None', 'label': 'No Mantra'}, // Added No Mantra option
  ];


  static const _instructionSteps = [
    "Inhale for the first count (e.g. 4 seconds).",
    "Hold your breath for the second count.",
    "Exhale for the third count.",
    "Hold again for the fourth count.",
    "Repeat this box cycle for your selected duration.",
  ];

  @override
  void initState() {
    super.initState();

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
        'Box Breathing',
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
          _buildMantraSection(),
          const SizedBox(height: 24),
          _buildTechniqueSection(),
          const SizedBox(height: 24),
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
          'Customize your box breathing experience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMantraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('SELECT MANTRA'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: _mantraOptions.map(_buildMantraOption).toList(),
        ),
      ],
    );
  }

  Widget _buildMantraOption(Map<String, dynamic> mantra) {
    final bool isSelected = _selectedMantra == mantra['value'];
    final bool isRecommended = mantra['value'] == 'Hanuman Chalisa';

    return GestureDetector(
      onTap: () => setState(() => _selectedMantra = mantra['value']),
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
            Text(
              mantra['label'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.blue[800] : Colors.blueGrey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
    final bool isRecommended = technique['value'] == '4:4:4:4';

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
                '${technique['inhale']}:${technique['hold1']}:${technique['exhale']}:${technique['hold2']}',
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
      setState(() {
        _selectedTechnique = 'custom';
        _customInhale = 4;
        _customHold1 = 4;
        _customExhale = 4;
        _customHold2 = 4;
      });
    } else {
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
          const SizedBox(width: 4),
          _buildBreathPhase('HOLD', '$_customHold1 sec'),
          const SizedBox(width: 4),
          _buildBreathPhase('EXHALE', '$_customExhale sec'),
          const SizedBox(width: 4),
          _buildBreathPhase('HOLD', '$_customHold2 sec'),
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
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }



  Widget _buildBeginButton() {
    final (inhale, hold1, exhale, hold2) = _parseBreathingPattern();
    // Default rounds to a reasonable number since duration is removed
    final rounds = 10;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  BoxBreathingScreen(
                    inhaleDuration: inhale,
                    hold1Duration: hold1,
                    exhaleDuration: exhale,
                    hold2Duration: hold2,
                    rounds: rounds,
                    mantra: _selectedMantra,
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
        _buildSectionTitle('ABOUT BOX BREATHING'),
        const SizedBox(height: 12),
        Text(
          "Box Breathing is a powerful technique of inhaling, holding, exhaling, and holding again for equal counts. "
              "It calms the mind, reduces stress, and enhances focus.",
          style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.blueGrey[700]),
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
            (i) => _buildStepCard(i + 1, _instructionSteps[i]));
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
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
                child: Text(text, style: const TextStyle(height: 1.4))),
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

  (int inhale, int hold1, int exhale, int hold2) _parseBreathingPattern() {
    if (_selectedTechnique == 'custom') {
      return (_customInhale, _customHold1, _customExhale, _customHold2);
    }

    final parts = _selectedTechnique.split(':');
    final inhale = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 4 : 4;
    final hold1 = parts.length > 1 ? int.tryParse(parts[1]) ?? 4 : 4;
    final exhale = parts.length > 2 ? int.tryParse(parts[2]) ?? 4 : 4;
    final hold2 = parts.length > 3 ? int.tryParse(parts[3]) ?? 4 : 4;
    return (inhale, hold1, exhale, hold2);
  }
}