import 'package:flutter/material.dart';
import 'package:meditation_app/Instruction/instruction_abdo.dart';
import 'package:meditation_app/Instruction/instruction_chest.dart';
import 'package:meditation_app/Instruction/instruction_complete.dart';
import 'package:meditation_app/courses/abdominal_breathing_page.dart';
import 'package:meditation_app/courses/bhramari_pranayama_page.dart';
import 'package:meditation_app/courses/chandra_bhedana_pranayama_page.dart';
import 'package:meditation_app/courses/chest_breathing_page.dart';
import 'package:meditation_app/courses/complete_breathing_page.dart';
import 'package:meditation_app/courses/nadi_shodhana_pranayama_page.dart';
import 'package:meditation_app/courses/sheetali_pranayama_page.dart';
import 'package:meditation_app/courses/sheetkari_pranayama_page.dart';
import 'package:meditation_app/courses/surya_bhedana_pranayama_page.dart';
import 'package:meditation_app/courses/ujjayi_pranayama_page.dart';

class CourseInfo {
  final String title;
  final String subtitle;
  final String image;
  final List<Color> gradientColors;
  final String duration;
  final String difficulty;
  final IconData icon;

  CourseInfo({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.gradientColors,
    required this.duration,
    required this.difficulty,
    required this.icon,
  });
}

class CoursesPage extends StatefulWidget {
  const CoursesPage({Key? key}) : super(key: key);

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedCategoryIndex = 0;

  // Color scheme constants
  static const Color lightTeal = Color(0xFF80CBC4);
  static const Color mediumTeal = Color(0xFF009688);
  static const Color darkTeal = Color(0xFF00695C);

  // Mapping of course titles to their dedicated pages
  final Map<String, Widget Function()> coursePages = {
    "Abdominal Breathing": () => AbdominalBreathingLearnMorePage(),
    "Chest Breathing": () => ChestBreathingLearnMorePage(),
    "Complete Breathing": () => CompleteBreathingLearnMorePage(),
    "Bhramari Pranayama": () => BhramariBreathingLearnMorePage(),
    "Nadi Shodhana Pranayama": () => const NadiShodhanaPranayamaPage(),
    "Ujjayi Pranayama": () => const UjjayiPranayamaLearnMorePage(),
    "Surya Bhedana Pranayama": () => const SuryaBhedanaPranayamaLearnMorePage(),
    "Chandra Bhedana Pranayama": () => const ChandraBhedanaPranayamaLearnMorePage(),
    "Sheetali Pranayama": () => const SheetaliPranayamaLearnMorePage(),
    "Sheetkari Pranayama": () => const SheetkariPranayamaLearnMorePage(),
  };

  // Enhanced course data with teal color scheme - subtitles removed
  final Map<String, List<CourseInfo>> courseCategories = {
    "Breathing Foundations": [
      CourseInfo(
        title: "Abdominal Breathing",
        subtitle: "",
        image: "assets/images/abdominal_breathing.png",
        gradientColors: [lightTeal, mediumTeal],
        duration: "5-10 min",
        difficulty: "Beginner",
        icon: Icons.air,
      ),
      CourseInfo(
        title: "Chest Breathing",
        subtitle: "",
        image: "assets/images/chest_breathing.png",
        gradientColors: [mediumTeal, darkTeal],
        duration: "8-12 min",
        difficulty: "Beginner",
        icon: Icons.favorite,
      ),
      CourseInfo(
        title: "Complete Breathing",
        subtitle: "",
        image: "assets/images/complete_breathing.png",
        gradientColors: [lightTeal, darkTeal],
        duration: "10-15 min",
        difficulty: "Intermediate",
        icon: Icons.landscape,
      ),
    ],
    "Advanced Pranayama": [
      CourseInfo(
        title: "Bhramari Pranayama",
        subtitle: "",
        image: "assets/images/bhramari.png",
        gradientColors: [mediumTeal, lightTeal],
        duration: "8-15 min",
        difficulty: "Intermediate",
        icon: Icons.music_note,
      ),
      CourseInfo(
        title: "Nadi Shodhana Pranayama",
        subtitle: "",
        image: "assets/images/nadishodana.png",
        gradientColors: [lightTeal, mediumTeal],
        duration: "10-20 min",
        difficulty: "Intermediate",
        icon: Icons.balance,
      ),
      CourseInfo(
        title: "Ujjayi Pranayama",
        subtitle: "",
        image: "assets/images/ujjayi.png",
        gradientColors: [darkTeal, mediumTeal],
        duration: "5-15 min",
        difficulty: "Advanced",
        icon: Icons.waves,
      ),
      CourseInfo(
        title: "Surya Bhedana Pranayama",
        subtitle: "",
        image: "assets/images/suryabedhana.png",
        gradientColors: [mediumTeal, darkTeal],
        duration: "8-12 min",
        difficulty: "Advanced",
        icon: Icons.wb_sunny,
      ),
      CourseInfo(
        title: "Chandra Bhedana Pranayama",
        subtitle: "",
        image: "assets/images/chandrabedhana.png",
        gradientColors: [lightTeal, darkTeal],
        duration: "8-12 min",
        difficulty: "Advanced",
        icon: Icons.nightlight_round,
      ),
      CourseInfo(
        title: "Sheetali Pranayama",
        subtitle: "",
        image: "assets/images/sheetali.png",
        gradientColors: [lightTeal, mediumTeal],
        duration: "5-10 min",
        difficulty: "Intermediate",
        icon: Icons.ac_unit,
      ),
      CourseInfo(
        title: "Sheetkari Pranayama",
        subtitle: "",
        image: "assets/images/sheetkari.png",
        gradientColors: [mediumTeal, lightTeal],
        duration: "5-10 min",
        difficulty: "Intermediate",
        icon: Icons.grain,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildEnhancedAppBar(),
          _buildWelcomeSection(),
          _buildCategoryTabs(),
          _buildCoursesGrid(),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                lightTeal,
                mediumTeal,
                darkTeal,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background shapes
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Discover Inner Peace",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Master the art of breathing and meditation",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
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
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mediumTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: mediumTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Journey Awaits",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Choose from beginner to advanced techniques",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: courseCategories.keys.length,
          itemBuilder: (context, index) {
            final category = courseCategories.keys.elementAt(index);
            final isSelected = index == _selectedCategoryIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [mediumTeal, darkTeal],
                    )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isSelected ? 0.15 : 0.05),
                        blurRadius: isSelected ? 15 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCoursesGrid() {
    final selectedCategory = courseCategories.keys.elementAt(_selectedCategoryIndex);
    final courses = courseCategories[selectedCategory]!;

    return SliverPadding(
      padding: const EdgeInsets.all(24.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 20.0,
          childAspectRatio: 2.2,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return _buildEnhancedCourseCard(courses[index], index);
          },
          childCount: courses.length,
        ),
      ),
    );
  }

  Widget _buildEnhancedCourseCard(CourseInfo course, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: () {
          if (coursePages.containsKey(course.title)) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    coursePages[course.title]!(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: child,
                  );
                },
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: course.gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: course.gradientColors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              course.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            course.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoChip(course.duration, Icons.access_time),
                              const SizedBox(width: 8),
                              _buildInfoChip(course.difficulty, Icons.signal_cellular_alt),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            course.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  course.icon,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow indicator
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}