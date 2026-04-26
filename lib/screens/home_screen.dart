import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../providers/matches_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../models/match_model.dart';
// import 'league_selection_screen.dart';
import 'match_details_screen.dart';
import 'manage_favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MatchesProvider>();
      provider.fetchLiveMatches();
      provider.fetchMultiDayMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.title),
        leading: IconButton(
          icon: Icon(Icons.filter_list_rounded, color: Theme.of(context).primaryColor),
          onPressed: () => setState(() => _selectedIndex = 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => langProvider.toggleLanguage(),
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Consumer<MatchesProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  _buildSimpleTabBar(provider, langProvider),
                  Expanded(
                    child: provider.isLoading
                        ? _buildShimmer()
                        : provider.errorMessage != null
                            ? _buildError(provider)
                            : _buildMainContent(provider, langProvider),
                  ),
                ],
              );
            },
          ),
          const ManageFavoritesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(langProvider),
    );
  }

  Widget _buildSimpleTabBar(MatchesProvider provider, LanguageProvider langProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton(langProvider.tabLive, 'live', provider),
          _tabButton(langProvider.tabAll, 'calendar', provider),
        ],
      ),
    );
  }

  Widget _tabButton(String label, String value, MatchesProvider provider) {
    final isSelected = provider.selectedTab == value;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTab(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white) : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(MatchesProvider provider, LanguageProvider langProvider) {
    if (provider.selectedTab == 'live') {
      return _buildMatchList(provider.liveMatches, provider, langProvider);
    } else {
      return _buildContinuousList(provider, langProvider);
    }
  }

  Widget _buildContinuousList(MatchesProvider provider, LanguageProvider langProvider) {
    if (provider.matchesByDate.isEmpty) {
      return _noMatches(langProvider);
    }

    final dates = provider.matchesByDate.keys.toList()..sort();
    
    return RefreshIndicator(
      onRefresh: () => provider.fetchMultiDayMatches(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final dateStr = dates[index];
          final matches = provider.matchesByDate[dateStr]!;
          final grouped = provider.groupMatchesByTournament(matches);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateStr, langProvider),
              ...grouped.entries.map((entry) => _buildTournamentGroup(entry.key, entry.value)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(String dateStr, LanguageProvider langProvider) {
    final date = DateTime.parse(dateStr);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;
    final label = isToday ? langProvider.today : DateFormat('EEEE, d MMMM').format(date).toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 8, right: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w900,
          fontSize: 15,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTournamentGroup(String leagueName, List<Match> matches) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              if (matches.first.leagueLogo != null)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: matches.first.leagueLogo!, 
                    width: 20, 
                    height: 20
                  ),
                ),
              const SizedBox(width: 10),
              Text(
                leagueName, 
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, 
                  fontSize: 14, 
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                )
              ),
            ],
          ),
        ),
        ...matches.map((m) => _buildMatchCardGlassmorphism(m)),
      ],
    );
  }

  Widget _buildMatchList(List<Match> matches, MatchesProvider provider, LanguageProvider langProvider) {
    if (matches.isEmpty) return _noMatches(langProvider);
    
    final grouped = provider.groupMatchesByTournament(matches);
    
    if (grouped.isEmpty) {
      return _buildEmptySelectionsState(langProvider);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchLiveMatches();
        await provider.fetchMultiDayMatches();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        children: grouped.entries.map((entry) => _buildTournamentGroup(entry.key, entry.value)).toList(),
      ),
    );
  }

  Widget _buildEmptySelectionsState(LanguageProvider lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.filter_list_off, size: 64, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            Text(
              lang.isArabic ? "لا توجد مباريات لمفضلاتك" : "No matches for your favorites",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              lang.isArabic 
                ? "قم باختيار المزيد من البطولات لعرض مبارياتها هنا" 
                : "Select more tournaments to see their matches here",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1; // Go to Leagues tab
                });
              },
              icon: const Icon(Icons.add),
              label: Text(lang.isArabic ? "إدارة الاختيارات" : "Manage Selections"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCardGlassmorphism(Match match) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLive = match.status.contains("'") || match.status.toLowerCase().contains("live");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: match)),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.08),
                      Theme.of(context).cardTheme.color!.withOpacity(0.4),
                    ]
                  : [
                      Colors.white,
                      Theme.of(context).cardTheme.color!,
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Column(
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home Team (Left)
              Expanded(
                child: Column(
                  children: [
                    if (match.homeLogo != null)
                      CachedNetworkImage(
                        imageUrl: match.homeLogo!,
                        width: 45,
                        height: 45,
                        errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 45, color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      match.homeTeam,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Center: Scores and Time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      match.homeScore != null && match.awayScore != null
                          ? '${match.homeScore} - ${match.awayScore}'
                          : 'VS',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive ? Colors.redAccent.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(12),
                        border: isLive ? Border.all(color: Colors.redAccent.withOpacity(0.5)) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLive) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            match.status,
                            style: TextStyle(
                              color: isLive ? Colors.redAccent : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Away Team (Right)
              Expanded(
                child: Column(
                  children: [
                    if (match.awayLogo != null)
                      CachedNetworkImage(
                        imageUrl: match.awayLogo!,
                        width: 45,
                        height: 45,
                        errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 45, color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      match.awayTeam,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Optional Bottom Information Space (Scorers)
          if ((match.homeScorers != null && match.homeScorers!.isNotEmpty) || 
              (match.awayScorers != null && match.awayScorers!.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.homeScorers ?? '',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant, 
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.sports_soccer, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                ),
                Expanded(
                  child: Text(
                    match.awayScorers ?? '',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant, 
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ]
        ],
      ), // closes Column
    ), // closes Container
    
    // Notification Icon
    Positioned(
      top: 10,
      right: 10,
      child: Consumer<MatchesProvider>(
        builder: (context, provider, child) {
          final isFollowed = provider.followedMatchIds.contains(match.id);
          return GestureDetector(
            onTap: () => provider.toggleFollowMatch(match.id),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isFollowed ? Colors.amber.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFollowed ? Icons.notifications_active : Icons.notifications_none,
                size: 18,
                color: isFollowed ? Colors.amber : Colors.grey.withOpacity(0.5),
              ),
            ),
          );
        },
      ),
    ),
    ],
    )); // closes Stack and GestureDetector
  }

  Widget _noMatches(LanguageProvider langProvider) {
    return Center(child: Text(langProvider.noMatches, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)));
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardTheme.color!, 
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(12), itemCount: 5,
        itemBuilder: (_, __) => Container(height: 100, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildError(MatchesProvider provider) {
    return Center(child: Text('Error: ${provider.errorMessage}', style: const TextStyle(color: Colors.red)));
  }

  Widget _buildBottomNav(LanguageProvider langProvider) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: langProvider.navMatches),
        BottomNavigationBarItem(icon: const Icon(Icons.emoji_events), label: langProvider.navLeagues),
        BottomNavigationBarItem(icon: const Icon(Icons.person), label: langProvider.navProfile),
      ],
    );
  }
}


