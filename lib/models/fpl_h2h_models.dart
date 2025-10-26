class H2HLeagueResponse {
  final List<H2HStanding> standings;
  final bool hasNext;

  H2HLeagueResponse({required this.standings, required this.hasNext});

  factory H2HLeagueResponse.fromJson(Map<String, dynamic> json) {
    return H2HLeagueResponse(
      standings: (json['standings'] as List)
          .map((i) => H2HStanding.fromJson(i))
          .toList(),
      hasNext: json['has_next'] as bool? ?? false,
    );
  }
}

class H2HStanding {
  final int entryId;
  final int rank;
  final String teamName;
  final String playerName;
  final int matchesPlayed;
  final int won;
  final int drawn;
  final int lost;
  final int pointsFor; // Total FPL points scored by this team in H2H matches
  final int total; // Total H2H points (3 for win, 1 for draw)

  H2HStanding({
    required this.entryId,
    required this.rank,
    required this.teamName,
    required this.playerName,
    required this.matchesPlayed,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.pointsFor,
    required this.total,
  });

  factory H2HStanding.fromJson(Map<String, dynamic> json) {
    return H2HStanding(
      entryId: json['entry_id'] as int,
      rank: json['rank'] as int,
      teamName: json['entry_name'] as String,
      playerName: json['player_name'] as String,
      matchesPlayed: json['matches_played'] as int,
      won: json['won'] as int,
      drawn: json['drawn'] as int,
      lost: json['lost'] as int,
      pointsFor: json['points_for'] as int,
      total: json['total'] as int,
    );
  }
}

class H2HMatch {
  final int event; // Gameweek
  final H2HTeam homeTeam;
  final H2HTeam awayTeam;
  final bool finished;

  H2HMatch({
    required this.event,
    required this.homeTeam,
    required this.awayTeam,
    required this.finished,
  });

  factory H2HMatch.fromJson(Map<String, dynamic> json) {
    return H2HMatch(
      event: json['event'] as int,
      homeTeam: H2HTeam.fromJson(json['home_team']),
      awayTeam: H2HTeam.fromJson(json['away_team']),
      finished: json['finished'] as bool,
    );
  }
}

class H2HTeam {
  final int entry; // FPL Team ID
  final String teamName;
  final String playerName;
  final int points;

  H2HTeam({
    required this.entry,
    required this.teamName,
    required this.playerName,
    required this.points,
  });

  factory H2HTeam.fromJson(Map<String, dynamic> json) {
    return H2HTeam(
      entry: json['entry'] as int,
      teamName: json['entry_name'] as String,
      playerName: json['player_name'] as String,
      points: json['points'] as int,
    );
  }
}
