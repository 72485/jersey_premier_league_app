// lib/pages/league_details_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/main.dart'; // For theme colors/gradient

class LeagueDetailsPage extends StatelessWidget {
  // Receives the league data from the dashboard
  final Map<String, dynamic> league;

  const LeagueDetailsPage({super.key, required this.league});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(league['name'] as String),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Reverted: Removed the Hero widget, this is now a standard header.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    league['icon'] as IconData,
                    size: 60,
                    color: Colors.blue.shade800,
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: Text(
                      league['name'] as String,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Placeholder content for the details page
            const SizedBox(height: 24),
            const Text(
              'About this League',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '${league['description']}\n\nThis page will soon display the league table, rules, and top players for the ${league['name']} format. Please check back later!',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}