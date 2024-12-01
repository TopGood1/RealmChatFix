import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal, // Sesuaikan dengan warna yang diinginkan
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Last Updated: Sunday, 13 October 2024\n",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Your privacy is important to us. This Privacy Policy explains how we collect, use, and share your information when you use the RealmChat real-time chat application (\"the App\").\n\n"
              "1. Information We Collect\n"
              "- **Personal Information**: We may collect personal information such as your name, email address, and phone number when you register for an account.\n"
              "- **Usage Data**: We may collect information about how you use the App, including chat history, app usage patterns, and device information (e.g., device model, operating system, and IP address).\n\n"
              "2. How We Use Your Information\n"
              "- We use your personal information to provide and improve the App.\n"
              "- We may use your chat data for moderation purposes, but we do not share or sell your messages to third parties.\n"
              "- We may send you notifications related to your account or the App’s functionality.\n\n"
              "3. Sharing Your Information\n"
              "- We may share your information with service providers who assist in operating the App (e.g., cloud storage providers).\n"
              "- We may share your information if required by law or in response to a legal process.\n\n"
              "4. Data Security\n"
              "- We use reasonable security measures to protect your information. However, we cannot guarantee the security of your data transmitted via the App.\n\n"
              "5. Data Retention\n"
              "- We will retain your personal data for as long as necessary to provide the App or as required by law.\n\n"
              "6. Your Rights\n"
              "- You may request to access, update, or delete your personal information by contacting us.\n"
              "- You have the right to withdraw your consent to data processing at any time.\n\n"
              "7. Children's Privacy\n"
              "- The App is not intended for use by children under the age of 13. We do not knowingly collect personal data from children under 13.\n\n"
              "8. Changes to the Privacy Policy\n"
              "- We may update this Privacy Policy from time to time. We will notify you of any changes by updating the \"Last Updated\" date at the top of this Policy.\n\n"
              "If you have any questions about this Privacy Policy, please contact us at [Your Email Address].",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
