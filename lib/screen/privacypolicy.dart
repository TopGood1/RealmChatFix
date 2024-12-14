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
              "- **Personal Information**: Your email address, name, and optional 'about' status that you provide during registration or profile updates.\n"
              "- **Chat Data**: Messages exchanged with other users.\n"
              "- **Usage Data**: nformation about how you use the App, including app interactions and error reports.\n\n"
              "2. How We Use Your Information\n"
              "- To create and manage your user account.\n"
              "- To enable real-time communication between users.\n"
              "- To provide customer support and improve user experience.\n"
              "- To send password recovery and account-related notifications.\n"
              "- To ensure the security and functionality of the App.\n\n"
              "3. Sharing Your Information\n"
              "- **Service Providers**: Third-party services like Firebase, which facilitate App functionality, authentication, and database storage.\n"
              "- **Legal Authorities**: If required by law, we may disclose your information to comply with legal obligations or protect our rights.\n\n"
              "4. Data Storage and Security\n"
              "- Your data is securely stored using Firebase infrastructure, which complies with industry security standards. We implement measures such as encryption and secure access protocols to protect your personal data. However, no method of transmission or storage is 100% secure, and we cannot guarantee absolute security.\n\n"
              "5. User Rights\n"
              "- **Access**: Request access to the personal information we hold about you.\n"
              "- **Correction**: Update or correct your profile information through the App.\n"
              "- **Deletion**: Delete your account and associated data using the 'Delete Account' feature in your profile settings.\n\n"
              "- If you have any concerns about your data, please contact us at 11211021@student.itk.ac.id\n\n"
              "6. Cookies and Tracking\n"
              "RealmChat does not use cookies or tracking mechanisms within the App. However, Firebase may collect certain usage data as part of their analytics tools.\n\n"
              "7. Third-Party Services\n"
              "The App integrates with Firebase, which may process your data in accordance with its own privacy policies. We encourage you to review Firebase's Privacy Policy\n\n"
              "8. Children’s Privacy\n"
              "RealmChat is not intended for use by individuals under the age of 13. If we become aware that we have collected data from a child under 13 without parental consent, we will take steps to delete such information.\n\n"
              "9. Changes to the Privacy Policy\n"
              "We may update this Privacy Policy from time to time. Any changes will be effective upon posting the updated policy in the App. We encourage you to review this policy periodically for any updates.\n\n"
              "10. Contact Us\n"
              "- Email: 11211021@student.itk.ac.id\n"
              "- Address:  Indonesia, Balikpapan. JL. Syarifuddin Yoes No.69 ",
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
