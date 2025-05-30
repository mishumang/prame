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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
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
            flexibleSpace: FlexibleSpaceBar(
              title: _scrollOffset > appBarHeight - kToolbarHeight - 15
                  ? Text(
                      'Meditation & Pranayama',
                      style: TextStyle(
                        color: Colors.teal[800],
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
                    'assets/images/meditation_bg.jpeg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.teal[800]!.withOpacity(0.6),
                          Colors.teal[100]!.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  if (_scrollOffset <= appBarHeight - kToolbarHeight - 10)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (widget.profileImage != null || widget.photoUrl != null)
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: widget.profileImage != null
                                        ? FileImage(widget.profileImage!)
                                        : (widget.photoUrl != null
                                            ? NetworkImage(widget.photoUrl!)
                                            : null) as ImageProvider,
                                    backgroundColor: Colors.white,
                                  )
                                else
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person, color: Colors.teal),
                                  ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      greeting,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      widget.userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Meditation & Pranayama',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('MEDITATION'),
                  const SizedBox(height: 16),
                  _buildBreathingGrid([
                    _BreathingItem(
                      "Abdominal\nBreathing",
                      ['assets/images/12.png'],
                      [Colors.teal[800]!, Colors.teal[400]!],
                      AbdominalBreathingPage(),
                    ),
                    _BreathingItem(
                      "Chest\nBreathing",
                      ['assets/images/14.png'],
                      [Colors.teal[400]!, Colors.teal[600]!],
                      ChestBreathingPage(),
                    ),
                    _BreathingItem(
                      "Complete\nBreathing",
                      ['assets/images/16.png'],
                      [Colors.teal[700]!, Colors.teal[300]!],
                      CompleteBreathingPage(),
                    ),
                  ]),
                  const SizedBox(height: 30),
                  _buildSectionTitle('PRANAYAMA'),
                  const SizedBox(height: 16),
                  _buildBreathingGrid([
                    _BreathingItem(
                      "Bhramari\nPranayama",
                      ['assets/images/21.png'],
                      [Colors.teal[800]!, Colors.teal[300]!],
                      BhramariBreathingPage(),
                    ),
                    _BreathingItem(
                      "Nadi\nShodhana",
                      ['assets/images/chndra1.png'],
                      [Colors.teal[500]!, Colors.teal[200]!],
                      NadiShodhanaPage(),
                    ),
                    _BreathingItem(
                      "Ujjayi\nPranayama",
                      ['assets/images/7.png'],
                      [Colors.teal[300]!, Colors.teal[700]!],
                      UjjayiPranayamaPage(),
                    ),
                    _BreathingItem(
                      "Surya\nBhedana",
                      ['assets/images/2.png'],
                      [Colors.teal[200]!, Colors.teal[500]!],
                      SuryaBhedanaPranayamaPage(),
                    ),
                    _BreathingItem(
                      "Chandra\nBhedana",
                      ['assets/images/5.png'],
                      [Colors.teal[800]!, Colors.teal[400]!],
                      ChandraBhedanaPranayamaPage(),
                    ),
                    _BreathingItem(
                      "Sheetali\nPranayama",
                      ['assets/images/13.png'],
                      [Colors.teal[300]!, Colors.teal[600]!],
                      SheetaliPranayamaPage(),
                    ),
                    _BreathingItem(
                      "Sheetkari\nPranayama",
                      ['assets/images/9.png'],
                      [Colors.teal[400]!, Colors.teal[800]!],
                      SheetkariPranayamaPage(),
                    ),
                  ]),
                  const SizedBox(height: 30),
                  _buildSectionTitle('ADVANCED'),
                  const SizedBox(height: 16),
                  _buildBreathingGrid([
                    _BreathingItem(
                      "Box\nBreathing",
                      ['assets/images/18.png'],
                      [Colors.teal[700]!, Colors.teal[300]!],
                      BoxBreathingPage(),
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildBreathingGrid(List<_BreathingItem> items) {
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
        return _BreathingCard(item: items[index]);
      },
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