import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/match_model.dart';

class ApiService {
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Future<List<Match>> getLiveMatches() async {
    const url = '${AppConstants.baseUrl}/liveMatches';
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((m) => Match.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Match>> getAllMatches() async {
    const url = '${AppConstants.baseUrl}/todayMatches'; // This currently handles all matches in our backend
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
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
