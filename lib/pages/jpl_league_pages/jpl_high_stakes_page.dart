// lib/pages/jpl_league_pages/jpl_high_stakes_classic_page.dart

import 'package:flutter/material.dart';
import 'package:jersey_premier_league/main.dart';
import 'package:jersey_premier_league/services/league_service.dart';

class JPLHighStakesClassicPage extends StatefulWidget {
  const JPLHighStakesClassicPage({super.key});

  @override
  State<JPLHighStakesClassicPage> createState() => _JPLHighStakesClassicPageState();
}

class _JPLHighStakesClassicPageState extends State<JPLHighStakesClassicPage> {
  late Future<LeagueStandingsResponse> _standingsFuture;
  late final LeagueService _leagueService;
  // NOTE: You must update this ID to the correct league ID for 'JPL High Stakes Season 9'
  final int leagueId = 1164350;
  final String leagueName = 'JPL High Stakes Classic';

  int _currentPage = 1;
  bool _hasNext = false;

  final Map<int, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    _leagueService = LeagueService(leagueId);
    _standingsFuture = _leagueService.fetchStandings(_currentPage);
  }

  void _loadPage(int newPage) {
    if (newPage < 1) return;

    setState(() {
      _currentPage = newPage;
      _standingsFuture = _leagueService.fetchStandings(_currentPage);
      _isExpanded.clear();
    });
  }

  // Header row structure with Rank (Natural width), Team (Expanded), and GW/Total (Fixed width 60, Center-aligned).
  Widget _buildHeaderRow() {
    return Container(
      // Padding matches ExpansionTile's tilePadding
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Rank (#) Column (Natural width, Left-aligned)
          Padding(
            padding: EdgeInsets.only(right: 8.0), // Padding for separation
            child: Text('#', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
          ),

          // Team Name Column (Expanded)
          Expanded(
            child: Text('Team Name', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
          ),

          // GW Total Column Header (Fixed Width 60, CENTER ALIGNED)
          SizedBox(
            width: 60,
            child: Text('GW', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),

          // Overall Total Column Header (Fixed Width 60, CENTER ALIGNED)
          SizedBox(
            width: 60,
            child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),

          // Placeholder to ensure alignment with the default ExpansionTile trailing icon space (24)
          SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              onPressed: _currentPage > 1 ? () => _loadPage(_currentPage - 1) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('Page $_currentPage', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: _hasNext ? () => _loadPage(_currentPage + 1) : null,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$leagueName'),
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
      body: FutureBuilder<LeagueStandingsResponse>(
        future: _standingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.standings.isNotEmpty) {
            final response = snapshot.data!;
            final standings = response.standings;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_hasNext != response.hasNext) {
                setState(() {
                  _hasNext = response.hasNext;
                });
              }
            });

            return Column(
              children: [
                _buildHeaderRow(),

                Expanded(
                  child: ListView.builder(
                    itemCount: standings.length,
                    itemBuilder: (context, index) {
                      final standing = standings[index];

                      return Card(
                        elevation: 2,
                        // Removed horizontal margin to match the full width of the header.
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        child: ExpansionTile(
                          // Uses default trailing arrow.

                          onExpansionChanged: (expanded) {
                            setState(() {
                              _isExpanded[standing.entryId] = expanded;
                            });
                          },

                          initiallyExpanded: _isExpanded[standing.entryId] ?? false,

                          // Padding matches header padding
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),

                          // title now contains only the main data row, allowing default trailing arrow to function.
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // Rank (#) Column (Natural width + padding, Left-aligned)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(standing.rank.toString(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.blue), textAlign: TextAlign.left),
                              ),

                              // Team Name (Expanded)
                              Expanded(
                                child: Text(standing.teamName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
                              ),

                              // GW Total Value (Width 60, CENTER ALIGNED)
                              SizedBox(
                                width: 60,
                                child: Text(standing.gwTotal.toString(), textAlign: TextAlign.right),
                              ),

                              // Overall Total (Width 60, CENTER ALIGNED)
                              SizedBox(
                                width: 60,
                                child: Text(standing.overallTotal.toString(), style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                              ),
                              // Default arrow occupies the trailing space.
                            ],
                          ),

                          children: <Widget>[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text('Manager: ${standing.playerName}', style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  FutureBuilder<List<ChipPlayed>>(
                                    future: _leagueService.fetchTeamChips(standing.entryId),
                                    builder: (context, chipSnapshot) {
                                      if (chipSnapshot.connectionState == ConnectionState.waiting) {
                                        return const Row(
                                          children: [
                                            SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                            SizedBox(width: 8),
                                            Text('Loading chip status...'),
                                          ],
                                        );
                                      } else if (chipSnapshot.hasData && chipSnapshot.data!.isNotEmpty) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.style, size: 18, color: Colors.grey),
                                                SizedBox(width: 8),
                                                Text('Chips Played:', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            ...chipSnapshot.data!.map((chip) => Padding(
                                              padding: const EdgeInsets.only(left: 26.0, top: 4.0),
                                              child: Text('${chip.name} - GW ${chip.event}', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                                            )),
                                          ],
                                        );
                                      } else {
                                        return const Row(
                                          children: [
                                            Icon(Icons.style, size: 18, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text('No chips played this season.', style: TextStyle(fontStyle: FontStyle.italic)),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildPaginationControls(),
              ],
            );
          } else {
            return const Center(child: Text('No league standings data found.'));
          }
        },
      ),
    );
  }
}