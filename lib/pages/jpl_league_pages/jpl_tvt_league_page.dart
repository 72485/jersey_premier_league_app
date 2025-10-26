// lib/pages/jpl_league_pages/jpl_tvt_league_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/main.dart';

class JPLTVTLeaguePage extends StatelessWidget {
  const JPLTVTLeaguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JPL TVT League (Team vs Team)'),
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
      body: const Center(
        child: Text(
          'JPL TVT League Team Standings and Scores Go Here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}