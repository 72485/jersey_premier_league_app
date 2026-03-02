// lib/pages/admin/manage_users_page.dart

import 'package:flutter/material.dart';

// Theme colors for consistency
const Color newPrimaryColor = Color(0xFFE91E63);

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: newPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt, size: 60, color: newPrimaryColor),
            SizedBox(height: 20),
            Text(
              'User Management Interface',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Here you can search, verify, and modify user accounts.'),
          ],
        ),
      ),
    );
  }
}