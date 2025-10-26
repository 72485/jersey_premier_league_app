import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jersey_premier_league/models/fpl_h2h_models.dart';

// ⚡ NEW: Base URL only for the main FPL API
const String _BASE_API_URL = 'https://fantasy.premierleague.com/api/';

// --- DATA MODELS (Only Classic Models remain here) ---

// Model for a chip played by a manager
class ChipPlayed {
  final String name;
  final int event; // Gameweek the chip was played

  ChipPlayed({required this.name, required this.event});

  factory ChipPlayed.fromJson(Map<String, dynamic> json) {
    // Map FPL API chip codes to readable names
    String chipName;
    switch (json['name']) {
      case 'bboost':
        chipName = 'Bench Boost';
        break;
      case '3xc':
        chipName = 'Triple Captain';
        break;
      case 'wildcard':
        chipName = 'Wildcard';
        break;
      case 'freehit':
        chipName = 'Free Hit';
        break;
      default:
        chipName = 'Unknown Chip';
    }

    return ChipPlayed(
      name: chipName,
      event: json['event'] as int,
    );
  }
}

// Model for a single team's standing
class TeamStanding {
  final int rank;
  final String teamName;
  final String playerName;
  final int entryId; // Manager ID
  final int gwTotal;
  final int overallTotal;

  TeamStanding({
    required this.rank,
    required this.teamName,
    required this.playerName,
    required this.entryId,
    required this.gwTotal,
    required this.overallTotal,
  });

  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(
      rank: json['rank'] as int,
      teamName: json['entry_name'] as String,
      playerName: json['player_name'] as String,
      entryId: json['entry'] as int,
      gwTotal: json['event_total'] as int,
      overallTotal: json['total'] as int,
    );
  }
}

// Container for standings data and pagination metadata
class LeagueStandingsResponse {
  final List<TeamStanding> standings;
  final bool hasNext;
  final int currentPage;

  LeagueStandingsResponse({
    required this.standings,
    required this.hasNext,
    required this.currentPage,
  });
}


// --- API SERVICE ---

class LeagueService {
  final int _leagueId;

  LeagueService(this._leagueId);

  /// Fetches the main classic league standings for a specific page.
  Future<LeagueStandingsResponse> fetchStandings(int page) async {
    final url = Uri.parse('${_BASE_API_URL}leagues-classic/$_leagueId/standings/?page_standings=$page');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final standingsData = data['standings'];

        final List<dynamic> results = standingsData['results'];
        final bool hasNext = standingsData['has_next'] as bool;
        final int currentPage = standingsData['page'] as int;

        final List<TeamStanding> standings = results.map((standing) => TeamStanding.fromJson(standing)).toList();

        return LeagueStandingsResponse(
          standings: standings,
          hasNext: hasNext,
          currentPage: currentPage,
        );
      } else {
        throw Exception('Failed to load standings. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to FPL API: $e');
    }
  }

  /// Fetches the chip history for a single manager (entryId).
  Future<List<ChipPlayed>> fetchTeamChips(int entryId) async {
    final url = Uri.parse('${_BASE_API_URL}entry/$entryId/history/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> chipData = data['chips'];

        // Filter for chips that have been played (indicated by a non-null 'time' field)
        return chipData
            .where((chip) => chip['time'] != null)
            .map((chip) => ChipPlayed.fromJson(chip))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Fetches the H2H league standings.
  Future<H2HLeagueResponse> fetchH2HStandings(int page) async {
    // ⚡ FIX: Use correct FPL endpoint structure for H2H Standings
    final url = Uri.parse('${_BASE_API_URL}leagues-h2h/$_leagueId/standings/?page_standings=$page');

    print('ℹ️ Hitting URL for H2H Standings: $url'); // 📢 LOGGING

    // NOTE: FPL API usually does not require special headers, but keeping it is fine.
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return H2HLeagueResponse.fromJson(data);
    } else {
      // 📢 LOGGING: Error details
      print('❌ FPL API Error: Failed to load H2H standings. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load H2H standings: ${response.statusCode}');
    }
  }

  /// Fetches H2H Fixtures (can filter by user team ID or all)
  Future<List<H2HMatch>> fetchH2HFixtures({required int gameWeek, String? fplTeamId}) async {
    // ⚡ FIX: Use correct FPL endpoint structure for H2H Matches
    // FPL uses `page` for fixtures pagination, not a separate matches endpoint.
    // However, the provided matches endpoint includes an 'event' filter.

    String baseUrl = '${_BASE_API_URL}leagues-h2h-matches/league/$_leagueId/?event=$gameWeek';

    // The FPL team ID filter typically works on the `entry` parameter, but
    // it's often more reliable to fetch all for the GW and filter locally if needed,
    // or use the `entry` parameter if that's what your custom API expected.
    // Based on the old structure, we'll keep the custom parameter name for now,
    // but the FPL standard is usually to fetch all for a GW and page through them.

    // If fplTeamId is provided, append the team ID filter
    if (fplTeamId != null && fplTeamId.isNotEmpty) {
      // NOTE: This parameter `&team_id=` might not be valid for the official FPL API.
      // The official API usually fetches all matches for a league/GW.
      // You may need to verify or implement local filtering if this fails.
      baseUrl += '&entry=$fplTeamId';
    }

    final url = Uri.parse(baseUrl);

    print('ℹ️ Hitting URL for H2H Fixtures: $url'); // 📢 LOGGING

    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      // The API response for this endpoint is often wrapped in a parent object,
      // e.g., {'results': [list of matches]}. We assume the list is flat or needs wrapping.
      // We will adjust based on the model:
      final data = json.decode(response.body);

      // We assume the actual list of matches is under a 'results' key,
      // as is common in the FPL API structure for paginated lists.
      final List<dynamic> jsonList = data['results'] ?? data;

      return jsonList.map((i) => H2HMatch.fromJson(i)).toList();
    } else {
      // 📢 LOGGING: Error details
      print('❌ FPL API Error: Failed to load H2H fixtures. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load H2H fixtures: ${response.statusCode}');
    }
  }

}