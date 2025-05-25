import 'package:flutter/material.dart';
import 'package:meditation_app/greeting/login_page.dart';
import 'package:meditation_app/progress/graph.dart';
import 'utils/routes.dart';
import 'relax.dart'; // Your home screen (when logged in)
import 'package:shared_preferences/shared_preferences.dart'; // For local tracking


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
    _logDailyUsage();
  }

  @override
  void dispose() {
    _logSessionTime();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _logSessionTime();
    } else if (state == AppLifecycleState.resumed) {
      _sessionStart = DateTime.now();
      _logDailyUsage();
    }
  }

  Future<void> _logSessionTime() async {
    if (_sessionStart == null) return;

    // Check if a user is logged in via SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null || userId.isEmpty) return;
    final uid = userId;

    final sessionEnd = DateTime.now();
    final sessionDuration = sessionEnd.difference(_sessionStart!);

    final totalUsageKey = 'total_usage_seconds_$uid';
    int totalSeconds = prefs.getInt(totalUsageKey) ?? 0;
    totalSeconds += sessionDuration.inSeconds;
    await prefs.setInt(totalUsageKey, totalSeconds);

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dailyUsageKey = "usage_${uid}_$today";
    int dailySeconds = prefs.getInt(dailyUsageKey) ?? 0;
    dailySeconds += sessionDuration.inSeconds;
    await prefs.setInt(dailyUsageKey, dailySeconds);

    print('Logged session of ${sessionDuration.inSeconds} seconds. Total usage: $totalSeconds seconds.');
  }

  Future<void> _logDailyUsage() async {
    // Check if a user is logged in via SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null || userId.isEmpty) return;
    final uid = userId;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final daysUsedKey = 'days_used_$uid';
    List<String> daysUsed = prefs.getStringList(daysUsedKey) ?? [];

    if (!daysUsed.contains(today)) {
      daysUsed.add(today);
      await prefs.setStringList(daysUsedKey, daysUsed);
      print('New day logged: $today');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Breathing Techniques App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthWrapper(),
        '/login': (context) => LoginPage(),
        '/relax': (context) => RelaxScreen(),
        '/progress': (context) => ProgressScreen(),
        ...AppRoutes.routes,
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper: Waiting for login status, showing loading indicator');
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data == true) {
          print('AuthWrapper: User is logged in, redirecting to /relax');
          return RelaxScreen();
        }
        print('AuthWrapper: User is not logged in, redirecting to /login');
        return LoginPage();
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final isLoggedIn = userId != null && userId.isNotEmpty;
    print('AuthWrapper: Checked login status, userId: $userId, isLoggedIn: $isLoggedIn');
    return isLoggedIn;
  }
}