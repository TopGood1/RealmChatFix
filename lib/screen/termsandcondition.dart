import 'package:flutter/material.dart';
import 'package:realmchat/main.dart';

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
              "Terms & Condition",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: customSwatch,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Terms & Condition",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  )),
              SizedBox(height: 10),
              Text(
                "Welcome to RealmChat! These Terms and Conditions (\"Terms\") govern your use of the RealmChat real-time chat application (\"the App\"). By using the App, you agree to comply with these Terms. If you do not agree with any of these Terms, please do not use the App.\n\n"
                "1. Use of the App\n"
                "- You must be at least 13 years old to use RealmChat. If you are under 13, you are not permitted to use the App.\n"
                "- You are responsible for all activities that occur under your account.\n"
                "- You agree to use the App only for lawful purposes and in a way that does not infringe on the rights of, restrict, or inhibit anyone else's use and enjoyment of the App.\n\n"
                "2. Account Security\n"
                "- You are responsible for maintaining the confidentiality of your account and password.\n"
                "- You agree to notify us immediately of any unauthorized access to or use of your account.\n\n"
                "3. Content Ownership and Responsibility\n"
                "- You retain ownership of the content you share via the App. However, by using the App, you grant us a non-exclusive, worldwide, royalty-free license to use, store, and share your content as needed to operate the App.\n"
                "- We do not monitor all content shared in the App but reserve the right to remove any content that violates these Terms.\n\n"
                "4. Prohibited Activities\n"
                "- You agree not to use the App for any illegal, fraudulent, or harmful activity, including, but not limited to, distributing viruses or harmful code, harassment, spamming, or phishing.\n"
                "- You must not reverse engineer, decompile, or disassemble any part of the App.\n\n"
                "5. Termination\n"
                "- We reserve the right to terminate or suspend your access to the App at any time, without notice, for any reason, including if we believe that you have violated these Terms.\n\n"
                "6. Disclaimer of Warranties\n"
                "- The App is provided \"as is\" without any warranties of any kind. We do not guarantee that the App will be error-free or uninterrupted.\n\n"
                "7. Limitation of Liability\n"
                "- To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, or consequential damages arising from your use of the App.\n\n"
                "8. Changes to the Terms\n"
                "- We may update these Terms from time to time. We will notify you of any changes by updating the \"Last Updated\" date at the top of these Terms.\n\n"
                "If you have any questions about these Terms, please contact us at [Your Email Address].",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ));
  }
}
