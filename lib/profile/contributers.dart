import 'package:flutter/material.dart';
import 'dart:math';

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
      role: "ROLE",
      description: "Passionate about creating intuitive and visually appealing designs. Samay has 5 years of experience in mobile app development and specializes in user-centric design approaches.",
      image: "assets/images/samay.jpg",
      github: "github.com/samaypatel",
      linkedin: "linkedin.com/in/samaypatel",
    ),
    Contributor(
      name: "Umang Mishra",
      role: "ROLEr",
      description: "Experienced in building robust backend services. Umang has contributed to several open-source projects and loves solving complex architectural challenges.",
      image: "assets/images/umang.jpg",
      github: "github.com/umangmishra",
      linkedin: "linkedin.com/in/umangmishra",
    ),
    Contributor(
      name: "Monisha",
      role: "ROLE",
      description: "Expert in creating responsive and interactive user interfaces. Monisha has a strong background in web technologies and is passionate about accessibility in design.",
      image: "assets/images/monisha.jpg",
      github: "github.com/monisha",
      linkedin: "linkedin.com/in/monisha",
    ),
    Contributor(
      name: "Jayanth",
      role: "ROLE",
      description: "Skilled in coordinating team efforts and ensuring project success. Jayanth has managed multiple software development projects and excels in agile methodologies.",
      image: "assets/images/jayanth.jpg",
      github: "github.com/jayanth",
      linkedin: "linkedin.com/in/jayanth",
    ),
  ];

  int _currentIndex = 0;
  bool _showDonateSection = false;

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
      _showDonateSection = false;
      _controller.reset();
      _controller.forward();
    });
  }

  void _toggleDonateSection() {
    setState(() {
      _showDonateSection = true;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the primary and accent colors from the theme
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributors'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          // Donate button in app bar
          TextButton.icon(
            onPressed: _toggleDonateSection,
            icon: const Icon(Icons.favorite, color: Colors.red),
            label: Text(
              'Donate',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Contributors list horizontally scrollable
          Container(
            height: 150,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary,
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
              itemCount: contributors.length + 1, // +1 for donate button
              itemBuilder: (context, index) {
                // Last item is the donate button
                if (index == contributors.length) {
                  return GestureDetector(
                    onTap: _toggleDonateSection,
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
                                color: _showDonateSection
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.red.shade100,
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Donate',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: _showDonateSection
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Regular contributor items
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
                              color: _currentIndex == index && !_showDonateSection
                                  ? colorScheme.secondary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(contributors[index].image),
                            backgroundColor: colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          contributors[index].name.split(' ')[0],
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: _currentIndex == index && !_showDonateSection
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

          // Contributor or Donate details
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
              child: _showDonateSection
                  ? _buildDonateSection(context, colorScheme, theme)
                  : _buildContributorDetails(context, colorScheme, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorDetails(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image
            Hero(
              tag: contributors[_currentIndex].name,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(contributors[_currentIndex].image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name and role
            Text(
              contributors[_currentIndex].name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                contributors[_currentIndex].role,
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bio
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
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
                contributors[_currentIndex].description,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Social links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  icon: Icons.link,
                  label: 'GitHub',
                  url: contributors[_currentIndex].github,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: Icons.person,
                  label: 'LinkedIn',
                  url: contributors[_currentIndex].linkedin,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonateSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heart icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 70,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Support Our Project',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
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
                'Your donations help us continue building and improving this project. Every contribution, no matter how small, makes a big difference. Thank you for your support!',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // QR Code
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: QRCodePainter(),
                size: const Size(180, 180),
              ),
            ),
            const SizedBox(height: 20),

            // Donation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.attach_money),
                  label: const Text('Donate Now'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening donation page...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening share options...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom QR Code Painter
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 25;

    // Draw QR code cells (simplified, just for visual representation)
    final Paint blackPaint = Paint()..color = Colors.black;

    // Draw pattern finder at top left
    _drawFinderPattern(canvas, 0, 0, cellSize, blackPaint);

    // Draw pattern finder at top right
    _drawFinderPattern(canvas, size.width - 7 * cellSize, 0, cellSize, blackPaint);

    // Draw pattern finder at bottom left
    _drawFinderPattern(canvas, 0, size.height - 7 * cellSize, cellSize, blackPaint);

    // Draw alignment pattern
    _drawAlignmentPattern(canvas, size.width - 9 * cellSize, size.height - 9 * cellSize, cellSize, blackPaint);

    // Draw timing patterns
    for (int i = 8; i < 17; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(i * cellSize, 6 * cellSize, cellSize, cellSize),
          blackPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(6 * cellSize, i * cellSize, cellSize, cellSize),
          blackPaint,
        );
      }
    }

    // Draw random data cells for visual effect
    final Random random = Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 25; i++) {
      for (int j = 0; j < 25; j++) {
        // Skip areas where finder patterns are located
        if ((i < 7 && j < 7) ||
            (i < 7 && j > 17) ||
            (i > 17 && j < 7)) {
          continue;
        }

        // Draw random cells with 40% probability
        if (random.nextDouble() < 0.4) {
          canvas.drawRect(
            Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
            blackPaint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double cellSize, Paint paint) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7),
      paint,
    );

    // White middle square
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5),
      Paint()..color = Colors.white,
    );

    // Inner black square
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize * 2, y + cellSize * 2, cellSize * 3, cellSize * 3),
      paint,
    );
  }

  void _drawAlignmentPattern(Canvas canvas, double x, double y, double cellSize, Paint paint) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(x, y, cellSize * 5, cellSize * 5),
      paint,
    );

    // White middle square
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 3, cellSize * 3),
      Paint()..color = Colors.white,
    );

    // Inner black square
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize * 2, y + cellSize * 2, cellSize, cellSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  final String image;
  final String github;
  final String linkedin;

  Contributor({
    required this.name,
    required this.role,
    required this.description,
    required this.image,
    required this.github,
    required this.linkedin,
  });
}

// Additional import needed for the QR code's random pattern
