// lib/pages/jpl_league_pages/jpl_grand_prix_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/main.dart';

class JPLGrandPrixPage extends StatelessWidget {
  const JPLGrandPrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JPL Grand Prix'),
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
          'JPL Grand Prix Weekly Rankings and Overall Leaderboard Go Here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}