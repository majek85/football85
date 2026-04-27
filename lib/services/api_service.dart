import 'dart:convert';
import 'package:http/http.dart' as http;
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
    } catch (_) {
      // Ignore if triggering fails, we still try to read from Supabase
    }
  }

  static Future<List<Match>> getLiveMatches() async {
    // Currently we just fetch all matches. Later you can filter by status='LIVE'
    return getAllMatches();
  }

  static Future<List<Match>> getAllMatches() async {
    await triggerVercelUpdate(); // Trigger the backend to update data
    
    const url = '${AppConstants.supabaseUrl}/rest/v1/matches?select=*&order=match_time.asc';
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
