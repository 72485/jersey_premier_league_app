// lib/pages/league_standings_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/services/fpl_service.dart';
import 'package:jersey_premier_league/models/league.dart';
import 'package:jersey_premier_league/models/standing_entry.dart';
import 'package:jersey_premier_league/main.dart'; // For appBarGradientColors

class LeagueStandingsPage extends StatefulWidget {
  final League league;
  final int currentFplTeamId;

  const LeagueStandingsPage({
    super.key,
    required this.league,
    required this.currentFplTeamId,
  });

  @override
  State<LeagueStandingsPage> createState() => _LeagueStandingsPageState();
}

class _LeagueStandingsPageState extends State<LeagueStandingsPage> {
  final FplService _fplService = FplService();
  late Future<List<StandingEntry>> _standingsFuture;

  @override
  void initState() {
    super.initState();
    _standingsFuture = _fplService.fetchLeagueStandings(widget.league.id);
  }

  @override
  Widget build(BuildContext context) {
    // Get primary color from theme
    final themePrimaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.league.name} Standings'),
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
      ),
      body: FutureBuilder<List<StandingEntry>>(
        future: _standingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error loading standings: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          final standings = snapshot.data;
          if (standings == null || standings.isEmpty) {
            return const Center(child: Text('No entries found in this league.'));
          }

          return Column(
            children: [
              // Header Row (Table Head)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: themePrimaryColor.withOpacity(0.1),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 50, child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(child: Text('Team Name / Manager', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 60, child: Text('Points', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: standings.length,
                  itemBuilder: (context, index) {
                    final entry = standings[index];
                    final bool isCurrentUser = entry.entryId == widget.currentFplTeamId;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isCurrentUser ? themePrimaryColor.withOpacity(0.1) : Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        // ⚡ FIX: Explicitly set crossAxisAlignment to center to constrain Row height and fix RenderFlex error
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Rank
                          SizedBox(width: 50, child: Text('${entry.rank}', style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal))),

                          // Team Name and Player Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ⚡ FIX: Use null-aware operator to handle potential null String? from model
                                Text(
                                  entry.teamName, // teamName is safe because of null-aware operator in StandingEntry.fromJson
                                  style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // ⚡ FIX: Use null-aware operator to handle potential null String? from model
                                Text(
                                  entry.playerName ?? 'N/A Manager',
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Points Column
                          SizedBox(
                            width: 60,
                            child: Text(
                              '${entry.totalPoints}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.bold,
                                color: isCurrentUser ? themePrimaryColor : Colors.black,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}