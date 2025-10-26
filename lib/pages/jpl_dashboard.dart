// lib/pages/jpl_dashboard.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/main.dart'; // For theme colors/gradient

// ⚡ IMPORT: Import the five specific league pages
import 'package:jersey_premier_league/pages/jpl_league_pages/jpl_classic_page.dart';
import 'package:jersey_premier_league/pages/jpl_league_pages/jpl_high_stakes_page.dart';
import 'package:jersey_premier_league/pages/jpl_league_pages/jpl_tvt_league_page.dart';
import 'package:jersey_premier_league/pages/jpl_league_pages/jpl_grand_prix_page.dart';

class JPL_Dashboard extends StatelessWidget {
  const JPL_Dashboard({super.key});

  final List<Map<String, dynamic>> leagueFormats = const [
    {
      'name': 'JPL Classic',
      'icon': Icons.stars,
      'description': 'Traditional points accumulation league.',
      'page': JPLClassicPage(), // ⚡ NEW: Page reference
    },
    {
      'name': 'JPL High Stakes',
      'icon': Icons.attach_money,
      'description': 'High entry, high reward league format.',
      'page': JPLHighStakesClassicPage(), // ⚡ NEW: Page reference
    },
    {
      'name': 'JPL TVT League (Team vs Team)',
      'icon': Icons.diversity_3,
      'description': 'Compete as a dedicated Team vs Team squad.',
      'page': JPLTVTLeaguePage(), // ⚡ NEW: Page reference
    },
    {
      'name': 'JPL Grand Prix',
      'icon': Icons.sports_score,
      'description': 'An F1-inspired format where points are awarded based on weekly rankings.',
      'page': JPLGrandPrixPage(), // ⚡ NEW: Page reference
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JPL League Selection'),
        automaticallyImplyLeading: false,
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
      // ListView of league formats
      body: ListView.builder(
        itemCount: leagueFormats.length,
        itemBuilder: (context, index) {
          final league = leagueFormats[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(
                league['icon'] as IconData,
                color: Colors.blue.shade800,
                size: 40,
              ),
              title: Text(
                league['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(league['description'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // ⚡ FIX: Navigate using the specific page widget stored in the map
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => league['page'] as Widget,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}