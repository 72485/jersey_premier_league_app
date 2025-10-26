// lib/models/standing_entry.dart

class StandingEntry {
  final int rank;
  final int totalPoints;
  final int entryId;
  final String teamName;
  final String? playerName; // Made nullable (String?)

  StandingEntry({
    required this.rank,
    required this.totalPoints,
    required this.entryId,
    required this.teamName,
    this.playerName, // Optional in constructor
  });

  factory StandingEntry.fromJson(Map<String, dynamic> json) {
    return StandingEntry(
      // Keys matching the /leagues-classic/{id}/standings API endpoint
      rank: (json['rank'] as int?) ?? 0,
      totalPoints: (json['total'] as int?) ?? 0,
      entryId: (json['entry'] as int?) ?? 0,
      teamName: (json['entry_name'] as String?) ?? 'Unknown Team',
      playerName: (json['player_name'] as String?) ?? 'Unknown Manager',
    );
  }
}