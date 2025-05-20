import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation_app/courses/abdominal_breathing_page.dart';
import 'package:meditation_app/courses/bhramari_pranayama_page.dart';
import 'package:meditation_app/greeting/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contributers.dart';
import 'donate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: MeditationApp(),
    theme: ThemeData(
      fontFamily: 'Poppins',
      primaryColor: const Color(0xff00695c), // Pastel blue
      scaffoldBackgroundColor: const Color(0xffF1FAEE), // Pastel cream
      appBarTheme: const AppBarTheme(
        color: Color(0xff00695c), // Pastel dark blue
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
  ));
}

class MeditationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeditationProfile(),
    );
  }
}

class MeditationProfile extends StatefulWidget {
  @override
  _MeditationProfileState createState() => _MeditationProfileState();
}

class _MeditationProfileState extends State<MeditationProfile> {
  int meditationSessions = 0;
  double totalMeditationTime = 0.0;
  String userName = "User Name";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          userName = doc.get('name') ?? 'User Name';
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // App's color palette
    final Color primaryBlue = const Color(0xff457B9D);
    final Color lightBlue = const Color(0xffA8DADC);
    final Color creamBg = const Color(0xffF1FAEE);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Meditation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryBlue.withOpacity(0.95),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, size: 24),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              creamBg.withOpacity(0.9),
              creamBg,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildProfileHeader(primaryBlue, lightBlue),
                  SizedBox(height: 24),
                  _buildMeditationStats(primaryBlue, lightBlue),
                  SizedBox(height: 24),
                  _buildSectionHeader('Recent Achievements', Icons.emoji_events_rounded, primaryBlue),
                  SizedBox(height: 12),
                  _buildAchievementList(primaryBlue),
                  SizedBox(height: 24),
                  _buildNavigationCards(primaryBlue, lightBlue, context),
                  SizedBox(height: 32), // Bottom padding for scrolling comfort
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color primaryBlue, Color lightBlue) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            lightBlue.withOpacity(0.7),
            lightBlue.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: primaryBlue,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Meditation Enthusiast',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: primaryBlue.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationStats(Color primaryBlue, Color lightBlue) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 16.0),
            child: Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                title: 'Sessions',
                value: '$meditationSessions',
                icon: Icons.repeat_rounded,
                primaryBlue: primaryBlue,
                lightBlue: lightBlue,
              ),
              _buildStatCard(
                title: 'Total Time',
                value: '${totalMeditationTime.toStringAsFixed(1)} min',
                icon: Icons.timer_rounded,
                primaryBlue: primaryBlue,
                lightBlue: lightBlue,
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color primaryBlue,
    required Color lightBlue,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              lightBlue.withOpacity(0.3),
              lightBlue.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: primaryBlue.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color primaryBlue) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryBlue,
          size: 22,
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementList(Color primaryBlue) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 40,
              color: primaryBlue.withOpacity(0.3),
            ),
            SizedBox(height: 12),
            Text(
              'No achievements unlocked yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: primaryBlue.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Keep meditating to earn rewards!',
              style: TextStyle(
                fontSize: 13,
                color: primaryBlue.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCards(Color primaryBlue, Color lightBlue, BuildContext context) {
    return Column(
      children: [
        _buildNavCard(
          title: 'Donate',
          subtitle: 'Support Yoga Mandir\'s charitable mission',
          icon: Icons.volunteer_activism,
          primaryBlue: primaryBlue,
          lightBlue: lightBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DonatePage()),
            );
          },
        ),
        SizedBox(height: 16),
        _buildNavCard(
          title: 'View Favorite Courses',
          subtitle: 'Access your saved meditation practices',
          icon: Icons.favorite_rounded,
          primaryBlue: primaryBlue,
          lightBlue: lightBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritesPage()),
            );
          },
        ),
        // The rest of your navigation cards remain unchanged
        SizedBox(height: 16),
        _buildNavCard(
          title: 'About Us',
          subtitle: 'Learn about Yoga Mandir, Bengaluru',
          icon: Icons.info_outline_rounded,
          primaryBlue: primaryBlue,
          lightBlue: lightBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutUsPage()),
            );
          },
        ),
        SizedBox(height: 16),
        _buildNavCard(
          title: 'Contributors',
          subtitle: 'Meet the team behind the app',
          icon: Icons.people_outline_rounded,
          primaryBlue: primaryBlue,
          lightBlue: lightBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContributorsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryBlue,
    required Color lightBlue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              lightBlue.withOpacity(0.6),
              lightBlue.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryBlue,
                size: 26,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: primaryBlue.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // App's color scheme
    final Color primaryBlue = const Color(0xff457B9D);
    final Color lightBlue = const Color(0xffA8DADC);
    final Color cream = const Color(0xffF1FAEE);
    final Color accentRed = const Color(0xffE63946);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom app bar with parallax effect
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About Us',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/yoga_banner.jpeg', // Add this image to your assets
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue, lightBlue],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          primaryBlue.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: cream,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and mission statement
                  _buildLogoSection(context, lightBlue, primaryBlue),

                  // Our story
                  _buildStorySection(context, primaryBlue, lightBlue),

                  // SURYA Program
                  _buildProgramSection(context, 'SURYA Program',
                      'Student Upliftment and Rejuvenation through Yoga',
                      Icons.school, primaryBlue, lightBlue),

                  // PRAME App
                  _buildProgramSection(context, 'PRAME App',
                      'Bringing ancient wisdom to the digital age',
                      Icons.smartphone, primaryBlue, lightBlue),

                  // Our Philosophy
                  _buildPhilosophySection(context, primaryBlue, lightBlue, accentRed),

                  // Founder section
                  _buildFounderSection(context, primaryBlue, lightBlue),

                  // Get in touch
                  _buildContactSection(context, primaryBlue, lightBlue, accentRed),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    color: primaryBlue,
                    child: Center(
                      child: Text(
                        '© 2025 Yoga Mandir, Bengaluru - All Rights Reserved',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context, Color lightBlue, Color primaryBlue) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Logo animation
          TweenAnimationBuilder(
            duration: Duration(seconds: 1),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/yoga_logo.png', // Add a circular logo image
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.spa, size: 60, color: primaryBlue),
                          Icon(Icons.waterfall_chart, size: 80, color: primaryBlue.withOpacity(0.3)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Yoga Mandir, Bengaluru',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Est. 1989',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: primaryBlue.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: lightBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lightBlue, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  'A registered charitable trust dedicated to promoting yoga as a holistic path to physical, mental, and spiritual well-being.',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Image.asset(
                  'assets/images/yoga_group.jpeg', // Add an image showing a yoga class or community
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(height: 0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, Color primaryBlue, Color lightBlue) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: primaryBlue, size: 28),
              SizedBox(width: 12),
              Text(
                'Our Story',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Established in 1989 by Yogaratna Dr. S N Omkar, Yoga Mandir has been a beacon of authentic yoga practice and teaching in Bengaluru for over three decades.',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryBlue.withOpacity(0.8),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/yoga_history.jpeg', // Add an historical image
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: 100,
                            color: lightBlue.withOpacity(0.3),
                            child: Icon(Icons.history, color: primaryBlue),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Image.asset(
                  'assets/images/yoga_centre.jpeg', // Add an image of the center
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: lightBlue.withOpacity(0.2),
                      child: Center(
                        child: Icon(Icons.image_not_supported, color: primaryBlue),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                Text(
                  'From its humble beginnings, it has grown into a respected institution that has touched thousands of lives through its dedication to the ancient practice of yoga.',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryBlue.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSection(BuildContext context, String title, String subtitle, IconData icon, Color primaryBlue, Color lightBlue) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightBlue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryBlue, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: primaryBlue.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Image.asset(
            title == 'SURYA Program'
                ? 'assets/images/yoga_students.jpeg' // Image of students practicing yoga
                : 'assets/images/yoga_app.jpg', // Image of app or digital yoga
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 120,
                color: lightBlue.withOpacity(0.2),
                child: Center(
                  child: Icon(
                    title == 'SURYA Program' ? Icons.groups : Icons.devices,
                    color: primaryBlue,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          if (title == 'SURYA Program')
            Text(
              'Our flagship program nurtures young minds through Patanjali-inspired teachings, promoting holistic development and well-being among students.',
              style: TextStyle(
                fontSize: 16,
                color: primaryBlue.withOpacity(0.8),
              ),
            )
          else
            Text(
              'The PRAME app is our initiative to bring the timeless wisdom of yoga to the digital age, making authentic practices accessible to everyone, anywhere.',
              style: TextStyle(
                fontSize: 16,
                color: primaryBlue.withOpacity(0.8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhilosophySection(BuildContext context, Color primaryBlue, Color lightBlue, Color accentRed) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: primaryBlue, size: 28),
              SizedBox(width: 12),
              Text(
                'Our Philosophy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightBlue.withOpacity(0.3), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/yoga_lotus.png', // Add an image of lotus flower
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: lightBlue.withOpacity(0.2),
                        child: Center(
                          child: Icon(Icons.spa, color: primaryBlue, size: 40),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '"Like a lotus leaf remains untouched by water, one should act without attachment."',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '— Bhagavad Gita 5.10',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'Our logo symbolizes a drop of water blooming through yoga and pranayama, representing the core philosophy that guides our practice.',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryBlue.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 24),

                // Core values with interactive elements
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCoreValueItem(context, 'Focus', Icons.lightbulb, primaryBlue, lightBlue),
                    _buildCoreValueItem(context, 'Devotion', Icons.volunteer_activism, primaryBlue, lightBlue),
                    _buildCoreValueItem(context, 'Compassion', Icons.favorite, primaryBlue, accentRed),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreValueItem(BuildContext context, String title, IconData icon, Color primaryBlue, Color backgroundColor) {
    String imagePath = title == 'Focus'
        ? 'assets/images/yoga_focus.jpg'
        : title == 'Devotion'
        ? 'assets/images/yoga_devotion.jpg'
        : 'assets/images/yoga_compassion.jpg';

    return InkWell(
      onTap: () {
        // Show a tooltip or description when tapped
        final snackBar = SnackBar(
          content: Text(
            title == 'Focus' ? 'The diya represents focus and mental clarity.'
                : title == 'Devotion' ? 'The folded hands symbolize devotion and surrender.'
                : 'The heart embodies compassion and love for all beings.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: primaryBlue,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(icon, color: primaryBlue, size: 24);
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFounderSection(BuildContext context, Color primaryBlue, Color lightBlue) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: lightBlue,
            backgroundImage: AssetImage('assets/images/founder.jpeg'),
            onBackgroundImageError: (exception, stackTrace) {
              // Placeholder if image fails to load
            },
            child: ClipOval(
              child: Image.asset(
                'assets/images/founder.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: 60, color: primaryBlue);
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Yogaratna Dr. S N Omkar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Founder',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: primaryBlue.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/founder_teaching.jpeg', // Image of founder teaching
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox();
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Under Dr. Omkar\'s guidance, Yoga Mandir remains a beacon of authentic yoga, fostering personal growth and community upliftment through the timeless wisdom of yoga practices.',
            style: TextStyle(
              fontSize: 16,
              color: primaryBlue.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, Color primaryBlue, Color lightBlue, Color accentRed) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get In Touch',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/yoga_building.jpeg', // Image of the yoga center building
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: lightBlue.withOpacity(0.2),
                        child: Center(
                          child: Icon(Icons.location_on, color: primaryBlue, size: 40),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                _buildContactItem(Icons.location_on, 'Yoga Mandir, Bengaluru', primaryBlue),
                Divider(color: lightBlue.withOpacity(0.5)),
                _buildContactItem(Icons.email, 'info@yogamandir.org', primaryBlue),
                Divider(color: lightBlue.withOpacity(0.5)),
                _buildContactItem(Icons.phone, '+91 9876543210', primaryBlue),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialMediaIcon(context, Icons.facebook, primaryBlue),
                    _buildSocialMediaIcon(context, Icons.camera_alt, primaryBlue),
                    _buildSocialMediaIcon(context, Icons.telegram, primaryBlue),
                    _buildSocialMediaIcon(context, Icons.whatshot, primaryBlue),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    const url = 'https://docs.google.com/forms/d/e/1FAIpQLSeFmPPfJqqb3NPP4f0JHQSMOM0Z0WHRd6Ubbl3sRHlL9w-lfg/viewform'; // replace with your actual GForm link
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open the feedback form'))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentRed,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Feedback form!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: primaryBlue.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon(BuildContext context, IconData icon, Color primaryBlue) {
    return InkWell(
      onTap: () {
        // Handle social media tap
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Follow us on social media!'))
        );
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryBlue, size: 20),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> favoriteCourses = [];
  bool _isLoading = true;
  String currentUserId = 'guest';

  // List of all possible courses.
  final List<String> allCourses = [
    "Abdominal Breathing",
    "Chest Breathing",
    "Complete Breathing",
    "Bhramari Pranayama",
    "Nadi Shodhana Pranayama",
    "Ujjayi Pranayama",
    "Surya Bhedana Pranayama",
    "Chandra Bhedana Pranayama",
    "Sheetali Pranayama",
    "Sheetkari Pranayama",
  ];

  // Mapping of course names to their respective pages.
  final Map<String, WidgetBuilder> coursePages = {
    "Abdominal Breathing": (context) => AbdominalBreathingLearnMorePage(),
    "Chest Breathing": (context) => CoursePage(title: "Chest Breathing"),
    "Complete Breathing": (context) => CoursePage(title: "Complete Breathing"),
    "Bhramari Pranayama": (context) => BhramariBreathingLearnMorePage(),
    "Nadi Shodhana Pranayama": (context) => CoursePage(title: "Nadi Shodhana Pranayama"),
    "Ujjayi Pranayama": (context) => CoursePage(title: "Ujjayi Pranayama"),
    "Surya Bhedana Pranayama": (context) => CoursePage(title: "Surya Bhedana Pranayama"),
    "Chandra Bhedana Pranayama": (context) => CoursePage(title: "Chandra Bhedana Pranayama"),
    "Sheetali Pranayama": (context) => CoursePage(title: "Sheetali Pranayama"),
    "Sheetkari Pranayama": (context) => CoursePage(title: "Sheetkari Pranayama"),
  };
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUserId = user?.uid ?? 'guest';
    _loadFavoriteCourses();
  }

  // Helper: Generate the key used for a course's favorite status.
  String _favoriteKey(String courseTitle) {
    return "favorite_" +
        courseTitle.toLowerCase().replaceAll(" ", "_") +
        "_$currentUserId";
  }

  Future<void> _loadFavoriteCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tempFavorites = [];
    for (String course in allCourses) {
      bool isFav = prefs.getBool(_favoriteKey(course)) ?? false;
      if (isFav) {
        tempFavorites.add(course);
      }
    }
    setState(() {
      favoriteCourses = tempFavorites;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Courses'),
        backgroundColor: const Color(0xff457B9D),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteCourses.isEmpty
          ? Center(
        child: Text(
          'No favorite courses added yet.',
          style: TextStyle(color: const Color(0xff457B9D)),
        ),
      )
          : ListView.builder(
        itemCount: favoriteCourses.length,
        itemBuilder: (context, index) {
          String course = favoriteCourses[index];
          return ListTile(
            leading: Icon(Icons.spa, color: const Color(0xffA8DADC)), // Pastel blue
            title: Text(course, style: TextStyle(color: const Color(0xff457B9D))),
            trailing: Icon(Icons.arrow_forward_ios, color: const Color(0xff457B9D)),
            onTap: () {
              if (coursePages.containsKey(course)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: coursePages[course]!),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Page not available")));
              }
            },
          );
        },
      ),
    );
  }
}

class CoursePage extends StatelessWidget {
  final String title;
  const CoursePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xff457B9D),
      ),
      body: Center(
        child: Text(
          "This is the page for $title",
          style: TextStyle(color: const Color(0xff457B9D)),
        ),
      ),
    );
  }
}