// lib/pages/admin/send_announcements_page.dart

import 'package:flutter/material.dart';

// Theme colors for consistency
const Color newPrimaryColor = Color(0xFFE91E63);

class SendAnnouncementsPage extends StatelessWidget {
  const SendAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Announcements'),
        backgroundColor: newPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 60, color: newPrimaryColor),
            SizedBox(height: 20),
            Text(
              'Broadcast Messaging',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Create and send notifications or emails to the user base.'),
          ],
        ),
      ),
    );
  }
}