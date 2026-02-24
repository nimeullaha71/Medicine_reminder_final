import 'package:flutter/material.dart';
import '../../../common/app_shell.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return  SubPageScaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      parentTabIndex: 4,
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xffE0712D), size: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Effective Date: February 25, 2026",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            Text(
              "MED AI our values your privacy. This Privacy Policy explains how we collect, use, and protect your personal information when you use our mobile application.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "1. Information We Collect",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- Personal Information: Name, email address, profile picture, contact information, and other details you provide when creating an account.\n"
                  "- Usage Data: Information about how you interact with the app, including features used, time spent, and device information.\n"
                  "- Cookies & Analytics: We may use analytics tools to understand app performance and improve user experience.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "2. How We Use Your Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- To provide and maintain our app services.\n"
                  "- To personalize your experience and update your profile.\n"
                  "- To communicate important updates or changes.\n"
                  "- To improve app functionality and performance.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "3. Data Sharing and Disclosure",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- We do not sell your personal information. We may share your data:\n"
                  "  • With service providers who help us operate the app.\n"
                  "  • If required by law or to protect legal rights.\n"
                  "  • During mergers, acquisitions, or transfers of assets (with the new entity bound to this policy).",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "4. Data Security",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "We implement reasonable technical and administrative measures to protect your personal data. However, no method of transmission or storage is 100% secure.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "5. Your Rights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- Access, update, or delete your personal information.\n"
                  "- Opt-out of certain communications.\n"
                  "- Contact us for any privacy-related concerns.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "6. Children’s Privacy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Our app is not intended for children under 13. We do not knowingly collect data from children under 13.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "7. Changes to This Privacy Policy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "We may update this policy from time to time. Changes will be posted in the app, and the “Effective Date” will be updated.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "8. Contact Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "If you have questions about this Privacy Policy, you can contact us at:\n\n"
                  "Email: support@medai.com\n"
                  "Address: Bangladesh",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}