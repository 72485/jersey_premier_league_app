// lib/pages/leagues_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/services/fpl_service.dart';
import 'package:jersey_premier_league/models/league.dart';
import 'package:jersey_premier_league/pages/league_standings_page.dart';
import 'package:jersey_premier_league/main.dart'; // For appBarGradientColors and theme colors

class LeaguesPage extends StatefulWidget {
  final int fplTeamId;

  const LeaguesPage({super.key, required this.fplTeamId});

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  final FplService _fplService = FplService();
  late Future<List<League>> _leaguesFuture;

  @override
  void initState() {
    super.initState();
    // Load the user's leagues when the page initializes
    _leaguesFuture = _fplService.fetchUserLeagues(widget.fplTeamId);
  }

  void _navigateToStandings(League league) {
    if (league.type == 'classic') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeagueStandingsPage(
            league: league,
            currentFplTeamId: widget.fplTeamId,
          ),
        ),
      );
    } else {
      // Handle H2H leagues which may have a different standings view or are unsupported
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${league.type.toUpperCase()} standings view is not yet supported.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themePrimaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leagues'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            // Use the gradient colors defined in main.dart
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<League>>(
        future: _leaguesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading leagues: ${snapshot.error}'));
          }

          final leagues = snapshot.data;
          if (leagues == null || leagues.isEmpty) {
            return const Center(child: Text('You are not currently in any leagues.'));
          }

          // Separate the Global League (ID 1) if present
          final globalLeague = leagues.where((l) => l.id == 1).toList();
          final otherLeagues = leagues.where((l) => l.id != 1).toList();

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // Global League Section
              if (globalLeague.isNotEmpty) ...[
                _buildLeagueSection(
                    context,
                    'Global League',
                    globalLeague,
                    themePrimaryColor
                ),
                const Divider(),
              ],

              // Other Leagues Section
              _buildLeagueSection(
                  context,
                  'Classic & H2H Leagues',
                  otherLeagues,
                  themePrimaryColor
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeagueSection(
      BuildContext context,
      String title,
      List<League> leagues,
      Color themePrimaryColor) {

    if (leagues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: leagues.map((league) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: InkWell(
                onTap: () => _navigateToStandings(league),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Column 1: League Name and Type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              league.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              league.id == 1
                                  ? 'Global League'
                                  : (league.type == 'classic' ? 'Classic League' : 'H2H League'),
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // Column 2: League Rank
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Your Rank',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '#${league.rank}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: themePrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}