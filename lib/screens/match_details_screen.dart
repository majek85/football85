import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../providers/language_provider.dart';
import '../providers/matches_provider.dart';
import 'team_profile_screen.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  int _homePredicted = 0;
  int _awayPredicted = 0;

  @override
  void initState() {
    super.initState();
    if (widget.match.leagueId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MatchesProvider>().fetchAndCacheStandings(widget.match.leagueId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Consumer<MatchesProvider>(
              builder: (context, provider, child) {
                final isFollowed = provider.followedMatchIds.contains(widget.match.id);
                return IconButton(
                  icon: Icon(
                    isFollowed ? Icons.notifications_active : Icons.notifications_none,
                    color: isFollowed ? Colors.amber : Colors.white,
                  ),
                  onPressed: () => provider.toggleFollowMatch(widget.match.id),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildMatchHeader(context, isDark),
            Container(
              color: Theme.of(context).cardTheme.color,
              child: TabBar(
                isScrollable: true,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                tabs: [
                  Tab(text: langProvider.tabTimeline, icon: const Icon(Icons.timeline)),
                  Tab(text: langProvider.tabLineups, icon: const Icon(Icons.groups)),
                  Tab(text: langProvider.tabStats, icon: const Icon(Icons.bar_chart)),
                  Tab(text: langProvider.isArabic ? "توقعات" : "Prediction", icon: const Icon(Icons.casino)),
                  Tab(text: langProvider.isArabic ? "الترتيب" : "Standings", icon: const Icon(Icons.leaderboard)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTimelineTab(context, isDark),
                  _buildLineupsTab(context, isDark),
                  _buildStatsTab(context, isDark),
                  _buildPredictionTab(context, isDark),
                  _buildStandingsTab(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.match.league,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeamColumn(context, widget.match.homeTeam, widget.match.homeLogo),
              _buildScoreCenter(context),
              _buildTeamColumn(context, widget.match.awayTeam, widget.match.awayLogo),
            ],
          ),
          if (widget.match.channels != null && widget.match.channels!.isNotEmpty) ...[
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.match.channels!.map((channel) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tv, size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        channel,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamColumn(BuildContext context, String teamName, String? logoUrl) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamProfileScreen(teamName: teamName, teamLogo: logoUrl),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: logoUrl != null 
                  ? CachedNetworkImage(imageUrl: logoUrl, width: 60, height: 60, errorWidget: (_,__,___) => const Icon(Icons.shield, color: Colors.white))
                  : const Icon(Icons.shield, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              teamName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCenter(BuildContext context) {
    final bool isLive = widget.match.status.contains("'");
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.match.homeScore?.toString() ?? '-',
              style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -2),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(":", style: TextStyle(color: Colors.white54, fontSize: 32, fontWeight: FontWeight.w300)),
            ),
            Text(
              widget.match.awayScore?.toString() ?? '-',
              style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -2),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isLive ? Colors.red : Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.match.status,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildTimelineItem(context, "Rice 90+2'", "Goal!", Icons.sports_soccer, true),
        _buildTimelineItem(context, "Mudryk 89'", "Goal!", Icons.sports_soccer, false),
        _buildTimelineItem(context, "Jackson 55'", "Goal!", Icons.sports_soccer, false),
        _buildTimelineItem(context, "Saka 44'", "Goal!", Icons.sports_soccer, true),
        _buildTimelineItem(context, "Sterling 9'", "Goal!", Icons.sports_soccer, false),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, String title, String subtitle, IconData icon, bool isHome) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isHome) const Spacer(),
          Column(
            crossAxisAlignment: isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isHome) Icon(icon, size: 16, color: Theme.of(context).primaryColor),
                  if (!isHome) const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (isHome) const SizedBox(width: 8),
                  if (isHome) Icon(icon, size: 16, color: Theme.of(context).primaryColor),
                ],
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          if (isHome) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLineupsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTeamLineup(context, widget.match.homeTeam, ["Raya", "White", "Saliba", "Gabriel", "Zinchenko", "Rice", "Odegaard", "Havertz", "Saka", "Jesus", "Martinelli"]),
          const SizedBox(height: 32),
          _buildTeamLineup(context, widget.match.awayTeam, ["Sanchez", "James", "Silva", "Colwill", "Cucurella", "Enzo", "Caicedo", "Gallagher", "Sterling", "Jackson", "Palmer"]),
        ],
      ),
    );
  }

  Widget _buildTeamLineup(BuildContext context, String team, List<String> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(team, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.blue)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: players.map((p) => Chip(
            label: Text(p, style: const TextStyle(fontSize: 12)),
            backgroundColor: Theme.of(context).cardTheme.color,
            side: BorderSide(color: Colors.blue.withOpacity(0.1)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsTab(BuildContext context, bool isDark) {
    if (widget.match.homeScore == null) {
      return Center(
        child: Text(
          "Stats not available until match starts",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStatRow(context, "Possession", 55, 45),
        _buildStatRow(context, "Shots on Target", 8, 3),
        _buildStatRow(context, "Total Shots", 14, 10),
        _buildStatRow(context, "Corners", 6, 4),
        _buildStatRow(context, "Offsides", 2, 1),
        _buildStatRow(context, "Fouls", 10, 12),
        _buildStatRow(context, "Yellow Cards", 1, 3),
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, int homeValue, int awayValue) {
    final double total = (homeValue + awayValue).toDouble();
    final double homeWidth = total == 0 ? 0.5 : homeValue / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(homeValue.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
              Text(awayValue.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (homeWidth * 100).toInt(),
                    child: Container(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: ((1 - homeWidth) * 100).toInt(),
                    child: Container(color: Colors.grey.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionTab(BuildContext context, bool isDark) {
    final provider = context.watch<MatchesProvider>();
    final savedPrediction = provider.predictions[widget.match.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.casino, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            savedPrediction != null ? "توقعك المسجل" : "توقع نتيجة المباراة",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          if (savedPrediction == null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPredictCounter(widget.match.homeTeam, _homePredicted, (val) => setState(() => _homePredicted = val)),
                const Text("VS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100)),
                _buildPredictCounter(widget.match.awayTeam, _awayPredicted, (val) => setState(() => _awayPredicted = val)),
              ],
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                provider.setMatchPrediction(widget.match.id, "$_homePredicted - $_awayPredicted");
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ توقعك بنجاح!")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("تأكيد التوقع", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Text(
                savedPrediction,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => provider.setMatchPrediction(widget.match.id, ""), // Just for demo to reset
              child: const Text("تعديل التوقع", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPredictCounter(String team, int value, Function(int) onChanged) {
    return Column(
      children: [
        Text(team, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _counterBtn(Icons.remove, () => value > 0 ? onChanged(value - 1) : null),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(value.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ),
            _counterBtn(Icons.add, () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
    );
  }

  Widget _buildStandingsTab(BuildContext context, bool isDark) {
    final provider = context.watch<MatchesProvider>();
    List<dynamic>? leagueStandings = widget.match.leagueId != null ? provider.standings[widget.match.leagueId] : null;

    // Use Mock if no data or for demo
    if (leagueStandings == null || leagueStandings.isEmpty) {
      leagueStandings = [
        {'rank': 1, 'team': {'name': 'Arsenal', 'logo': 'https://media.api-sports.io/football/teams/42.png'}, 'played': 30, 'points': 71},
        {'rank': 2, 'team': {'name': 'Liverpool', 'logo': 'https://media.api-sports.io/football/teams/40.png'}, 'played': 30, 'points': 70},
        {'rank': 3, 'team': {'name': 'Man City', 'logo': 'https://media.api-sports.io/football/teams/50.png'}, 'played': 30, 'points': 67},
        {'rank': 4, 'team': {'name': 'Aston Villa', 'logo': 'https://media.api-sports.io/football/teams/66.png'}, 'played': 31, 'points': 60},
        {'rank': 5, 'team': {'name': 'Spurs', 'logo': 'https://media.api-sports.io/football/teams/47.png'}, 'played': 30, 'points': 57},
      ];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            _buildStandingsHeader(),
            const Divider(height: 1),
            ...leagueStandings.map((s) => _buildStandingsRow(context, s)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("#", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text("Team", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          SizedBox(width: 40, child: Text("PL", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          SizedBox(width: 50, child: Text("PTS", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
        ],
      ),
    );
  }

  Widget _buildStandingsRow(BuildContext context, dynamic s) {
    final String teamName = s['team']['name'];
    final bool isCurrentMatchTeam = teamName == widget.match.homeTeam || teamName == widget.match.awayTeam;

    return Container(
      color: isCurrentMatchTeam ? Colors.blue.withOpacity(0.05) : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 30, 
            child: Text(
              s['rank'].toString(), 
              style: TextStyle(
                fontWeight: s['rank'] <= 4 ? FontWeight.bold : FontWeight.normal,
                color: s['rank'] <= 4 ? Colors.blue : null,
              )
            )
          ),
          Expanded(
            child: Row(
              children: [
                if (s['team']['logo'] != null)
                  CachedNetworkImage(imageUrl: s['team']['logo'], width: 24, height: 24),
                const SizedBox(width: 10),
                Text(teamName, style: TextStyle(fontWeight: isCurrentMatchTeam ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
          SizedBox(width: 40, child: Text(s['played'].toString(), textAlign: TextAlign.center)),
          SizedBox(width: 50, child: Text(s['points'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
