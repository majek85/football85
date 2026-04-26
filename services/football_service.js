const logger = require('../utils/logger');
const cache = require('./cache_service');

const API_HOST = 'free-api-live-football-data.p.rapidapi.com';
const API_ENDPOINT = `https://${API_HOST}`;
const API_KEY = process.env.FOOTBALL_API_KEY;

class FootballService {
  async fetchWithFallback(endpoint, params = {}, cacheKey, ttl) {
    const cachedData = cache.get(cacheKey);
    if (cachedData) return cachedData;

    try {
      if (!API_KEY) throw new Error('API_KEY_MISSING');
      const response = await fetch(`${API_ENDPOINT}/${endpoint}?${new URLSearchParams(params)}`, {
        headers: { 'x-rapidapi-key': API_KEY, 'x-rapidapi-host': API_HOST }
      });

      if (!response.ok) return this.getMockData();
      const result = await response.json();
      return this.normalize(result);
    } catch (error) {
      return this.getMockData();
    }
  }

  normalize(raw) {
    const data = raw.response || raw.data || [];
    return data.map(item => ({
      id: item.id || Math.random().toString(36).substr(2, 9),
      league: item.league_name || 'International',
      homeTeam: item.home_team_name || 'Home Team',
      awayTeam: item.away_team_name || 'Away Team',
      score: { home: item.home_score || 0, away: item.away_score || 0 },
      status: item.status || 'NS',
      elapsed: item.elapsed || '0',
      date: item.date || new Date().toISOString().split('T')[0]
    }));
  }

  getMockData() {
    const today = new Date().toISOString().split('T')[0];
    const tomorrow = new Date(Date.now() + 86400000).toISOString().split('T')[0];
    const dayAfter = new Date(Date.now() + 172800000).toISOString().split('T')[0];
    
    return [
      // Today
      { id: 't1', league: 'Premier League', homeTeam: 'Arsenal', awayTeam: 'Chelsea', score: { home: 0, away: 0 }, status: 'NS', date: today },
      { id: 't2', league: 'Champions League', homeTeam: 'Real Madrid', awayTeam: 'Man City', score: { home: 1, away: 1 }, status: 'In Progress', elapsed: '45', date: today },
      // Tomorrow
      { id: 'tom1', league: 'La Liga', homeTeam: 'Barcelona', awayTeam: 'Atletico', score: { home: 0, away: 0 }, status: 'NS', date: tomorrow },
      // Day After
      { id: 'da1', league: 'Saudi Pro League', homeTeam: 'Al Nassr', awayTeam: 'Al Ittihad', score: { home: 0, away: 0 }, status: 'NS', date: dayAfter },
    ];
  }

  async getAllMatches() {
    // Fetches all available upcoming matches to cover multiple days
    return this.fetchWithFallback('football-all-matches', {}, 'all_matches_bundle', 300);
  }

  async getLiveMatches() {
    return this.fetchWithFallback('football-live-matches', {}, 'live_matches', 30);
  }
}

module.exports = new FootballService();
