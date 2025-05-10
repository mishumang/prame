import 'package:flutter/material.dart';
import 'package:meditation_app/courses/nadi_shodhana_pranayama_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../Breathing_Pages/bilateral_screen.dart';
import '../Customization/customize.dart';

class NadiShodhanaPage extends StatefulWidget {
  @override
  _NadiShodhanaPageState createState() => _NadiShodhanaPageState();
}

class _NadiShodhanaPageState extends State<NadiShodhanaPage> {
  String _selectedTechnique = '4:6';
  String _selectedImage = 'assets/images/muladhara_chakra3.png'; // Default image
  final Map<String, String> _techniques = {
    '4:6': '4:6 Breathing (Recommended)',
    '2:3': '2:3 Breathing',
  };
  final List<Map<String, String>> _imageOptions = [
    {'name': 'Option 1', 'path': 'assets/images/option3.png'},
    {'name': 'Option 2', 'path': 'assets/images/option1.png'},
    {'name': 'Option 3', 'path': 'assets/images/option2.png'},
  ];

  late YoutubePlayerController _ytController;
  bool _isMinutesMode = false;
  int _selectedDuration = 5;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
          "https://www.youtube.com/watch?v=HhDUXFJDgB4")!,
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nadi Shodhana Pranayama"),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("Breathing Technique"),
            SizedBox(height: 8),
            _buildTechniqueButtons(),
            SizedBox(height: 24),
            _buildSectionTitle("Visualization Image"),
            SizedBox(height: 8),
            _buildImageSelector(),
            SizedBox(height: 24),
            _buildSectionTitle("Duration"),
            _buildDurationControls(),
            SizedBox(height: 24),
            _buildCustomizeButton(),
            SizedBox(height: 16),
            _buildBeginButton(),
            SizedBox(height: 24),
            // Steps dropdown
            ExpansionTile(
              title: Text(
                "How To Practice",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              children: _buildInstructionSteps(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Video player widget (unused after removal)
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _imageOptions.map((image) {
        bool isSelected = _selectedImage == image['path'];
        return GestureDetector(
          onTap: () => setState(() => _selectedImage = image['path']!),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Color(0xff98bad5) : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(image['path']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black54,
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  image['name']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
          print("Customized: Inhale ${result['inhale']}, Exhale ${result['exhale']}, Hold ${result['hold']}");
          final rounds = _isMinutesMode
              ? (_selectedDuration * 60) ~/
              (result['inhale']! + result['exhale']! + result['hold']!)
              : _selectedDuration;

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => BilateralScreen(
          //       inhaleDuration: result['inhale']!,
          //       exhaleDuration: result['exhale']!,
          //       rounds: rounds,
          //       imagePath: _selectedImage,
          //     ),
          //   ),
          // );
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
          final inhale = _selectedTechnique == '4:6' ? 4 : 2;
          final exhale = _selectedTechnique == '4:6' ? 6 : 3;
          final rounds = _isMinutesMode
              ? (_selectedDuration * 60) ~/ (inhale + exhale)
              : _selectedDuration;

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => BilateralScreen(
          //       inhaleDuration: inhale,
          //       exhaleDuration: exhale,
          //       rounds: rounds,
          //       imagePath: _selectedImage,
          //     ),
          //   ),
          // );
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

  // Instruction steps
  List<Widget> _buildInstructionSteps() {
    return [
      _buildStepCard(1, "Sit comfortably with spine straight and shoulders relaxed."),
      _buildStepCard(2, "Close your right nostril with your thumb; inhale slowly through the left."),
      _buildStepCard(3, "Close left nostril with ring finger, release thumb, exhale via right."),
      _buildStepCard(4, "Inhale through right, close it, then exhale through left."),
      _buildStepCard(5, "Continue alternating for your selected duration."),
    ];
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

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }
}
