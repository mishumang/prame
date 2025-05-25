import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbdominalBreathingLearnMorePage extends StatefulWidget {
  const AbdominalBreathingLearnMorePage({Key? key}) : super(key: key);

  @override
  _AbdominalBreathingLearnMorePageState createState() =>
      _AbdominalBreathingLearnMorePageState();
}

class _AbdominalBreathingLearnMorePageState
    extends State<AbdominalBreathingLearnMorePage> with TickerProviderStateMixin {
  late String currentUserId;
  YoutubePlayerController? _controller;
  bool _isPlayerInitialized = false;
  Timer? _positionTimer;

  // --- FAVORITE FUNCTIONALITY ---
  bool _isFavorite = false;

  // Single video with multiple segments/chapters
  final String mainVideoUrl = "https://www.youtube.com/watch?v=HhDUXFJDgB4";
  late final String videoId;

  // Video segments (chapters) with start times in seconds
  final List<Map<String, dynamic>> segments = [
    {
      "title": "Introduction to Abdominal Breathing",
      "startTime": 0,
      "endTime": 300,
      "duration": "5 mins",
      "description": "Learn the basics of abdominal breathing technique",
    },
    {
      "title": "Proper Positioning",
      "startTime": 300,
      "endTime": 600,
      "duration": "5 mins",
      "description": "How to position your body for optimal breathing",
    },
    {
      "title": "Breathing Exercise Practice",
      "startTime": 600,
      "endTime": 900,
      "duration": "5 mins",
      "description": "Guided practice session for abdominal breathing",
    },
    {
      "title": "Advanced Techniques",
      "startTime": 900,
      "endTime": 1200,
      "duration": "5 mins",
      "description": "Advanced breathing patterns and variations",
    },
  ];

  // Progress tracking for segments
  Map<int, double> _segmentProgress = {};
  int _currentSegmentIndex = 0;

  // Animation for fade-in effect
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Color scheme from CoursesPage
  static const Color lightTeal = Color(0xFF80CBC4);
  static const Color mediumTeal = Color(0xFF009688);
  static const Color darkTeal = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    videoId = YoutubePlayer.convertUrlToId(mainVideoUrl)!;
    _initializeUserIdAndData();

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _initializeUserIdAndData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId') ?? 'guest';
    await _loadSegmentProgress();
    await _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite =
          prefs.getBool("favorite_abdominal_breathing_${currentUserId}") ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await prefs.setBool("favorite_abdominal_breathing_${currentUserId}", _isFavorite);
  }

  void _initializeVideo({int startAt = 0}) {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        startAt: startAt,
      ),
    );

    _controller!.addListener(() {
      if (_controller!.value.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  void _jumpToSegment(int segmentIndex) {
    int startTime = segments[segmentIndex]["startTime"];

    setState(() {
      _currentSegmentIndex = segmentIndex;
    });

    if (_controller == null) {
      _initializeVideo(startAt: startTime);
      setState(() {
        _isPlayerInitialized = true;
      });
      _startPositionTimer();
    } else {
      _controller!.seekTo(Duration(seconds: startTime));
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _controller?.dispose();
    _animationController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _loadSegmentProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < segments.length; i++) {
      int savedSeconds = prefs.getInt("segment_progress_${currentUserId}_${videoId}_$i") ?? 0;
      int segmentDuration = segments[i]["endTime"] - segments[i]["startTime"];
      double progress = savedSeconds / segmentDuration;
      if (progress > 1) progress = 1;
      _segmentProgress[i] = progress;
    }
    setState(() {});
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(Duration(seconds: 2), (_) async {
      if (_controller == null) return;

      final position = _controller!.value.position;
      int currentSeconds = position.inSeconds;

      int activeSegmentIndex = _findActiveSegment(currentSeconds);
      if (activeSegmentIndex != -1) {
        setState(() {
          _currentSegmentIndex = activeSegmentIndex;
        });

        int segmentStart = segments[activeSegmentIndex]["startTime"];
        int segmentEnd = segments[activeSegmentIndex]["endTime"];
        int segmentDuration = segmentEnd - segmentStart;
        int progressInSegment = currentSeconds - segmentStart;

        if (progressInSegment >= 0) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt("segment_progress_${currentUserId}_${videoId}_$activeSegmentIndex", progressInSegment);

          double progress = progressInSegment / segmentDuration;
          if (progress > 1) progress = 1;

          setState(() {
            _segmentProgress[activeSegmentIndex] = progress;
          });
        }
      }
    });
  }

  int _findActiveSegment(int currentSeconds) {
    for (int i = 0; i < segments.length; i++) {
      int startTime = segments[i]["startTime"];
      int endTime = segments[i]["endTime"];
      if (currentSeconds >= startTime && currentSeconds < endTime) {
        return i;
      }
    }
    return -1;
  }

  Widget _buildVideoPlayer() {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        aspectRatio: 16 / 9,
      ),
      builder: (context, player) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: player,
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    String thumbnailUrl = "https://img.youtube.com/vi/$videoId/0.jpg";
    return GestureDetector(
      onTap: () {
        _initializeVideo();
        setState(() {
          _isPlayerInitialized = true;
        });
        _startPositionTimer();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              thumbnailUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
          const Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(Map<String, dynamic> segment, int index) {
    double progress = _segmentProgress[index] ?? 0.0;
    bool isCurrentSegment = index == _currentSegmentIndex;

    return GestureDetector(
      onTap: () => _jumpToSegment(index),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Increased for theme consistency
          gradient: isCurrentSegment
              ? LinearGradient(
            colors: [lightTeal, mediumTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isCurrentSegment ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isCurrentSegment ? 0.15 : 0.05),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    "https://img.youtube.com/vi/$videoId/0.jpg",
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      segment["duration"],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                if (isCurrentSegment)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      segment["title"],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isCurrentSegment ? Colors.white : const Color(0xFF1A202C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        segment["description"],
                        style: TextStyle(
                          fontSize: 11,
                          color: isCurrentSegment ? Colors.white.withOpacity(0.9) : const Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 4,
              width: double.infinity,
              color: Colors.grey[300],
              child: FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 4,
                  color: isCurrentSegment ? mediumTeal : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Match CoursesPage background
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [lightTeal, mediumTeal, darkTeal],
            ),
          ),
        ),
        title: const Text(
          "Abdominal Breathing",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : mediumTeal, // Use mediumTeal for unfilled state
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Match CoursesPage scroll physics
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isPlayerInitialized ? _buildVideoPlayer() : _buildPlaceholder(),
                const SizedBox(height: 10),
                const Text(
                  "Abdominal Breathing",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C), // Match CoursesPage primary text
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Learn deep abdominal breathing to improve relaxation and lung capacity.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B), // Match CoursesPage secondary text
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Segments",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    if (_isPlayerInitialized)
                      Text(
                        "Current: ${segments[_currentSegmentIndex]["title"]}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: mediumTeal, // Use mediumTeal instead of blue
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: segments.length,
                    itemBuilder: (context, index) {
                      final segment = segments[index];
                      return _buildSegmentItem(segment, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}