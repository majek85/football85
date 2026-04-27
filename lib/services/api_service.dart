import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/match_model.dart';

class ApiService {
  static Map<String, String> get _supabaseHeaders => {
    'Content-Type': 'application/json',
    'apikey': AppConstants.supabaseKey,
    'Authorization': 'Bearer ${AppConstants.supabaseKey}',
  };

  static Future<void> triggerVercelUpdate() async {
    try {
      await http.get(Uri.parse(AppConstants.vercelApiUrl));
    } catch (_) {}
  }

  static Future<List<Match>> getLiveMatches() async {
    return getAllMatches();
  }

  static Future<List<Match>> getAllMatches() async {
    // 1. Trigger Vercel to fetch from RapidAPI and save to Supabase (ignore errors if protected)
    await triggerVercelUpdate();
    
    final today = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(today);
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(today.add(const Duration(days: 1)));

    // 2. Fetch directly from Supabase Database (today's matches only)
    final url = '${AppConstants.supabaseUrl}/rest/v1/matches?select=*&match_time=gte.$dateStr&match_time=lt.$tomorrowStr&order=match_time.asc';
    try {
      final response = await http.get(Uri.parse(url), headers: _supabaseHeaders);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((m) => Match.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Legacy stubs for compatibility
  static Future<List<Match>> getMatchesByDate(DateTime date) async => getAllMatches();
  static Future<List<Match>> getTeamSchedule(int teamId) async => getAllMatches();
  static Future<List<dynamic>> getStandings(int leagueId) async => [];
}
