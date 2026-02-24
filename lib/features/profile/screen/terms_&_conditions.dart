import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: const Color(0xffE0712D),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Terms & Conditions",
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
              "Welcome to MED AI! By using our mobile application, you agree to comply with and be bound by the following terms and conditions. Please read them carefully.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "1. Use of the App",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- You agree to use MED AI only for lawful purposes and in accordance with these Terms.\n"
                  "- You must not use the app to harm others, violate rights, or engage in unauthorized activities.\n"
                  "- We reserve the right to suspend or terminate accounts that violate these Terms.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "2. User Accounts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- You must provide accurate and complete information when creating an account.\n"
                  "- You are responsible for maintaining the confidentiality of your login credentials.\n"
                  "- You agree to notify us immediately of any unauthorized use of your account.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "3. Intellectual Property",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- All content, features, and functionality of MED AI are owned by us or our licensors.\n"
                  "- You may not reproduce, distribute, modify, or create derivative works from any part of the app without permission.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "4. Third-Party Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- MED AI may include links or integrate with third-party services.\n"
                  "- We are not responsible for the content, privacy policies, or practices of third-party services.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "5. Limitation of Liability",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- MED AI is provided 'as-is' and we do not guarantee it will be error-free or uninterrupted.\n"
                  "- We are not liable for any direct, indirect, incidental, or consequential damages resulting from the use of the app.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "6. Modifications to the App",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- We may update, modify, or discontinue features of MED AI at any time without notice.\n"
                  "- Continued use of the app constitutes acceptance of any changes to these Terms.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "7. Governing Law",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- These Terms are governed by the laws of the jurisdiction in which MED AI operates.\n"
                  "- Any disputes arising from these Terms or your use of the app shall be resolved in accordance with applicable law.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "8. Contact Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "If you have questions about these Terms & Conditions, please contact us at:\n\n"
                  "Email: support@medai.com\n"
                  "Address: [Your Company Address]",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}