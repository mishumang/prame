import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

// Use a consistent baseUrl (adjust to your setup)
const String baseUrl = 'http://10.0.2.2:3000/api/users';

Future<void> registerUser(String name, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Registration failed with status: ${response.statusCode}');
      throw Exception('Failed to register: ${response.body}');
    }
  } catch (e) {
    print('Error in registerUser: $e');
    rethrow;
  }
}

Future<void> signInWithGoogle(String idToken, String accessToken) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/google-signin'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'idToken': idToken,
        'accessToken': accessToken,
      }),
    );

    if (response.statusCode != 200) {
      print('Google Sign-In failed with status: ${response.statusCode}');
      throw Exception('Google Sign-In failed: ${response.body}');
    }
  } catch (e) {
    print('Error in signInWithGoogle: $e');
    rethrow;
  }
}

Future<void> sendOTP(String phone) async {
  final url = Uri.parse('$baseUrl/send-otp');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"phone": phone}),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to send OTP');
  }
}

Future<bool> verifyOTP(String phone, String otp) async {
  final url = Uri.parse('$baseUrl/verify-otp');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"phone": phone, "otp": otp}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['success'] == true;
  } else {
    throw Exception('Failed to verify OTP');
  }
}

Future<void> registerWithPhone({
  required String phone,
  required String name,
  required String password,
}) async {
  final url = Uri.parse('$baseUrl/registerPhone');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "phone": phone,
      "name": name,
      "password": password,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Registration failed');
  }
}


Future<void> loginUser(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String userId = data['userId'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
    } else {
      print('Login failed with status: ${response.statusCode}');
      throw Exception('Login failed: ${response.body}');
    }
  } catch (e) {
    print('Error in loginUser: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Fetch profile failed with status: ${response.statusCode}');
      throw Exception('Failed to fetch user profile: ${response.body}');
    }
  } catch (e) {
    print('Error in fetchUserProfile: $e');
    rethrow;
  }
}

Future<void> updateProgresses(String uid, Map<String, dynamic> progressData) async {
  print('updateProgress function called'); // Debug print
  final url = Uri.parse('$baseUrl/updateProgress');
  print('Sending request to: $url');
  print('UID: $uid, ProgressData: $progressData');

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "uid": uid,
        "progressData": progressData,
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to update progress: ${response.body}");
    }
  } catch (e) {
    print("Caught error in updateProgress: $e");
    rethrow;
  }
}

Future<Map<String, Map<String, dynamic>>> fetchProgressData(String uid) async {
  final url = Uri.parse('$baseUrl/progress/$uid');
  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    return data.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
  } else {
    throw Exception("Failed to fetch progress: ${response.body}");
  }
}

Future<String?> uploadProfileImage(String userId, File imageFile) async {
  final request =
  http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/$userId'));
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['imageUrl']; // Ensure your backend returns the new URL as imageUrl.
  } else {
    throw Exception('Failed to upload profile image');
  }
}

// Update the user profile.
// This function sends the new name, email, phone, and profileImageUrl (if provided)
// to the backend, which is expected to update the user data in the database.
Future<void> updateUserProfile({
  required String userId,
  required String name,
  String? email,
  String? phone,
  // String? profileImageUrl,
}) async {
  final url = Uri.parse('$baseUrl/update/$userId');
  final Map<String, dynamic> body = {
    "name": name,
  };

  // Add the email, phone, and profileImageUrl only if they are provided.
  if (email != null) {
    body["email"] = email;
  }
  if (phone != null) {
    body["phone"] = phone;
  }
  // if (profileImageUrl != null) {
  //   body["profileImageUrl"] = profileImageUrl;
  // }

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update user profile');
  }
}