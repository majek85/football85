import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/match_model.dart';
import '../providers/matches_provider.dart';
import '../providers/language_provider.dart';
import 'match_details_screen.dart';

class TeamProfileScreen extends StatelessWidget {
  final String teamName;
  final String? teamLogo;

  const TeamProfileScreen({
    super.key,
    required this.teamName,
    this.teamLogo,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final matchesProvider = context.watch<MatchesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter matches involving this team from the existing data
    final List<Match> teamMatches = [];
    
    // Check live matches
    for (var m in matchesProvider.liveMatches) {
      if (m.homeTeam == teamName || m.awayTeam == teamName) teamMatches.add(m);
    }
    
    // Check daily matches
    for (var dayMatches in matchesProvider.matchesByDate.values) {
      for (var m in dayMatches) {
        if (m.homeTeam == teamName || m.awayTeam == teamName) teamMatches.add(m);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDark, matchesProvider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                langProvider.isArabic ? "المباريات الأخيرة والقادمة" : "Recent & Upcoming Matches",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          teamMatches.isEmpty
              ? _buildEmptyState(context, langProvider)
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final match = teamMatches[index];
                      return _buildMatchTile(context, match, isDark);
                    },
                    childCount: teamMatches.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, MatchesProvider provider) {
    final isFavorite = provider.favoriteTeams.contains(teamName);

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark 
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                      : [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                ),
              ),
            ),
            // Profile Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: teamLogo != null 
                      ? CachedNetworkImage(
                          imageUrl: teamLogo!,
                          width: 80,
                          height: 80,
                          errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 80, color: Colors.grey),
                        )
                      : const Icon(Icons.shield, size: 80, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: Colors.white,
          ),
          onPressed: () => provider.toggleTeam(teamName),
        ),
      ],
    );
  }

  Widget _buildMatchTile(BuildContext context, Match match, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailsScreen(match: match),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.league,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSmallTeam(match.homeTeam, match.homeLogo),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("vs", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                        _buildSmallTeam(match.awayTeam, match.awayLogo),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    match.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: match.status.contains("'") ? Colors.red : Theme.of(context).primaryColor,
                    ),
                  ),
                  if (match.homeScore != null)
                    Text(
                      "${match.homeScore} - ${match.awayScore}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallTeam(String name, String? logo) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logo != null)
            CachedNetworkImage(imageUrl: logo, width: 20, height: 20)
          else
            const Icon(Icons.shield, size: 20),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, LanguageProvider lang) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              lang.isArabic ? "لا توجد مباريات مجدولة حالياً" : "No scheduled matches found",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
