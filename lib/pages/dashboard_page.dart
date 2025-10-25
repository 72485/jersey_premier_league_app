// In dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart'; // Import User model
import 'package:jersey_premier_league/widgets/grid_item.dart'; // Import GridItem widget
// NEW IMPORTS: Required for navigation from previous steps
import 'package:jersey_premier_league/services/auth_service.dart';
import 'package:jersey_premier_league/pages/profile_page.dart';
import 'package:jersey_premier_league/pages/change_password_page.dart';


class DashboardPage extends StatelessWidget {
  final User user;
  final VoidCallback onSignOut;
  // NEW: Add authService required for navigation (from previous fix)
  final AuthService authService;

  const DashboardPage({
    super.key,
    required this.user,
    required this.onSignOut,
    required this.authService, // Add to constructor
  });

  // Navigation functions (from previous steps)
  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          user: user,
          authService: authService,
        ),
      ),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(
          authService: authService,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Defines the 6 items for the 2x3 grid with ambient colors and proper navigation
    final List<Map<String, dynamic>> gridItems = [
      // Muted Ambient Colors
      {'title': 'FPL Leagues', 'icon': Icons.groups_2_outlined, 'color': Colors.green.shade500, 'onTap': null},
      {'title': 'JPL Leagues', 'icon': Icons.emoji_events_outlined, 'color': Colors.teal.shade500, 'onTap': null},
      {'title': 'Stats', 'icon': Icons.bar_chart_outlined, 'color': Colors.deepOrange.shade500, 'onTap': null},
      {'title': 'Fixtures', 'icon': Icons.calendar_month_outlined, 'color': Colors.indigo.shade500, 'onTap': null},
      {
        'title': 'Profile',
        'icon': Icons.person_outline,
        'color': Colors.blueGrey.shade500,
        'onTap': () => _navigateToProfile(context),
      },
      {
        'title': 'Change Password',
        'icon': Icons.lock_outline,
        'color': Colors.blueGrey.shade700,
        'onTap': () => _navigateToChangePassword(context),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('JPL Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: onSignOut,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.name}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  // Display FPL ID for confirmation
                  Text(
                    'FPL Team ID: ${user.fpl_team_ID ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // 2x3 Grid View
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.2, // Adjust card height
                children: gridItems.map((item) {
                  return GridItem(
                    title: item['title'],
                    icon: item['icon'],
                    color: item['color'],
                    onTapCallback: item['onTap'] as VoidCallback?,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}