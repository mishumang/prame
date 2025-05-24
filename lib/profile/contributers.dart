import 'package:flutter/material.dart';
import 'dart:math';

// Custom Color Theme
class AppColors {
  static const Color primary = Color(0xFF4DB6AC); // Green accent color from the flower button
  static const Color primaryLight = Color(0xFF009688);
  static const Color primaryDark = Color(0xFF4DB6AC);
  static const Color background = Color(0xFFF0F4F8);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);

  // Additional colors for avatar backgrounds
  static const List<Color> avatarColors = [
    Color(0xFF4DB6AC),
    Color(0xFF26A69A),
    Color(0xFF00897B),
    Color(0xFF00796B),
  ];
}

class ContributorsPage extends StatefulWidget {
  const ContributorsPage({Key? key}) : super(key: key);

  @override
  _ContributorsPageState createState() => _ContributorsPageState();
}

class _ContributorsPageState extends State<ContributorsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Contributor> contributors = [
    Contributor(
      name: "Samay Patel",
      role: "Project Associate",
      description: "Samay Patel served as the central figure in the project, leading the team as the Project Associate at the Indian Institute of Science (IISc). With a keen eye for both detail and strategy, he overlooked the entire project lifecycle, from conceptualization to deployment. Samay ensured that all modules were effectively coordinated, deadlines were met, and the project adhered to the intended vision and technical specifications. His leadership facilitated smooth communication between the frontend, backend, and integration teams, driving the project towards successful completion.",
      github: "https://github.com/samay-patel-2110",
      linkedin: "https://www.linkedin.com/in/samay-p-6a4084126",
    ),
    Contributor(
      name: "Umang Mishra",
      role: "Full Stack Developer",
      description: "Umang Mishra brought versatility to the team, working extensively on both frontend and backend development. Her primary focus was on implementing secure authentication mechanisms, ensuring data protection and user privacy throughout the application. Simultaneously, she worked on integrating frontend components with backend logic, managing data flow between the client and server, and implementing essential business logic. Umang's ability to work across both domains was instrumental in maintaining consistency and resolving technical challenges effectively.",
      github: "github.com/mishumang",
      linkedin: "https://www.linkedin.com/in/umang-mishra-932123290/",
    ),
    Contributor(
      name: "Monisha Prabhu",
      role: "Full Stack Developer ",
      description: "Monisha Prabhu handled the backend development, focusing on database management, server-side logic, and data processing. Utilizing MongoDB, she structured the database architecture to ensure optimal data flow and efficient querying. Additionally, Monisha managed the deployment of backend services on AWS, integrating cloud functionalities such as server management, data storage, and security protocols. Her contributions ensured that the application remained robust, scalable, and capable of handling extensive data operations effectively.",
      github: "github.com/monisha",
      linkedin: "linkedin.com/in/monisha",
    ),
    Contributor(
      name: "Jayanth",
      role: "Full Stack Developer",
      description: "Jayanth played a crucial role in shaping the user experience of the application. He was responsible for designing a user-centric interface that was not only visually appealing but also functionally intuitive. Focusing on frontend development, Jayanth integrated key UI elements and ensured that the application's design was consistent and accessible across all platforms. His work involved implementing responsive layouts, managing component architecture, and aligning the frontend with backend services for a seamless user experience.",
      github: "github.com/jayanth",
      linkedin: "linkedin.com/in/jayanth",
    ),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContributorTap(int index) {
    setState(() {
      _currentIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  // Generate a consistent color for each contributor based on their name
  Color getContributorColor(String name) {
    // Simple hash function to get a consistent index
    int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return AppColors.avatarColors[hash % AppColors.avatarColors.length];
  }

  // Get the initials of a person's name
  String getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Use the custom AppColors instead of theme colors
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Contributors'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Contributors list horizontally scrollable
          Container(
            height: 150,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: contributors.length,
              itemBuilder: (context, index) {
                // Regular contributor items with initials instead of images
                final contributor = contributors[index];
                final color = getContributorColor(contributor.name);
                final initials = getInitials(contributor.name);

                return GestureDetector(
                  onTap: () => _onContributorTap(index),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: color,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          contributor.name.split(' ')[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: _currentIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Contributor details
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _controller,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                );
              },
              child: _buildContributorDetails(context, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorDetails(BuildContext context, ThemeData theme) {
    final contributor = contributors[_currentIndex];
    final color = getContributorColor(contributor.name);

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name and role (removed the large avatar circle)
            Text(
              contributor.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                contributor.role,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bio
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                contributor.description,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Social links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  icon: Icons.code,
                  label: 'GitHub',
                  url: contributor.github,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: Icons.business,
                  label: 'LinkedIn',
                  url: contributor.linkedin,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        // Add URL launching logic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $url')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
      ),
    );
  }
}

class Contributor {
  final String name;
  final String role;
  final String description;
  final String github;
  final String linkedin;

  Contributor({
    required this.name,
    required this.role,
    required this.description,
    required this.github,
    required this.linkedin,
  });
}