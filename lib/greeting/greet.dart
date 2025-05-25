import 'package:flutter/material.dart';
import 'package:meditation_app/api_service.dart';
import 'package:meditation_app/relax.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'phone_sign_up_page.dart';

class NameInputPage extends StatefulWidget {
  const NameInputPage({Key? key}) : super(key: key);

  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSubmitting = false;
  bool _isPasswordVisible = false;
  bool _isGoogleSignIn = false;

  // Initialize animation variables with nullable types
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    );

    _animationController!.forward();

    // Set system UI style for a clean look
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isSubmitting = true;
      _isGoogleSignIn = false;
    });

    try {
      // Register user using email/password via API
      await registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Since registerUser doesn't return userId, assume login is needed to get userId
      await loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration Successful!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RelaxScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isSubmitting = true;
      _isGoogleSignIn = true;
    });

    try {
      // Start the Google sign-in process
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force account chooser
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled sign-in
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _isGoogleSignIn = false;
          });
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // Call signInWithGoogle from api_service.dart
      await signInWithGoogle(googleAuth.idToken!, googleAuth.accessToken!);

      // Optionally, store additional user data if needed
      // Since signInWithGoogle doesn't return userId, call loginUser or fetchUserProfile if needed
      final prefs = await SharedPreferences.getInstance();
      // Assuming backend stores userId in SharedPreferences during signInWithGoogle
      // If not, you may need to call an API to fetch or store user data here

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google Sign-Up Successful!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RelaxScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isGoogleSignIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F1),
      body: _fadeAnimation == null
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeAnimation!,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back Button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5D4037)),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 30),

                  // Header
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Begin your meditation journey with us",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Input Fields
                  _buildModernTextField(
                    controller: _nameController,
                    hintText: "Full Name",
                    prefixIcon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                  _buildModernTextField(
                    controller: _emailController,
                    hintText: "Email Address",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  _buildModernTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  // Register Button
                  _isSubmitting && !_isGoogleSignIn
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D4037)))
                      : _buildPrimaryButton(
                    text: "CREATE ACCOUNT",
                    onPressed: _register,
                    backgroundColor: const Color(0xFF5D4037),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey[300], thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Or sign up with",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey[300], thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Alternative Sign Up Methods
                  Row(
                    children: [
                      // Google Sign Up
                      Expanded(
                        child: _buildSocialButton(
                          text: "Google",
                          icon: Icons.g_mobiledata_rounded,
                          iconColor: Colors.red,
                          backgroundColor: Colors.white,
                          onPressed: _signUpWithGoogle,
                          isLoading: _isSubmitting && _isGoogleSignIn,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Phone Sign Up
                      Expanded(
                        child: _buildSocialButton(
                          text: "Phone",
                          icon: Icons.phone_android,
                          iconColor: const Color(0xFF1976D2),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PhoneSignUpPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Terms and Conditions
                  Center(
                    child: Text(
                      "By signing up, you agree to our Terms of Service\nand Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
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
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF5D4037),
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF5D4037),
            ),
            onPressed: onVisibilityToggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: backgroundColor.withOpacity(0.5),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: const Color(0xFF5D4037),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5D4037)),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}