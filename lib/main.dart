import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realmchat/screen/forgotpassword.dart';
import 'package:realmchat/screen/home.dart';
import 'package:realmchat/screen/login.dart';
import 'package:realmchat/screen/register.dart';
import 'package:realmchat/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Map<int, Color> color = {
  50: const Color.fromRGBO(65, 179, 162, .1),
  100: const Color.fromRGBO(65, 179, 162, .2),
  200: const Color.fromRGBO(65, 179, 162, .3),
  300: const Color.fromRGBO(65, 179, 162, .4),
  400: const Color.fromRGBO(65, 179, 162, .5),
  500: const Color.fromRGBO(65, 179, 162, .6),
  600: const Color.fromRGBO(65, 179, 162, .7),
  700: const Color.fromRGBO(65, 179, 162, .8),
  800: const Color.fromRGBO(65, 179, 162, .9),
  900: const Color.fromRGBO(65, 179, 162, 1),
};

MaterialColor customSwatch = MaterialColor(0xFF41B3A2, color);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe) {
      return '/home';
    }
    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RealmChat',
      theme: ThemeData(
        primarySwatch: customSwatch,
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const SplashScreen(),
        '/home': (context) => const MainScreen(),
        '/register': (context) => const Register(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Page Not Found")),
            body: const Center(child: Text("Page not found!")),
          ),
        );
      },
    );
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}