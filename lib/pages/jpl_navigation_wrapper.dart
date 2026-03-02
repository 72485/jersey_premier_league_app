// lib/pages/jpl_navigation_wrapper.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/services/auth_service.dart';
import 'package:jersey_premier_league/models/user_model.dart';
import 'package:jersey_premier_league/pages/leagues_page.dart';
import 'package:jersey_premier_league/pages/fixtures_page.dart';
// IMPORT: Add the new dashboard page
import 'package:jersey_premier_league/pages/jpl_dashboard.dart';
import 'package:jersey_premier_league/pages/profile_page.dart';
import 'package:jersey_premier_league/pages/change_password_page.dart';
import 'package:jersey_premier_league/main.dart'; // For theme colors/gradient

// 1. New Widget for the Tools Tab with TabBar
// --------------------------------------------------------------------------
class ToolsTabPage extends StatelessWidget {
  final User user;
  final AuthService authService;
  final VoidCallback onSignOut;

  const ToolsTabPage({
    super.key,
    required this.user,
    required this.authService,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    // We use DefaultTabController to manage the tabs state
    return DefaultTabController(
      length: 2, // Profile and Password tabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Prevents back button on sub-page
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              // Use the same gradient for consistency
              gradient: LinearGradient(
                colors: appBarGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text('Tools'),

          // Global Logout Button
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Sign Out',
              // ⚡ FIX: Access 'onSignOut' directly
              onPressed: onSignOut,
            ),
            const SizedBox(width: 8),
          ],

          // TabBar styling for visibility
          bottom: const TabBar(
            isScrollable: false,
            indicatorColor: Colors.yellow,
            labelColor: Colors.yellow,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: "PROFILE DETAILS"),
              Tab(text: "CHANGE PASSWORD"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ⚡ FIX: Access properties directly (user, authService, onSignOut)
            // Do NOT use 'widget.user' or 'widget.authService' here.

            // First Tab Content: Profile (Lines 85-86 area)
            ProfilePage(
              user: user,
              authService: authService,
              onSignOut: onSignOut,
            ),

            // Second Tab Content: Change Password (Line 90 area)
            ChangePasswordPage(
              authService: authService,
            ),
          ],
        ),
      ),
    );
  }
}
// --------------------------------------------------------------------------

// (The rest of the file remains unchanged)

class JPLNavigationWrapper extends StatefulWidget {
  final User user;
  final AuthService authService;
  final VoidCallback onSignOut;

  const JPLNavigationWrapper({
    super.key,
    required this.user,
    required this.authService,
    required this.onSignOut,
  });

  @override
  State<JPLNavigationWrapper> createState() => _JPLNavigationWrapperState();
}

class _JPLNavigationWrapperState extends State<JPLNavigationWrapper> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    final fplTeamId = int.tryParse(widget.user.fpl_team_id ?? '') ?? 0;

    // Initialize the list of pages
    _pages = <Widget>[
      // 0: JPL Leagues (Home) -> POINTS TO NEW DASHBOARD
      const JPL_Dashboard(),

      // 1: Fixtures
      const FixturesPage(),

      // 2: FPL Leagues (Points to LeaguesPage)
      LeaguesPage(fplTeamId: fplTeamId),

      // 3: Tools - The wrapper page containing Profile and Password tabs
      ToolsTabPage(
        user: widget.user,
        authService: widget.authService,
        onSignOut: widget.onSignOut,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Access the initialized list
        child: _pages.elementAt(_selectedIndex),
      ),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: appBarGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 10, spreadRadius: 0),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer),
              label: 'JPL Leagues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Fixtures',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'FPL Leagues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Tools',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}