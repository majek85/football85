  class Match {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogo;
  final String? awayLogo;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final String elapsed;
  final String league;
  final String? leagueLogo;
  final String? homeScorers;
  final String? awayScorers;
  final String? date;
  final List<String>? channels;
  final int? leagueId;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogo,
    this.awayLogo,
    this.homeScore,
    this.awayScore,
    required this.status,
    required this.elapsed,
    required this.league,
    this.leagueLogo,
    this.homeScorers,
    this.awayScorers,
    this.date,
    this.channels,
    this.leagueId,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] is int ? json['id'] : 0,
      homeTeam: json['homeTeam'] ?? 'Unknown',
      awayTeam: json['awayTeam'] ?? 'Unknown',
      homeScore: json['score']?['home'],
      awayScore: json['score']?['away'],
      status: json['status'] ?? '',
      elapsed: json['elapsed']?.toString() ?? '',
      league: json['league'] ?? '',
      date: json['date'],
    );
  }

  // --- Local Serialization for Caching ---
  Map<String, dynamic> toJsonLocal() {
    return {
      'id': id,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeLogo': homeLogo,
      'awayLogo': awayLogo,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'status': status,
      'elapsed': elapsed,
      'league': league,
      'leagueLogo': leagueLogo,
      'homeScorers': homeScorers,
      'awayScorers': awayScorers,
      'date': date,
      'channels': channels,
      'leagueId': leagueId,
    };
  }

  factory Match.fromJsonLocal(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      homeLogo: json['homeLogo'],
      awayLogo: json['awayLogo'],
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      status: json['status'],
      elapsed: json['elapsed'],
      league: json['league'],
      leagueLogo: json['leagueLogo'],
      homeScorers: json['homeScorers'],
      awayScorers: json['awayScorers'],
      date: json['date'],
      channels: json['channels'] != null ? List<String>.from(json['channels']) : null,
      leagueId: json['leagueId'],
    );
  }
}
