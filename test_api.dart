import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://utyxvzrazuwonedcdubs.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0eXh2enJhenV3b25lZGNkdWJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxOTU5MzQsImV4cCI6MjA5Mjc3MTkzNH0.YPKOxYki21WfhgzN1HIvPKuHyVjFwJ-VfofnN7OJwCI';

  final headers = {
    'Content-Type': 'application/json',
    'apikey': supabaseKey,
    'Authorization': 'Bearer $supabaseKey',
  };

  const url = '$supabaseUrl/rest/v1/matches?select=*&order=match_time.asc';
  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Success! Found ${data.length} matches in Supabase.');
      if (data.isNotEmpty) {
        print('First match: ${data.first}');
      }
    } else {
      print('Failed! Status: ${response.statusCode}, Body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
