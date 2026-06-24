import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'supabase_config.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';
import 'api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initSupabase();
  runApp(const ManaCareerApp());
}

class ManaCareerApp extends StatelessWidget {
  const ManaCareerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ManaCareer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF16213B),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          if (!snapshot.hasData) {
            return const LoginScreen();
          }
          return _ProfileGate(uid: snapshot.data!.uid);
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16213B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline_rounded,
                color: Color(0xFFE2A33B), size: 52),
            SizedBox(height: 16),
            Text('ManaCareer',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFFE2A33B)),
          ],
        ),
      ),
    );
  }
}

class _ProfileGate extends StatefulWidget {
  final String uid;
  const _ProfileGate({required this.uid});

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  bool _loading = true;
  bool _profileComplete = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final profile = await ApiService.getProfile(widget.uid);
      if (mounted) {
        setState(() {
          // STRICT CHECK — must exist AND profileComplete must be exactly true
          _profileComplete =
              profile != null && profile['profileComplete'] == true;
          _loading = false;
        });
      }
    } catch (_) {
      // On ANY error, send to profile setup — never bypass to home
      if (mounted) {
        setState(() {
          _profileComplete = false;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _SplashScreen();
    if (!_profileComplete) return const ProfileSetupScreen();
    return const HomeScreen();
  }
}