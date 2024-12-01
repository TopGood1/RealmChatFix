import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  final bool isEmailVerification;

  const OtpScreen({super.key, required this.isEmailVerification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('A verification email has been sent to your email.'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
