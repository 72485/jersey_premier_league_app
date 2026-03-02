// lib/pages/admin/manage_leagues_page.dart

import 'package:flutter/material.dart';

// Theme colors for consistency
const Color newPrimaryColor = Color(0xFFE91E63);

class ManageLeaguesPage extends StatelessWidget {
  const ManageLeaguesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage JPL Leagues'),
        backgroundColor: newPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 60, color: newPrimaryColor),
            SizedBox(height: 20),
            Text(
              'League Verification & Creation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Interface to handle FPL team ID verification and league configuration.'),
          ],
        ),
      ),
    );
  }
}