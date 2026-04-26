import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/matches_provider.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> topLeagues = [
    {'name': 'Premier League', 'logo': 'https://media.api-sports.io/football/leagues/39.png'},
    {'name': 'Championship', 'logo': 'https://media.api-sports.io/football/leagues/40.png'},
    {'name': 'League One', 'logo': 'https://media.api-sports.io/football/leagues/41.png'},
    {'name': 'FA Cup', 'logo': 'https://media.api-sports.io/football/leagues/45.png'},
    {'name': 'EFL Cup', 'logo': 'https://media.api-sports.io/football/leagues/48.png'},
    {'name': 'Community Shield', 'logo': 'https://media.api-sports.io/football/leagues/528.png'},
    {'name': 'La Liga', 'logo': 'https://media.api-sports.io/football/leagues/140.png'},
    {'name': 'UEFA Champions', 'logo': 'https://media.api-sports.io/football/leagues/2.png'},
    {'name': 'Serie A', 'logo': 'https://media.api-sports.io/football/leagues/135.png'},
    {'name': 'Bundesliga', 'logo': 'https://media.api-sports.io/football/leagues/78.png'},
    {'name': 'Ligue 1', 'logo': 'https://media.api-sports.io/football/leagues/61.png'},
    {'name': 'Saudi Pro', 'logo': 'https://media.api-sports.io/football/leagues/307.png'},
  ];

  final List<Map<String, String>> topTeams = [
    {'name': 'Real Madrid', 'logo': 'https://media.api-sports.io/football/teams/541.png'},
    {'name': 'Barcelona', 'logo': 'https://media.api-sports.io/football/teams/529.png'},
    {'name': 'Man City', 'logo': 'https://media.api-sports.io/football/teams/50.png'},
    {'name': 'Arsenal', 'logo': 'https://media.api-sports.io/football/teams/42.png'},
    {'name': 'Liverpool', 'logo': 'https://media.api-sports.io/football/teams/40.png'},
    {'name': 'Man United', 'logo': 'https://media.api-sports.io/football/teams/33.png'},
    {'name': 'Chelsea', 'logo': 'https://media.api-sports.io/football/teams/49.png'},
    {'name': 'Bayern Munich', 'logo': 'https://media.api-sports.io/football/teams/157.png'},
  ];

  void _nextPage() {
    if (_currentPage == 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _finishOnboarding() {
    context.read<MatchesProvider>().completeOnboarding();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(langProvider.welcomeTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(langProvider.btnSkip, style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => langProvider.toggleLanguage(),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Force using buttons
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildSelectionGrid(
                    title: langProvider.selectLeaguesTitle,
                    items: topLeagues,
                    isLeague: true,
                  ),
                  _buildSelectionGrid(
                    title: langProvider.selectTeamsTitle,
                    items: topTeams,
                    isLeague: false,
                  ),
                ],
              ),
            ),
            _buildBottomControls(langProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionGrid({required String title, required List<Map<String, String>> items, required bool isLeague}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildSelectionCard(items[index], isLeague);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(Map<String, String> item, bool isLeague) {
    final provider = context.watch<MatchesProvider>();
    final isSelected = isLeague 
        ? provider.favoriteLeagues.contains(item['name'])
        : provider.favoriteTeams.contains(item['name']);

    return GestureDetector(
      onTap: () {
        if (isLeague) {
          provider.toggleLeague(item['name']!);
        } else {
          provider.toggleTeam(item['name']!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected) 
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CachedNetworkImage(
                imageUrl: item['logo']!,
                width: 40,
                height: 40,
                errorWidget: (_, __, ___) => const Icon(Icons.shield, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item['name']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(LanguageProvider langProvider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildDot(0),
              const SizedBox(width: 8),
              _buildDot(1),
            ],
          ),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              _currentPage == 0 ? langProvider.btnContinue : langProvider.btnFinish,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
