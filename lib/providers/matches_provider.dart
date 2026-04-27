import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';

class MatchesProvider with ChangeNotifier {
  Map<String, List<Match>> matchesByDate = {};
  List<Match> liveMatches = [];
  Set<String> favoriteLeagues = {};
  Set<String> favoriteTeams = {};
  Set<int> followedMatchIds = {};
  bool notifyMatchStart = true;
  bool notifyGoals = true;
  bool hasFinishedOnboarding = false;
  bool isLoading = false;
  String? errorMessage;
  String selectedTab = 'live';
  Map<int, String> predictions = {};
  Map<int, List<dynamic>> standings = {};

  // Database of ALL major world competitions
  final Map<String, List<String>> countryBundles = {
    'England 🏴󠁧󠁢󠁥󠁮󠁧󠁿': ['Premier League', 'FA Cup', 'EFL Cup', 'Community Shield', 'Championship'],
    'Spain 🇪🇸': ['La Liga', 'Copa del Rey', 'Supercopa de España', 'Segunda División'],
    'Italy 🇮🇹': ['Serie A', 'Coppa Italia', 'Supercoppa Italiana', 'Serie B'],
    'Germany 🇩🇪': ['Bundesliga', 'DFB-Pokal', 'DFL-Supercup', '2. Bundesliga'],
    'France 🇫🇷': ['Ligue 1', 'Coupe de France', 'Trophée des Champions', 'Ligue 2'],
    'Portugal 🇵🇹': ['Primeira Liga', 'Taça de Portugal', 'Taça da Liga'],
    'Netherlands 🇳🇱': ['Eredivisie', 'KNVB Beker', 'Johan Cruyff Shield'],
    'Turkey 🇹🇷': ['Süper Lig', 'Turkish Cup', 'Turkish Super Cup'],
    'Saudi Arabia 🇸🇦': ['Saudi Pro League', 'King Cup', 'Saudi Super Cup', 'First Division'],
    'Qatar 🇶🇦': ['Qatar Stars League', 'Qatar Cup', 'Emir Cup'],
    'UAE 🇦🇪': ['UAE Pro League', 'President Cup', 'League Cup'],
    'Egypt 🇪🇬': ['Egypt Premier League', 'Egypt Cup', 'Egyptian Super Cup'],
    'Morocco 🇲🇦': ['Botola Pro', 'Moroccan Throne Cup'],
    'Algeria 🇩🇿': ['Algerian Ligue Professionnelle 1', 'Algerian Cup'],
    'Tunisia 🇹🇳': ['Tunisian Ligue Professionnelle 1', 'Tunisian Cup'],
    'Brazil 🇧🇷': ['Série A', 'Copa do Brasil', 'Supercopa do Brasil'],
    'Argentina 🇦🇷': ['Primera División', 'Copa Argentina', 'Supercopa Argentina'],
    'USA 🇺🇸': ['MLS', 'US Open Cup'],
    
    // International / Qualifiers Bundles (The missing piece)
    'World Cup & Qualifiers 🏆': [
      'FIFA World Cup',
      'World Cup Qualifiers - Europe',
      'World Cup Qualifiers - Africa',
      'World Cup Qualifiers - Asia',
      'World Cup Qualifiers - South America',
      'World Cup Qualifiers - North America'
    ],
    'Continental Nations 🌍': [
      'UEFA Euro',
      'Copa America',
      'Africa Cup of Nations',
      'AFC Asian Cup',
      'UEFA Nations League',
      'CONCACAF Gold Cup'
    ],
  };

  MatchesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteLeagues = (prefs.getStringList('favoriteLeagues') ?? []).toSet();
    favoriteTeams = (prefs.getStringList('favoriteTeams') ?? []).toSet();
    followedMatchIds = (prefs.getStringList('followedMatchIds') ?? []).map((id) => int.parse(id)).toSet();
    notifyMatchStart = prefs.getBool('notifyMatchStart') ?? true;
    notifyGoals = prefs.getBool('notifyGoals') ?? true;
    hasFinishedOnboarding = prefs.getBool('hasFinishedOnboarding') ?? false;
    
    final predJson = prefs.getString('predictions');
    if (predJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(predJson);
        predictions = decoded.map((key, value) => MapEntry(int.parse(key), value.toString()));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> toggleLeague(String leagueName) async {
    if (favoriteLeagues.contains(leagueName)) {
      favoriteLeagues.remove(leagueName);
    } else {
      favoriteLeagues.add(leagueName);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteLeagues', favoriteLeagues.toList());
  }

  Future<void> toggleCountryBundle(String countryName) async {
    final leagues = countryBundles[countryName] ?? [];
    if (leagues.isEmpty) return;
    bool allSelected = leagues.every((l) => favoriteLeagues.contains(l));
    if (allSelected) {
      for (var l in leagues) { favoriteLeagues.remove(l); }
    } else {
      for (var l in leagues) { favoriteLeagues.add(l); }
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteLeagues', favoriteLeagues.toList());
  }

  bool isCountryBundleSelected(String countryName) {
    final leagues = countryBundles[countryName] ?? [];
    if (leagues.isEmpty) return false;
    return leagues.every((l) => favoriteLeagues.contains(l));
  }

  bool isCountryBundlePartial(String countryName) {
    final leagues = countryBundles[countryName] ?? [];
    if (leagues.isEmpty) return false;
    bool any = leagues.any((l) => favoriteLeagues.contains(l));
    bool all = leagues.every((l) => favoriteLeagues.contains(l));
    return any && !all;
  }

  Future<void> toggleTeam(String teamName) async {
    if (favoriteTeams.contains(teamName)) {
      favoriteTeams.remove(teamName);
    } else {
      favoriteTeams.add(teamName);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteTeams', favoriteTeams.toList());
  }

  Future<void> completeOnboarding() async {
    hasFinishedOnboarding = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasFinishedOnboarding', true);
  }

  Future<void> toggleFollowMatch(int matchId) async {
    if (followedMatchIds.contains(matchId)) {
      followedMatchIds.remove(matchId);
    } else {
      followedMatchIds.add(matchId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('followedMatchIds', followedMatchIds.map((id) => id.toString()).toList());
  }

  Future<void> toggleNotifyMatchStart() async {
    notifyMatchStart = !notifyMatchStart;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifyMatchStart', notifyMatchStart);
  }

  Future<void> toggleNotifyGoals() async {
    notifyGoals = !notifyGoals;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifyGoals', notifyGoals);
  }

  Future<void> setMatchPrediction(int matchId, String prediction) async {
    predictions[matchId] = prediction;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> stringyPreds = predictions.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('predictions', json.encode(stringyPreds));
  }

  Future<void> fetchAndCacheStandings(int leagueId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'standings_$leagueId';
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      standings[leagueId] = json.decode(cached);
      notifyListeners();
    }
    try {
      final results = await ApiService.getStandings(leagueId);
      if (results.isNotEmpty) {
        standings[leagueId] = results;
        await prefs.setString(cacheKey, json.encode(results));
        notifyListeners();
      }
    } catch (_) {}
  }

  Map<String, List<Match>> groupMatchesByTournament(List<Match> matches) {
    Map<String, List<Match>> grouped = {};
    for (var match in matches) {
      if (favoriteLeagues.isNotEmpty && !favoriteLeagues.contains(match.league)) continue;
      if (!grouped.containsKey(match.league)) grouped[match.league] = [];
      grouped[match.league]!.add(match);
    }
    return grouped;
  }

  Future<void> fetchLiveMatches() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final allMatches = await ApiService.getLiveMatches();
      // Filter only live matches if needed, for now we just show all or those marked as LIVE
      liveMatches = allMatches.where((m) => m.status == 'LIVE' || m.status.contains("'")).toList();
    } catch (e) {
      liveMatches = [];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMultiDayMatches() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await ApiService.getAllMatches();
      matchesByDate = {}; // Reset
      if (results.isNotEmpty) {
        for (var match in results) {
          // Fallback to today's date if match date is somehow null
          final dateKey = match.date != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(match.date!)) : DateFormat('yyyy-MM-dd').format(DateTime.now());
          if (!matchesByDate.containsKey(dateKey)) {
            matchesByDate[dateKey] = [];
          }
          matchesByDate[dateKey]!.add(match);
        }
      } else {
        // No matches found in database
      }
    } catch (e) {
      matchesByDate.clear();
      errorMessage = "Failed to load matches from database.";
    }
    isLoading = false;
    notifyListeners();
  }

  void setTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }
}
