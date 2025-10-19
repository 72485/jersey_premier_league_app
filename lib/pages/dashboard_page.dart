import 'package:flutter/material.dart';
import 'package:jersey_premier_league/models/user_model.dart'; // Import User model
import 'package:jersey_premier_league/widgets/grid_item.dart'; // Import GridItem widget

class DashboardPage extends StatelessWidget {
  final User user;
  final VoidCallback onSignOut;

  const DashboardPage({super.key, required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    // Defines the 6 items for the 2x3 grid
    final List<Map<String, dynamic>> gridItems = [
      {'title': 'FPL Leagues', 'icon': Icons.sports_football, 'color': Colors.green.shade700},
      {'title': 'JPL Leagues', 'icon': Icons.local_fire_department, 'color': Colors.blue.shade700},
      {'title': 'Stats', 'icon': Icons.show_chart, 'color': Colors.red.shade700},
      {'title': 'Fixtures', 'icon': Icons.schedule, 'color': Colors.purple.shade700},
      {'title': 'Settings', 'icon': Icons.settings, 'color': Colors.grey.shade700},
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
                  return GridItem( // Using the imported GridItem widget
                    title: item['title'],
                    icon: item['icon'],
                    color: item['color'],
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
