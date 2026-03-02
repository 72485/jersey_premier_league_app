// lib/pages/admin_home_page.dart

import 'package:flutter/material.dart';

// Import the new administrative pages
import 'package:jersey_premier_league/pages/admin_pages/manage_users_page.dart';
import 'package:jersey_premier_league/pages/admin_pages/manage_leagues_page.dart';
import 'package:jersey_premier_league/pages/admin_pages/league_settings_page.dart';
import 'package:jersey_premier_league/pages/admin_pages/send_announcements_page.dart';
import 'package:jersey_premier_league/pages/admin_pages/system_health_page.dart';


// Assuming newPrimaryColor and appBarGradientColors are available or defined here
const Color newPrimaryColor = Color(0xFFE91E63);
const Color newSecondaryColor = Color(0xFF00BCD4);
const Color newNeutralColor = Color(0xFFBDBDBD); // Added for local context
const List<Color> appBarGradientColors = [
  newPrimaryColor, // Start color (Magenta)
  newSecondaryColor, // End color (Cyan)
];

// Data model for the Admin Dashboard options
class AdminOption {
  final String title;
  final IconData icon;
  final String description;

  AdminOption({required this.title, required this.icon, required this.description});
}

class AdminHomePage extends StatelessWidget {
  final VoidCallback onSignOut;

  const AdminHomePage({super.key, required this.onSignOut});

  // Define the list of admin dashboard options
  static final List<AdminOption> _adminOptions = [
    AdminOption(
      title: 'Manage Users',
      icon: Icons.people_alt,
      description: 'Review, verify, and manage all registered user accounts.',
    ),
    AdminOption(
      title: 'Manage JPL Leagues',
      icon: Icons.check_circle_outline,
      description: 'Approve or reject user-submitted FPL team IDs.',
    ),
    AdminOption(
      title: 'League Settings',
      icon: Icons.settings,
      description: 'Configure league rules, deadlines, and scoring parameters.',
    ),
    AdminOption(
      title: 'Send Announcements',
      icon: Icons.campaign,
      description: 'Broadcast important messages or updates to all users.',
    ),
    AdminOption(
      title: 'System Health',
      icon: Icons.monitor_heart,
      description: 'Check API status and performance metrics.',
    ),
    AdminOption(
      title: 'View Logs',
      icon: Icons.list_alt,
      description: 'Access application and error logs for debugging.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onSignOut,
            tooltip: 'Sign Out',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- 1. Welcome Header ---
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Administrator!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: newPrimaryColor),
                ),
                SizedBox(height: 4),
                Text(
                  'Quick overview and system tasks.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),

          const Text(
            'Administrative Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(color: newNeutralColor),

          // --- 3. Full-Width Task List ---
          ..._adminOptions.map((option) => AdminTaskTile(option: option, color: newPrimaryColor)),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

// ❌ KeyMetricCard class is no longer needed since it's removed from the widget tree
// I will keep it commented out for now in case it's added back later, but it's not strictly necessary.
/*
class KeyMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const KeyMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}
*/

// 🆕 UPDATED: Custom Widget for the full-width list tiles with navigation
class AdminTaskTile extends StatelessWidget {
  final AdminOption option;
  final Color color;

  const AdminTaskTile({super.key, required this.option, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              option.icon,
              color: color,
            ),
          ),
          title: Text(
            option.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            option.description,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            // --- Navigation Logic ---
            Widget destinationPage;

            // This switch statement maps the title string to the corresponding destination widget
            switch (option.title) {
              case 'Manage Users':
                destinationPage = const ManageUsersPage();
                break;
              case 'Manage JPL Leagues':
                destinationPage = const ManageLeaguesPage();
                break;
              case 'League Settings':
                destinationPage = const LeagueSettingsPage();
                break;
              case 'Send Announcements':
                destinationPage = const SendAnnouncementsPage();
                break;
              case 'System Health':
                destinationPage = const SystemHealthPage();
                break;
              default:
              // Fallback for unmapped options
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${option.title} is not yet implemented.')),
                );
                return;
            }

            // Perform the navigation
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            );
          },
        ),
        // FIX: Removed const keyword from Divider
        Divider(height: 1, color: newNeutralColor),
      ],
    );
  }
}