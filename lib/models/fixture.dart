// lib/models/fixture.dart

class Fixture {
  final String homeTeam;
  final String awayTeam;
  final int? homeScore; // Made nullable
  final int? awayScore; // Made nullable
  final DateTime kickoffTime; // Changed to non-nullable DateTime
  final bool started; // Added required property
  final bool finished;

  Fixture({
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.kickoffTime,
    required this.started,
    required this.finished,
  });

  // ⚡ FIX: Make the score parsing helper a static method
  static int? _safeParseScore(dynamic value) {
    if (value == null) {
      return null; // Return null if score is missing
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value); // returns null if parsing fails
    }
    return null;
  }

  factory Fixture.fromJson(
      Map<String, dynamic> json, Map<int, String> teamIdMap) {

    // 'finished' and 'started' are standard FPL keys
    final bool isFinished = json['finished'] as bool? ?? false;
    final bool hasStarted = json['started'] as bool? ?? false;

    // Use safe parsing helper function to handle nulls and mixed types
    final int? homeScore = _safeParseScore(json['team_h_score']);
    final int? awayScore = _safeParseScore(json['team_a_score']);

    // Parse kickoff_time string into DateTime object. Fallback to current time if null.
    final String? kickoffTimeString = json['kickoff_time'] as String?;
    final DateTime parsedKickoffTime = kickoffTimeString != null
        ? DateTime.tryParse(kickoffTimeString) ?? DateTime.now()
        : DateTime.now();


    return Fixture(
      // Map team IDs to team names using the provided map
      homeTeam: teamIdMap[json['team_h'] as int] ?? 'Unknown',
      awayTeam: teamIdMap[json['team_a'] as int] ?? 'Unknown',

      homeScore: homeScore,
      awayScore: awayScore,

      kickoffTime: parsedKickoffTime,
      started: hasStarted,
      finished: isFinished,
    );
  }
}