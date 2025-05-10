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

// First, define the CourseInfo class outside the CoursesPage class
class CourseInfo {
  final String title;
  final String image;
  final Color color;

  CourseInfo({
    required this.title,
    required this.image,
    required this.color,
  });
}

class CoursesPage extends StatelessWidget {
  CoursesPage({Key? key}) : super(key: key);

  // Mapping of course titles to their dedicated pages
  final Map<String, Widget Function()> coursePages = {
    "Abdominal Breathing": () =>  AbdominalBreathingLearnMorePage(),
    "Chest Breathing": () =>  ChestBreathingLearnMorePage(),
    "Complete Breathing": () =>  CompleteBreathingLearnMorePage(),
    "Bhramari Pranayama": () => BhramariBreathingLearnMorePage(),
    "Nadi Shodhana Pranayama": () => const NadiShodhanaPranayamaPage(),
    "Ujjayi Pranayama": () => const UjjayiPranayamaLearnMorePage(),
    "Surya Bhedana Pranayama": () => const SuryaBhedanaPranayamaLearnMorePage(),
    "Chandra Bhedana Pranayama": () => const ChandraBhedanaPranayamaLearnMorePage(),
    "Sheetali Pranayama": () => const SheetaliPranayamaLearnMorePage(),
    "Sheetkari Pranayama": () => const SheetkariPranayamaLearnMorePage(),
  };

  // Course data organized by category
  final Map<String, List<CourseInfo>> courseCategories = {
    "Breathing Techniques": [
      CourseInfo(
        title: "Abdominal Breathing",
        image: "assets/images/abdominal_breathing.png",
        color: const Color(0xFF6A8CAF),
      ),
      CourseInfo(
        title: "Chest Breathing",
        image: "assets/images/chest_breathing.png",
        color: const Color(0xFF7F9EB2),
      ),
      CourseInfo(
        title: "Complete Breathing",
        image: "assets/images/complete_breathing.png",
        color: const Color(0xFF95B0C5),
      ),
    ],
    "Pranayama Techniques": [
      CourseInfo(
        title: "Bhramari Pranayama",
        image: "assets/images/bhramari.png",
        color: const Color(0xFF8A6BBE),
      ),
      CourseInfo(
        title: "Nadi Shodhana Pranayama",
        image: "assets/images/nadishodana.png",
        color: const Color(0xFF7B5CB3),
      ),
      CourseInfo(
        title: "Ujjayi Pranayama",
        image: "assets/images/ujjayi.png",
        color: const Color(0xFF6C4DA8),
      ),
      CourseInfo(
        title: "Surya Bhedana Pranayama",
        image: "assets/images/suryabedhana.png",
        color: const Color(0xFF5D3E9D),
      ),
      CourseInfo(
        title: "Chandra Bhedana Pranayama",
        image: "assets/images/chandrabedhana.png",
        color: const Color(0xFF4E2F92),
      ),
      CourseInfo(
        title: "Sheetali Pranayama",
        image: "assets/images/sheetali.png",
        color: const Color(0xFF3F2087),
      ),
      CourseInfo(
        title: "Sheetkari Pranayama",
        image: "assets/images/sheetkari.png",
        color: const Color(0xFF30117C),
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Courses",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/images/banner.png",
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xff304674),
            elevation: 0,
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final category = courseCategories.keys.elementAt(index);
                  return _buildCourseCategory(context, category);
                },
                childCount: courseCategories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCategory(BuildContext context, String category) {
    final courses = courseCategories[category]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: category == courseCategories.keys.first ? 0 : 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xff304674),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 0.9,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            return _buildModernCourseCard(context, courses[index]);
          },
        ),
      ],
    );
  }

  Widget _buildModernCourseCard(BuildContext context, CourseInfo course) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (coursePages.containsKey(course.title)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => coursePages[course.title]!()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.asset(
                      course.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                color: course.color,
              ),
              child: Text(
                course.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}