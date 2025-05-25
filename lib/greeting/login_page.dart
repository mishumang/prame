import 'package:flutter/material.dart';
import 'package:meditation_app/api_service.dart';
import 'package:meditation_app/greeting/greet.dart';
import 'package:meditation_app/relax.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // Set system UI style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Comment out the auto-login check as per original code
    // _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() async {
    // Check if userId is stored in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RelaxScreen()),
      );
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isSubmitting = true);
    try {
      await loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RelaxScreen()),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failed: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  void _skipToRelaxScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RelaxScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // App Logo and Header
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/yoga_app.jpg',
                            fit: BoxFit.cover,
                            width: 130,
                            height: 130,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Welcome Text
                  const Center(
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Login to continue your meditation journey",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email Field
                  _buildInputContainer(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF009688),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildInputContainer(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF009688),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF009688),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _skipToRelaxScreen,
                        child: const Text(
                          "Skip Login",
                          style: TextStyle(
                            color: Color(0xFF26A69A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Add forgot password logic here
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF26A69A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Login Button
                  _isSubmitting
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FD7F)))
                      : _buildGradientButton(
                    onPressed: _handleLogin,
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // OR Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Social Login Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialLoginButton(
                        icon: Icons.g_mobiledata_rounded,
                        backgroundColor: Colors.red[50]!,
                        iconColor: Colors.red,
                        onPressed: () {
                          // Add Google login logic using signInWithGoogle
                          // Requires google_sign_in package
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildSocialLoginButton(
                        icon: Icons.facebook_rounded,
                        backgroundColor: Colors.blue[50]!,
                        iconColor: Colors.blue,
                        onPressed: () {
                          // Add Facebook login logic (not provided in API)
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildSocialLoginButton(
                        icon: Icons.apple_rounded,
                        backgroundColor: Colors.grey[200]!,
                        iconColor: Colors.black,
                        onPressed: () {
                          // Add Apple login logic (not provided in API)
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Sign Up Option
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NameInputPage()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: Color(0xFF26A69A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF0050FD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 30,
        ),
      ),
    );
  }
}