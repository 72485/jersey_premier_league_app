// lib/pages/fixtures_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/services/fpl_service.dart';
import 'package:jersey_premier_league/models/fixture.dart';
import 'package:intl/intl.dart';
import 'package:jersey_premier_league/main.dart'; // For appBarGradientColors

const int maxGameweek = 38;

class FixturesPage extends StatefulWidget {
  const FixturesPage({super.key});

  @override
  State<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends State<FixturesPage> {
  final FplService _fplService = FplService();

  // Initialize to a completed Future with an empty list to prevent LateInitializationError
  late Future<List<Fixture>> _fixturesFuture = Future.value([]);

  int _currentGameweek = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // --- Data Loading Logic ---

  Future<void> _loadInitialData() async {
    try {
      final bootstrapData = await _fplService.fetchBootstrapData();
      final gw = await _fplService.getCurrentGameweek(bootstrapData);

      setState(() {
        _currentGameweek = gw;
        _fixturesFuture = _loadFixturesForGameweek(gw);
      });
    } catch (e) {
      // Set the future to an error state if initial load fails
      setState(() {
        _fixturesFuture = Future.error('Failed to load initial data: $e');
      });
    }
  }

  Future<List<Fixture>> _loadFixturesForGameweek(int gw) async {
    // This calls the FplService to fetch the data
    return _fplService.fetchFixturesForGameweek(gw);
  }

  // --- Gameweek Navigation Logic ---

  void _changeGameweek(int delta) {
    int newGw = _currentGameweek + delta;
    if (newGw >= 1 && newGw <= maxGameweek) {
      setState(() {
        _currentGameweek = newGw;
        _fixturesFuture = _loadFixturesForGameweek(newGw);
      });
    }
  }

  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) {
    final themePrimaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixtures'),
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
      body: Column(
        children: [
          // Gameweek Navigation Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentGameweek > 1 ? () => _changeGameweek(-1) : null,
                  color: _currentGameweek > 1 ? themePrimaryColor : Colors.grey,
                ),
                Text(
                  'Gameweek $_currentGameweek',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentGameweek < maxGameweek ? () => _changeGameweek(1) : null,
                  color: _currentGameweek < maxGameweek ? themePrimaryColor : Colors.grey,
                ),
              ],
            ),
          ),

          // Fixtures List
          Expanded(
            child: FutureBuilder<List<Fixture>>(
              future: _fixturesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final fixtures = snapshot.data;
                if (fixtures == null || fixtures.isEmpty) {
                  return const Center(child: Text('No fixtures found for this gameweek.'));
                }

                return ListView.builder(
                  itemCount: fixtures.length,
                  itemBuilder: (context, index) {
                    return _buildFixtureRow(fixtures[index], themePrimaryColor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixtureRow(Fixture fixture, Color themePrimaryColor) {
    final hasStarted = fixture.started;
    final finished = fixture.finished;

    // Determine the status text and score display
    String scoreDisplay;
    String statusText;

    if (finished) {
      scoreDisplay = '${fixture.homeScore} - ${fixture.awayScore}';
      statusText = 'FINAL';
    } else if (hasStarted) {
      scoreDisplay = '${fixture.homeScore} - ${fixture.awayScore}';
      statusText = 'LIVE'; // Simple status for display
    } else {
      // Display kickoff time if not started
      scoreDisplay = DateFormat('EEE d MMM').format(fixture.kickoffTime);
      statusText = DateFormat('HH:mm').format(fixture.kickoffTime);
    }

    // Fallback for missing scores/status in edge cases
    if (fixture.homeScore == null || fixture.awayScore == null) {
      if (hasStarted && !finished) {
        scoreDisplay = 'LIVE';
        statusText = 'SCORE TBD';
      } else if (!hasStarted) {
        // Already handled by showing date/time
      } else {
        scoreDisplay = 'N/A';
        statusText = 'POSTPONED';
      }
    }


    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home Team
            Expanded(
              flex: 3,
              child: Text(
                fixture.homeTeam,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            // Score/Time Display
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      scoreDisplay,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: hasStarted ? FontWeight.w900 : FontWeight.normal,
                        fontSize: hasStarted ? 20 : 14,
                        color: hasStarted ? themePrimaryColor : Colors.grey.shade700,
                      ),
                    ),
                    if (statusText.isNotEmpty)
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusText == 'LIVE' ? Colors.red : themePrimaryColor.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Away Team
            Expanded(
              flex: 3,
              child: Text(
                fixture.awayTeam,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}