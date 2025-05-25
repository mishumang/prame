import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BhramariBreathingLearnMorePage extends StatefulWidget {
  const BhramariBreathingLearnMorePage({Key? key}) : super(key: key);

  @override
  _BhramariBreathingLearnMorePageState createState() =>
      _BhramariBreathingLearnMorePageState();
}

class _BhramariBreathingLearnMorePageState
    extends State<BhramariBreathingLearnMorePage> with TickerProviderStateMixin {
  late String currentUserId;
  YoutubePlayerController? _controller;
  bool _isPlayerInitialized = false;
  Timer? _positionTimer;

  // --- FAVORITE FUNCTIONALITY ---
  bool _isFavorite = false;

  // Track the currently playing chapter
  String? _currentVideoId;

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
    await _loadChapterProgress();
    await _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite =
          prefs.getBool("favorite_bhramari_pranayama_${currentUserId}") ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await prefs.setBool("favorite_bhramari_pranayama_${currentUserId}", _isFavorite);
  }

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

  void _changeChapter(String videoUrl) {
    String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
    setState(() {
      _currentVideoId = videoId;
    });
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
    _animationController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _loadChapterProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var chapter in chapters) {
      String videoUrl = chapter["videoUrl"]!;
      String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
      int savedSeconds =
          prefs.getInt("progress_${currentUserId}_$videoId") ?? 0;
      _chapterProgressSeconds[videoId] = savedSeconds;
      int durationMins = int.tryParse(chapter["duration"]!.split(" ")[0]) ?? 1;
      double fraction = savedSeconds / (durationMins * 60);
      if (fraction > 1) fraction = 1;
      _chapterProgress[videoId] = fraction;
    }
    setState(() {});
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      if (_controller == null) return;
      final position = _controller!.value.position;
      String currentVideoId = _controller!.metadata.videoId;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          "progress_${currentUserId}_$currentVideoId", position.inSeconds);
      _chapterProgressSeconds[currentVideoId] = position.inSeconds;
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: player,
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    String thumbnailUrl = chapters[0]["thumbnail"]!;
    return GestureDetector(
      onTap: () {
        String videoUrl = chapters[0]["videoUrl"]!;
        _initializeVideo(videoUrl);
        setState(() {
          _currentVideoId = YoutubePlayer.convertUrlToId(videoUrl)!;
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

  Widget _buildChapterItem(Map<String, String> chapter) {
    String videoUrl = chapter["videoUrl"]!;
    String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
    double progress = _chapterProgress[videoId] ?? 0.0;
    bool isCurrentChapter = _currentVideoId == videoId;

    return GestureDetector(
      onTap: () => _changeChapter(videoUrl),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Increased for theme consistency
          gradient: isCurrentChapter
              ? LinearGradient(
            colors: [lightTeal, mediumTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isCurrentChapter ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isCurrentChapter ? 0.15 : 0.05),
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
                    chapter["thumbnail"]!,
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
                      chapter["duration"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                if (isCurrentChapter)
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
                      chapter["title"]!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isCurrentChapter ? Colors.white : const Color(0xFF1A202C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                  color: isCurrentChapter ? mediumTeal : Colors.green,
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
          "Bhramari Breathing",
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
              color: _isFavorite ? Colors.red : mediumTeal,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                  "Bhramari Breathing",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Learn deep bhramari breathing to improve relaxation and lung capacity.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Chapters",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
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
      ),
    );
  }
}