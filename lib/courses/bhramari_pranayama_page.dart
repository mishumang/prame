import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BhramariBreathingLearnMorePage extends StatefulWidget {
  const BhramariBreathingLearnMorePage({Key? key}) : super(key: key);

  @override
  _BhramariBreathingLearnMorePageState createState() =>
      _BhramariBreathingLearnMorePageState();
}

class _BhramariBreathingLearnMorePageState
    extends State<BhramariBreathingLearnMorePage> {
  late final String currentUserId;
  YoutubePlayerController? _controller;
  bool _isPlayerInitialized = false;
  Timer? _positionTimer;

  // --- NEW FAVORITE FUNCTIONALITY ---
  bool _isFavorite = false; // Holds the favorite state for this course.
  // --- END NEW CODE ---

  // Simulated database with YouTube video links, thumbnails, and durations.
  final List<Map<String, String>> chapters = [
    {
      "title": "Chapter 1",
      "videoUrl": "https://www.youtube.com/watch?v=H7XI-EsIkCY",
      "thumbnail": "https://img.youtube.com/vi/H7XI-EsIkCY/0.jpg",
      "duration": "8 mins",
    },
    {
      "title": "Chapter 2",
      "videoUrl": "https://www.youtube.com/watch?v=8H1vGh1Pk38",
      "thumbnail": "https://img.youtube.com/vi/8H1vGh1Pk38/0.jpg",
      "duration": "6 mins",
    },
  ];

  // In-memory storage for chapter progress.
  Map<String, double> _chapterProgress = {};
  Map<String, int> _chapterProgressSeconds = {};

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUserId = user?.uid ?? 'guest';
    _loadChapterProgress();
    // --- NEW FAVORITE FUNCTIONALITY ---
    _loadFavoriteStatus();
    // --- END NEW CODE ---
  }

  // --- NEW FAVORITE FUNCTIONALITY ---
  /// Loads the favorite status for this course using a user-specific key.
  Future<void> _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Updated key to "favorite_bhramari_pranayama_${currentUserId}"
      _isFavorite =
          prefs.getBool("favorite_bhramari_pranayama_${currentUserId}") ?? false;
    });
  }

  /// Toggles the favorite state and saves it using SharedPreferences.
  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await prefs.setBool("favorite_bhramari_pranayama_${currentUserId}", _isFavorite);
  }
  // --- END NEW CODE ---

  /// Initializes the YouTube player for a given video URL,
  /// starting at the previously saved progress (if any).
  void _initializeVideo(String videoUrl) {
    String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
    int startAtSeconds = _chapterProgressSeconds[videoId] ?? 0;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        startAt: startAtSeconds,
      ),
    );

    // Listen for full-screen changes.
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

  /// Changes the chapter by loading the new video,
  /// starting at the previously saved progress (if available).
  void _changeChapter(String videoUrl) {
    String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
    int startAtSeconds = _chapterProgressSeconds[videoId] ?? 0;
    if (_controller == null) {
      _initializeVideo(videoUrl);
      setState(() {
        _isPlayerInitialized = true;
      });
      _startPositionTimer();
    } else {
      _controller!.load(videoId, startAt: startAtSeconds);
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  /// Loads saved progress for each chapter from SharedPreferences.
  Future<void> _loadChapterProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var chapter in chapters) {
      String videoUrl = chapter["videoUrl"]!;
      String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
      // Use a user-specific key.
      int savedSeconds =
          prefs.getInt("progress_${currentUserId}_$videoId") ?? 0;
      _chapterProgressSeconds[videoId] = savedSeconds;
      // Parse the duration string (e.g., "8 mins" or "6 mins").
      int durationMins = int.tryParse(chapter["duration"]!.split(" ")[0]) ?? 1;
      double fraction = savedSeconds / (durationMins * 60);
      if (fraction > 1) fraction = 1;
      _chapterProgress[videoId] = fraction;
    }
    setState(() {});
  }

  /// Starts a timer that periodically saves the current playback position
  /// and updates the progress indicator.
  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      if (_controller == null) return;
      final position = _controller!.value.position;
      String currentVideoId = _controller!.metadata.videoId;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Save progress with a user-specific key.
      await prefs.setInt(
          "progress_${currentUserId}_$currentVideoId", position.inSeconds);
      _chapterProgressSeconds[currentVideoId] = position.inSeconds;
      // Update progress indicator.
      for (var chapter in chapters) {
        String vidId = YoutubePlayer.convertUrlToId(chapter["videoUrl"]!)!;
        if (vidId == currentVideoId) {
          int durationMins =
              int.tryParse(chapter["duration"]!.split(" ")[0]) ?? 1;
          double fraction = position.inSeconds / (durationMins * 60);
          if (fraction > 1) fraction = 1;
          setState(() {
            _chapterProgress[vidId] = fraction;
          });
        }
      }
    });
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
    String thumbnailUrl = chapters[0]["thumbnail"]!;
    return GestureDetector(
      onTap: () {
        _initializeVideo(chapters[0]["videoUrl"]!);
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

  /// Builds a chapter item with thumbnail, title, and a progress indicator.
  Widget _buildChapterItem(Map<String, String> chapter) {
    String videoUrl = chapter["videoUrl"]!;
    String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
    double progress = _chapterProgress[videoId] ?? 0.0;

    return GestureDetector(
      onTap: () => _changeChapter(videoUrl),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
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
                    chapter["thumbnail"]!,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.black54,
                    child: Text(
                      chapter["duration"]!,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                chapter["title"]!,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                  color: Colors.green,
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
        title: const Text("Bhramari Breathing"),
        actions: [
          // --- NEW FAVORITE FUNCTIONALITY ---
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: _toggleFavorite,
          ),
          // --- END NEW CODE ---
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
                "Bhramari Breathing",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Learn deep bhramari breathing to improve relaxation and lung capacity.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                "Chapters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return _buildChapterItem(chapter);
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
