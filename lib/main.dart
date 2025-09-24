import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ถ้าคุณรัน flutterfire configure แล้ว ให้เปิดบรรทัดนี้และใช้ DefaultFirebaseOptions
// import 'firebase_options.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'habit_tracker_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Firebase Status',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('th', ''), Locale('en', '')],
      home: const AuthGate(),
      routes: {
        '/home': (context) => const HomePage(),
        '/habit-tracker': (context) => const HabitTrackerPage(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  bool _showRegister = false;

  void _toggle() => setState(() => _showRegister = !_showRegister);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (user == null) {
          return _showRegister
              ? RegisterPage(onGoToLogin: _toggle)
              : LoginPage(onGoToRegister: _toggle);
        }
        return const HomePage();
      },
    );
  }
}
