// lib/pages/admin/system_health_page.dart

import 'package:flutter/material.dart';

// Theme colors for consistency
const Color newPrimaryColor = Color(0xFFE91E63);

class SystemHealthPage extends StatelessWidget {
  const SystemHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Health'),
        backgroundColor: newPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_heart, size: 60, color: newPrimaryColor),
            SizedBox(height: 20),
            Text(
              'API Status and Performance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Monitor uptime and external API connections.'),
          ],
        ),
      ),
    );
  }
}