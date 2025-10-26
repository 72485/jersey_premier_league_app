// lib/models/league.dart

class League {
  final int id;
  final String name;
  final String type; // classic or h2h
  final int rank;

  League({
    required this.id,
    required this.name,
    required this.type,
    required this.rank,
  });

  // Factory method updated to accept 'type' as a NAMED argument
  factory League.fromJson(Map<String, dynamic> json, {required String type}) {
    return League(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? 'Unknown League',
      type: type, // Value passed from FplService
      rank: (json['entry_rank'] as int?) ?? 0, // Your current rank in the league
    );
  }
}