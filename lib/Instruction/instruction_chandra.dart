import 'package:flutter/material.dart';
import 'package:meditation_app/courses/chandra_bhedana_pranayama_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../Breathing_Pages/bilateral_screen.dart';
import '../Customization/customize.dart';

class ChandraBhedanaPranayamaPage extends StatefulWidget {
  @override
  _ChandraBhedanaPranayamaPageState createState() => _ChandraBhedanaPranayamaPageState();
}

class _ChandraBhedanaPranayamaPageState extends State<ChandraBhedanaPranayamaPage> {
  static const Color _brandColor = Color(0xff98bad5);

  String _selectedTechnique = '4:4';
  final Map<String, String> _techniques = {
    '4:4': '4:4 Chandra Bhedana (Standard)',
    'custom': 'Customize Technique',
  };

  final String _videoUrl = 'https://www.youtube.com/watch?v=YOUR_CHANDRA_VIDEO_ID';
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
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
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
    // default 4:4
    return 4 + 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chandra Bhedana Pranayama"),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: _brandColor,
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

            _buildSectionTitle("Duration"),
            _buildDurationControls(),
            SizedBox(height: 24),

            _buildCustomizeButton(),
            SizedBox(height: 16),

            _buildBeginButton(),
            SizedBox(height: 32),

            _buildSectionTitle("About Chandra Bhedana"),
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
      ),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }

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
        ? [5,10,15,20,25,30,35,40,45,50,55,60]
        : [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75];
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
          border: Border.all(color: isActive ? _brandColor : Colors.grey[400]!),
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
        ? "≈ ${(totalSeconds/_roundSeconds).toStringAsFixed(0)} rounds"
        : "≈ ${(totalSeconds/60).toStringAsFixed(1)} minutes";
    return Text(hint, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]));
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
      });
    }
  }

  Widget _buildBeginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          final inhale = _selectedTechnique == '4:4' ? 4 : (_customInhale ?? 4);
          final exhale = _selectedTechnique == '4:4' ? 4 : (_customExhale ?? 4);
          final rounds = _isMinutesMode
              ? (_selectedDuration * 60) ~/ (inhale + exhale)
              : _selectedDuration;
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => BilateralScreen(
          //       inhaleDuration: inhale,
          //       exhaleDuration: exhale,
          //       rounds: rounds,
          //     ),
          //   ),
          // );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      "Chandra Bhedana Pranayama involves inhaling through the left nostril "
          "and exhaling through the right. It is said to calm the mind, cool the body, "
          "and balance lunar energy.",
      style: TextStyle(fontSize: 15, height: 1.5),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _ytController,
        aspectRatio: 16/9,
        showVideoProgressIndicator: true,
      ),
    );
  }

  List<Widget> _buildInstructionSteps() {
    final steps = [
      "Sit comfortably with your spine straight and shoulders relaxed.",
      "Close your right nostril gently with your finger, inhale slowly through the left.",
      "Close your left nostril, exhale gently through the right.",
      "Continue alternating, focusing on the cooling lunar energy.",
      "Maintain a smooth, steady rhythm for your selected duration.",
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

  Widget _buildLearnMoreButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChandraBhedanaPranayamaLearnMorePage()),
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
