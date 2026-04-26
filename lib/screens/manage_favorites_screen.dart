import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/matches_provider.dart';
import '../providers/language_provider.dart';

class ManageFavoritesScreen extends StatefulWidget {
  const ManageFavoritesScreen({super.key});

  @override
  State<ManageFavoritesScreen> createState() => _ManageFavoritesScreenState();
}

class _ManageFavoritesScreenState extends State<ManageFavoritesScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final Map<String, List<Map<String, dynamic>>> europeHierarchy = {
    'England 🏴󠁧󠁢󠁥󠁮󠁧󠁿': [{'name': 'Premier League', 'logo': '39'}, {'name': 'FA Cup', 'logo': '45'}],
    'Spain 🇪🇸': [{'name': 'La Liga', 'logo': '140'}, {'name': 'Copa del Rey', 'logo': '143'}],
    'Italy 🇮🇹': [{'name': 'Serie A', 'logo': '135'}, {'name': 'Coppa Italia', 'logo': '137'}],
    'Germany 🇩🇪': [{'name': 'Bundesliga', 'logo': '78'}, {'name': 'DFB-Pokal', 'logo': '81'}],
    'France 🇫🇷': [{'name': 'Ligue 1', 'logo': '61'}],
  };

  final Map<String, List<Map<String, dynamic>>> gulfHierarchy = {
    'Saudi Arabia 🇸🇦': [{'name': 'Saudi Pro League', 'logo': '307'}, {'name': 'King Cup', 'logo': '525'}],
    'UAE 🇦🇪': [{'name': 'UAE Pro League', 'logo': '301'}],
    'Qatar 🇶🇦': [{'name': 'Qatar Stars League', 'logo': '305'}],
  };

  final Map<String, List<Map<String, dynamic>>> asiaHierarchy = {
    'Japan 🇯🇵': [{'name': 'J1 League', 'logo': '196'}, {'name': 'Emperor Cup', 'logo': '196'}],
    'South Korea 🇰🇷': [{'name': 'K League 1', 'logo': '292'}],
    'China 🇨🇳': [{'name': 'Chinese Super League', 'logo': '169'}],
  };

  final Map<String, List<Map<String, dynamic>>> africaHierarchy = {
    'Egypt 🇪🇬': [{'name': 'Egypt Premier League', 'logo': '233'}, {'name': 'Egypt Cup', 'logo': '233'}],
    'Morocco 🇲🇦': [{'name': 'Botola Pro', 'logo': '200'}],
    'Algeria 🇩🇿': [{'name': 'Algerian Ligue Professionnelle 1', 'logo': '116'}],
  };

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildSearchHeader(isDark, langProvider),
        _buildUserSelectionHeader(isDark, langProvider),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (_searchQuery.isEmpty) ...[
                _buildSectionTitle(langProvider.isArabic ? "أوروبا 🇪🇺" : "Europe 🇪🇺"),
                ...europeHierarchy.entries.map((e) => _buildCountryExpansionTile(e.key, e.value, isDark)).toList(),
                
                _buildSectionTitle(langProvider.isArabic ? "دول الخليج 🏜️" : "Arab Gulf 🏜️"),
                ...gulfHierarchy.entries.map((e) => _buildCountryExpansionTile(e.key, e.value, isDark)).toList(),

                _buildSectionTitle(langProvider.isArabic ? "آسيا 🌏" : "Asia 🌏"),
                ...asiaHierarchy.entries.map((e) => _buildCountryExpansionTile(e.key, e.value, isDark)).toList(),

                _buildSectionTitle(langProvider.isArabic ? "أفريقيا 🐘" : "Africa 🐘"),
                ...africaHierarchy.entries.map((e) => _buildCountryExpansionTile(e.key, e.value, isDark)).toList(),
              ] else ...[
                _buildSearchResults(isDark),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(bool isDark, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: lang.isArabic ? "ابحث عن دولة أو بطولة..." : "Search country or league...",
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blue),
      ),
    );
  }

  Widget _buildCountryExpansionTile(String country, List<Map<String, dynamic>> leagues, bool isDark) {
    final provider = context.watch<MatchesProvider>();
    int selectedCount = leagues.where((l) => provider.favoriteLeagues.contains(l['name'])).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: selectedCount > 0 ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Text(country.split(' ').last, style: const TextStyle(fontSize: 24)),
          title: Text(
            country.split(' ').sublist(0, country.split(' ').length - 1).join(' '), 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: selectedCount > 0 ? Colors.blue : null)
          ),
          trailing: selectedCount > 0 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                child: Text(selectedCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            : const Icon(Icons.keyboard_arrow_down, size: 20),
          children: leagues.map((league) => _buildLeagueSelectionRow(league, isDark)).toList(),
        ),
      ),
    );
  }

  Widget _buildLeagueSelectionRow(Map<String, dynamic> league, bool isDark) {
    final provider = context.watch<MatchesProvider>();
    final isSelected = provider.favoriteLeagues.contains(league['name']);

    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 0, 16, 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.emoji_events, size: 18, color: Colors.amber),
        title: Text(
          league['name'], 
          style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
        ),
        trailing: Checkbox(
          value: isSelected,
          activeColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) => provider.toggleLeague(league['name']),
        ),
      ),
    );
  }

  Widget _buildUserSelectionHeader(bool isDark, LanguageProvider lang) {
    final provider = context.watch<MatchesProvider>();
    if (provider.favoriteLeagues.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.blue, size: 14),
          const SizedBox(width: 8),
          Text(
            "${provider.favoriteLeagues.length} ${lang.isArabic ? 'بطولة مفعلة' : 'Leagues Active'}",
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(lang.isArabic ? "مراجعة الكل" : "Review All", style: const TextStyle(fontSize: 10)),
          )
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    List<Map<String, dynamic>> results = [];
    final allHierarchies = [europeHierarchy, gulfHierarchy, asiaHierarchy, africaHierarchy];
    for (var hierarchy in allHierarchies) {
      hierarchy.forEach((country, leagues) {
        if (country.toLowerCase().contains(_searchQuery.toLowerCase())) {
          results.addAll(leagues);
        } else {
          for (var l in leagues) {
            if (l['name'].toLowerCase().contains(_searchQuery.toLowerCase())) {
              results.add(l);
            }
          }
        }
      });
    }

    if (results.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("لا توجد نتائج...")));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildLeagueSelectionRow(results[index], isDark),
    );
  }
}
