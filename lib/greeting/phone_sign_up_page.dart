import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation_app/relax.dart';

class PhoneSignUpPage extends StatefulWidget {
  const PhoneSignUpPage({Key? key}) : super(key: key);

  @override
  _PhoneSignUpPageState createState() => _PhoneSignUpPageState();
}

class _PhoneSignUpPageState extends State<PhoneSignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _verificationId;
  int _currentStep = 1; // 1: Phone input, 2: Code verification, 3: Name & password input
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Step 1: Send the SMS code
  void _sendCode() async {
    setState(() => _isSubmitting = true);
    String phone = _phoneController.text.trim();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // For auto-verification on supported devices
        try {
          await _auth.signInWithCredential(credential);
          setState(() {
            _currentStep = 3;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Auto verification failed: ${e.toString()}')),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _currentStep = 2;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
    setState(() => _isSubmitting = false);
  }

  // Step 2: Verify the SMS code entered by the user
  void _verifyCode() async {
    setState(() => _isSubmitting = true);
    String code = _codeController.text.trim();
    if (_verificationId != null) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      try {
        await _auth.signInWithCredential(credential);
        setState(() {
          _currentStep = 3;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid code. Please try again.')),
        );
      }
    }
    setState(() => _isSubmitting = false);
  }

  // Step 3: Ask for the user's name and password to complete registration
  void _completeSignUp() async {
    setState(() => _isSubmitting = true);
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();
    String phone = _phoneController.text.trim();

    // Create a dummy email from the phone number (strip non-digits)
    String sanitizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    String dummyEmail = '$sanitizedPhone@myapp.com';

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Link the email/password provider to the phone-authenticated user
        AuthCredential emailCredential = EmailAuthProvider.credential(
          email: dummyEmail,
          password: password,
        );
        await user.linkWithCredential(emailCredential);

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'phone': phone,
          'createdAt': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );

        // Navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RelaxScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing registration: ${e.toString()}')),
      );
    }
    setState(() => _isSubmitting = false);
  }

  Widget _buildPhoneInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: "Phone Number",
            hintText: "+1234567890",
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _sendCode,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Send Code"),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            labelText: "Verification Code",
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _verifyCode,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Verify Code"),
        ),
      ],
    );
  }

  Widget _buildUserInfoInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Name",
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _completeSignUp,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Complete Sign Up"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_currentStep == 1) {
      content = _buildPhoneInput();
    } else if (_currentStep == 2) {
      content = _buildCodeInput();
    } else {
      content = _buildUserInfoInput();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up with Phone")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: content),
      ),
    );
  }
}
