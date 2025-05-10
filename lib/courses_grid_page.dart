import 'package:flutter/material.dart';

// Import your dedicated course pages (if needed elsewhere):
import 'courses/abdominal_breathing_page.dart';
import 'courses/chest_breathing_page.dart';
import 'courses/complete_breathing_page.dart';
import 'courses/bhramari_pranayama_page.dart';
import 'courses/nadi_shodhana_pranayama_page.dart';
import 'courses/ujjayi_pranayama_page.dart';
import 'courses/surya_bhedana_pranayama_page.dart';
import 'courses/chandra_bhedana_pranayama_page.dart';
import 'courses/sheetali_pranayama_page.dart';
import 'courses/sheetkari_pranayama_page.dart';

class CoursesGridPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> courses;
  final Map<String, Widget Function()> coursePages;

  const CoursesGridPage({
    Key? key,
    required this.title,
    required this.courses,
    required this.coursePages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: courses.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // two items per row
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final course = courses[index];
          return GestureDetector(
            onTap: () {
              final courseTitle = course["title"];
              if (courseTitle != null && coursePages.containsKey(courseTitle)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => coursePages[courseTitle]!()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No page found for $courseTitle")),
                );
              }
            },
            child: Stack(
              children: [
                // Background Image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(course["image"]!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient Overlay for better readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Course Title
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Text(
                    course["title"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
