import 'dart:async';
import 'package:flutter/material.dart';
import 'package:realmchat/screen/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //Membuat Durasi Loading Screen
    Timer(const Duration(seconds: 3), () {
      //Menavigasikan splashscreen mengarah ke halaman login setelah 3 detik
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/RealmChat_LoadingIcons.png',
                height: 300, width: 250),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), //indikator loading
          ],
        )));
  }
}
