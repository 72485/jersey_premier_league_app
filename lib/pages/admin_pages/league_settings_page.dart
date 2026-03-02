// lib/pages/admin/league_settings_page.dart

import 'package:flutter/material.dart';

// Theme colors for consistency
const Color newPrimaryColor = Color(0xFFE91E63);

class LeagueSettingsPage extends StatelessWidget {
  const LeagueSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('League Settings'),
        backgroundColor: newPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 60, color: newPrimaryColor),
            SizedBox(height: 20),
            Text(
              'Global League Configuration',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Set global rules, deadlines, and scoring mechanisms.'),
          ],
        ),
      ),
    );
  }
}