// lib/services/fpl_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/fixture.dart';
import '../models/league.dart';
import '../models/standing_entry.dart';

const int maxGameweek = 38;

class FplService {
  final String _bootstrapUrl = 'https://fantasy.premierleague.com/api/bootstrap-static/';
  final String _fixturesUrl = 'https://fantasy.premierleague.com/api/fixtures/';
  final String _entryUrl = 'https://fantasy.premierleague.com/api/entry/';
  final String _leagueStandingsUrl = 'https://fantasy.premierleague.com/api/leagues-classic/';

  Future<Map<String, dynamic>> fetchBootstrapData() async {
    final uri = Uri.parse(_bootstrapUrl);
    debugPrint('API Hit: $uri');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load FPL bootstrap data (Status: ${response.statusCode}).');
  }

  Future<Map<int, String>> _getTeamIdMapping(Map<String, dynamic> bootstrapData) async {
    final Map<int, String> teamIdMap = {};
    for (var team in bootstrapData['teams']) {
      teamIdMap[team['id'] as int] = team['name'] as String;
    }
    return teamIdMap;
  }

  Future<int> getCurrentGameweek(Map<String, dynamic> bootstrapData) async {
    for (var gameweek in bootstrapData['events']) {
      if (gameweek['is_current'] == true) {
        return gameweek['id'] as int;
      }
    }
    return 1;
  }

  Future<List<Fixture>> fetchFixturesForGameweek(int gameweek) async {
    final bootstrapData = await fetchBootstrapData();
    final teamIdMap = await _getTeamIdMapping(bootstrapData);

    final uri = Uri.parse(_fixturesUrl);
    debugPrint('API Hit: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> allFixturesJson = json.decode(response.body);
      return allFixturesJson
          .where((json) => json['event'] == gameweek)
          .map((json) => Fixture.fromJson(json, teamIdMap))
          .toList();
    }
    throw Exception('Failed to load FPL fixtures data (Status: ${response.statusCode}).');
  }

  Future<List<League>> fetchUserLeagues(int fplTeamId) async {
    final uri = Uri.parse('$_entryUrl$fplTeamId/');
    debugPrint('API Hit: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<League> allLeagues = [];

      // Process Classic Leagues
      final classicLeagues = jsonResponse['leagues']['classic'] as List<dynamic>?;
      if (classicLeagues != null) {
        // ⚡ FIX: Use NAMED parameter 'type'
        allLeagues.addAll(classicLeagues.map((json) => League.fromJson(json, type: 'classic')));
      }

      // Process H2H Leagues
      final h2hLeagues = jsonResponse['leagues']['h2h'] as List<dynamic>?;
      if (h2hLeagues != null) {
        // ⚡ FIX: Use NAMED parameter 'type'
        allLeagues.addAll(h2hLeagues.map((json) => League.fromJson(json, type: 'h2h')));
      }

      return allLeagues;
    }
    throw Exception('Failed to load user leagues (Status: ${response.statusCode})');
  }

  Future<List<StandingEntry>> fetchLeagueStandings(int leagueId) async {
    final uri = Uri.parse('$_leagueStandingsUrl$leagueId/standings/?page_new_entries=1&page_standings=1');
    debugPrint('API Hit: $uri');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final standingsJson = jsonResponse['standings']['results'] as List<dynamic>?;

      if (standingsJson == null) return [];

      return standingsJson
          .map((json) => StandingEntry.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load league standings (Status: ${response.statusCode})');
  }
}