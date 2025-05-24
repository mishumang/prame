import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbdominalBreathingLearnMorePage extends StatefulWidget {
  const AbdominalBreathingLearnMorePage({Key? key}) : super(key: key);

  @override
  _AbdominalBreathingLearnMorePageState createState() =>
      _AbdominalBreathingLearnMorePageState();
}

class _AbdominalBreathingLearnMorePageState
    extends State<AbdominalBreathingLearnMorePage> {
  late final String currentUserId;
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
      "startTime": 0, // Start at beginning
      "endTime": 300, // 5 minutes
      "duration": "5 mins",
      "description": "Learn the basics of abdominal breathing technique",
    },
    {
      "title": "Proper Positioning",
      "startTime": 300, // 5 minutes
      "endTime": 600, // 10 minutes
      "duration": "5 mins",
      "description": "How to position your body for optimal breathing",
    },
    {
      "title": "Breathing Exercise Practice",
      "startTime": 600, // 10 minutes
      "endTime": 900, // 15 minutes
      "duration": "5 mins",
      "description": "Guided practice session for abdominal breathing",
    },
    {
      "title": "Advanced Techniques",
      "startTime": 900, // 15 minutes
      "endTime": 1200, // 20 minutes
      "duration": "5 mins",
      "description": "Advanced breathing patterns and variations",
    },
  ];

  // Progress tracking for segments
  Map<int, double> _segmentProgress = {};
  int _currentSegmentIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUserId = user?.uid ?? 'guest';
    videoId = YoutubePlayer.convertUrlToId(mainVideoUrl)!;
    _loadSegmentProgress();
    _loadFavoriteStatus();
  }

  // --- FAVORITE FUNCTIONALITY ---
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

  /// Initializes the YouTube player, starting at a specific time
  void _initializeVideo({int startAt = 0}) {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        startAt: startAt,
      ),
    );

    // Listen for full-screen changes
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

  /// Jumps to a specific segment in the video
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  /// Loads saved progress for segments from SharedPreferences
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

  /// Starts a timer that tracks progress and updates segment completion
  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(Duration(seconds: 2), (_) async {
      if (_controller == null) return;

      final position = _controller!.value.position;
      int currentSeconds = position.inSeconds;

      // Determine which segment we're currently in
      int activeSegmentIndex = _findActiveSegment(currentSeconds);
      if (activeSegmentIndex != -1) {
        setState(() {
          _currentSegmentIndex = activeSegmentIndex;
        });

        // Calculate progress within the current segment
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

  /// Finds which segment is currently active based on video position
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
        return player;
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
          Image.network(
            thumbnailUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.black38,
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

  /// Builds a segment item with progress indicator
  Widget _buildSegmentItem(Map<String, dynamic> segment, int index) {
    double progress = _segmentProgress[index] ?? 0.0;
    bool isCurrentSegment = index == _currentSegmentIndex;

    return GestureDetector(
      onTap: () => _jumpToSegment(index),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: isCurrentSegment
              ? Border.all(color: Colors.blue, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
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
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    "https://img.youtube.com/vi/$videoId/0.jpg",
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.black54,
                    child: Text(
                      segment["duration"],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
                        color: Colors.blue,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    segment["title"],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    segment["description"],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Progress indicator
            Container(
              height: 4,
              width: double.infinity,
              color: Colors.grey[300],
              child: FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 4,
                  color: isCurrentSegment ? Colors.blue : Colors.green,
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
      appBar: AppBar(
        title: const Text("Abdominal Breathing"),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isPlayerInitialized ? _buildVideoPlayer() : _buildPlaceholder(),
              const SizedBox(height: 10),
              const Text(
                "Abdominal Breathing",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Learn deep abdominal breathing to improve relaxation and lung capacity.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Segments",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_isPlayerInitialized)
                    Text(
                      "Current: ${segments[_currentSegmentIndex]["title"]}",
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
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
    );
  }
}