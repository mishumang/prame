import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation_app/Instruction/instruction_abdo.dart';
import 'package:meditation_app/Instruction/instruction_bhramari.dart';
import 'package:meditation_app/Instruction/instruction_chandra.dart';
import 'package:meditation_app/Instruction/instruction_complete.dart';
import 'package:meditation_app/Instruction/instruction_chest.dart';
import 'package:meditation_app/Instruction/instruction_nadi.dart';
import 'package:meditation_app/Instruction/instruction_sheetali.dart';
import 'package:meditation_app/Instruction/instruction_sheetkari.dart';
import 'package:meditation_app/Instruction/instruction_surya.dart';
import 'package:meditation_app/Instruction/instruction_ujjayi.dart';
import 'package:meditation_app/Instruction/instruction_box.dart';
import 'package:meditation_app/Panic_Breathing_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditation_app/progress/graph.dart';
import 'profile/profile.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditation_app/courses_page.dart';

class RelaxScreen extends StatefulWidget {
  const RelaxScreen({Key? key}) : super(key: key);

  @override
  State<RelaxScreen> createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  String _userName = 'User';
  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const MeditationScreen(),
    CoursesPage(),
    ProgressScreen(),
    MeditationProfile(),
  ];

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _userName = doc.get('name') ?? 'User';
          _profileImageUrl = user.photoURL;
          _screens[0] = MeditationScreen(
            userName: _userName,
            profileImage: _profileImage,
            photoUrl: _profileImageUrl,
            pickImage: _pickImage,
          );
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        _screens[0] = MeditationScreen(
          userName: _userName,
          profileImage: _profileImage,
          photoUrl: _profileImageUrl,
          pickImage: _pickImage,
        );
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  void _handlePanicButton() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PanicBreathingPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_currentIndex],
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: _slideAnimation, child: child),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomAppBar(
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.spa,
                        color: _currentIndex == 0 ? Colors.teal : Colors.grey.shade400,
                        size: 28),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    icon: Icon(Icons.school,
                        color: _currentIndex == 1 ? Colors.teal : Colors.grey.shade400,
                        size: 28),
                    onPressed: () => _onItemTapped(1),
                  ),
                  const SizedBox(width: 48),
                  IconButton(
                    icon: Icon(Icons.bar_chart,
                        color: _currentIndex == 2 ? Colors.teal : Colors.grey.shade400,
                        size: 28),
                    onPressed: () => _onItemTapped(2),
                  ),
                  IconButton(
                    icon: Icon(Icons.person,
                        color: _currentIndex == 3 ? Colors.teal : Colors.grey.shade400,
                        size: 28),
                    onPressed: () => _onItemTapped(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handlePanicButton,
        backgroundColor: Colors.teal,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60),
          side: const BorderSide(color: Colors.white, width: 3),
        ),
        child: const Icon(Icons.emergency, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class MeditationScreen extends StatefulWidget {
  final String userName;
  final File? profileImage;
  final String? photoUrl;
  final Function()? pickImage;

  const MeditationScreen({
    Key? key,
    this.userName = 'User',
    this.profileImage,
    this.photoUrl,
    this.pickImage,
  }) : super(key: key);

  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // Combined items list for all categories with type indication
  List<Map<String, dynamic>> _allItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // Initialize all items
    _initializeItems();
  }

  void _initializeItems() {
    // Daily wisdom items
    final List<_WisdomItem> wisdomItems = [
      _WisdomItem(
        "Mindfulness",
        "Mindfulness is the basic human ability to be fully present.",
        "assets/images/thought1.jpg",
      ),
      _WisdomItem(
        "Balance",
        "Yoga helps create balance in body, mind and spirit.",
        "assets/images/thought2.jpg",
      ),
      _WisdomItem(
        "Breathe",
        "When in doubt, breathe out.",
        "assets/images/thoughts3.jpg",
      ),
    ];

    // Meditation breathing items
    final List<Map<String, dynamic>> meditationItems = [
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Abdominal\nBreathing",
          ['assets/images/13.png'],
          [Colors.teal[800]!, Colors.teal[400]!],
          AbdominalBreathingPage(),
        )
      },
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Chest\nBreathing",
          ['assets/images/15.png'],
          [Colors.teal[400]!, Colors.teal[600]!],
          ChestBreathingPage(),
        )
      },
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Complete\nBreathing",
          ['assets/images/17.png'],
          [Colors.teal[700]!, Colors.teal[300]!],
          CompleteBreathingPage(),
        )
      },
      // Add wisdom card to fill empty space
      {'type': 'wisdom', 'item': wisdomItems[0]},
    ];

    // Pranayama items
    final List<Map<String, dynamic>> pranayamaItems = [
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Bhramari\nPranayama",
          ['assets/images/21.png'],
          [Colors.teal[800]!, Colors.teal[300]!],
          BhramariBreathingPage(),
        )
      },
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Nadi\nShodhana",
          ['assets/images/1.png'],
          [Colors.teal[500]!, Colors.teal[200]!],
          NadiShodhanaPage(),
        )
      },
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Ujjayi\nPranayama",
          ['assets/images/7.png'],
          [Colors.teal[300]!, Colors.teal[700]!],
          UjjayiPranayamaPage(),
        )
      },
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Surya\nBhedana",
          ['assets/images/3.png'],
          [Colors.teal[200]!, Colors.teal[500]!],
          SuryaBhedanaPranayamaPage(),
        )
      },
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Chandra\nBhedana",
          ['assets/images/5.png'],
          [Colors.teal[800]!, Colors.teal[400]!],
          ChandraBhedanaPranayamaPage(),
        )
      },
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Sheetali\nPranayama",
          ['assets/images/13.png'],
          [Colors.teal[300]!, Colors.teal[600]!],
          SheetaliPranayamaPage(),
        )
      },
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Sheetkari\nPranayama",
          ['assets/images/9.png'],
          [Colors.teal[400]!, Colors.teal[800]!],
          SheetkariPranayamaPage(),
        )
      },
      // Add wisdom card to fill empty space
      {'type': 'wisdom', 'item': wisdomItems[1]},
    ];

    // Advanced items
    final List<Map<String, dynamic>> advancedItems = [
      {
        'type': 'breathing',
        'item': _BreathingItem(
          "Box\nBreathing",
          ['assets/images/19.png'],
          [Colors.teal[700]!, Colors.teal[300]!],
          BoxBreathingPage(),
        )
      },
      // Add remaining wisdom card
      {'type': 'wisdom', 'item': wisdomItems[2]},
    ];

    // Create sections with headers and items
    _allItems = [
      {'type': 'header', 'title': 'MEDITATION'},
      ...meditationItems,
      {'type': 'header', 'title': 'PRANAYAMA'},
      ...pranayamaItems,
      {'type': 'header', 'title': 'ADVANCED'},
      ...advancedItems,
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.3;
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: appBarHeight,
            pinned: true,
            stretch: true,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double top = constraints.biggest.height;
                final bool showTitle = _scrollOffset > appBarHeight - kToolbarHeight - 15;

                return FlexibleSpaceBar(
                  title: showTitle
                      ? Text(
                    '',
                    style: TextStyle(
                      color: Color(0xFF1A2C50),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  )
                      : null,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/ban.png',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xFF1A2C50).withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      if (!showTitle)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundImage: widget.profileImage != null
                                      ? FileImage(widget.profileImage!)
                                      : (widget.photoUrl != null
                                      ? NetworkImage(widget.photoUrl!)
                                      : null) as ImageProvider?,
                                  backgroundColor: Colors.white,
                                  child: (widget.profileImage == null && widget.photoUrl == null)
                                      ? Icon(Icons.person, size: 30, color: Color(0xFF1A2C50))
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      greeting,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      widget.userName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildUnifiedGrid(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedGrid() {
    // Group the items to build sections
    List<Widget> sections = [];
    String? currentHeader;
    List<Map<String, dynamic>> currentItems = [];

    for (var i = 0; i < _allItems.length; i++) {
      var item = _allItems[i];

      if (item['type'] == 'header') {
        // If we have accumulated items, add them to sections
        if (currentHeader != null && currentItems.isNotEmpty) {
          sections.add(_buildSectionTitle(currentHeader));
          sections.add(const SizedBox(height: 16));
          sections.add(_buildGridItems(currentItems));
          sections.add(const SizedBox(height: 30));

          // Reset for next section
          currentItems = [];
        }
        currentHeader = item['title'];
      } else {
        currentItems.add(item);
      }
    }

    // Add any remaining items
    if (currentHeader != null && currentItems.isNotEmpty) {
      sections.add(_buildSectionTitle(currentHeader));
      sections.add(const SizedBox(height: 16));
      sections.add(_buildGridItems(currentItems));
    }

    return Column(children: sections);
  }

  Widget _buildGridItems(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['type'] == 'breathing') {
          return _BreathingCard(item: item['item']);
        } else if (item['type'] == 'wisdom') {
          return _WisdomCard(item: item['item']);
        }
        return Container(); // Fallback
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.teal[800],
          letterSpacing: 1.5,
          fontFamily: 'Poppins',
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

// Class for Daily Wisdom items
class _WisdomItem {
  final String title;
  final String content;
  final String imagePath;

  _WisdomItem(this.title, this.content, this.imagePath);
}

// Widget for Daily Wisdom cards
class _WisdomCard extends StatelessWidget {
  final _WisdomItem item;

  const _WisdomCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image is missing
                  return Container(
                    color: Colors.amber[300],
                  );
                },
              ),
            ),

            // Semi-transparent overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathingItem {
  final String title;
  final List<String> imagePaths;
  final List<Color> gradientColors;
  final Widget destinationPage;

  _BreathingItem(this.title, this.imagePaths, this.gradientColors, this.destinationPage);
}

class _BreathingCard extends StatelessWidget {
  final _BreathingItem item;

  const _BreathingCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item.destinationPage),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image with scale effect
              Positioned.fill(
                child: Image.asset(
                  item.imagePaths[0],
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      item.gradientColors[1].withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      width: 40,
                      decoration: BoxDecoration(
                        color: item.gradientColors[0],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}