const https = require('https');

// TheSportsDB Free API - Key: 2 (no registration required)
const SPORTSDB_BASE = 'https://www.thesportsdb.com/api/v1/json/2';

function fetchJSON(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch (e) { reject(e); }
      });
    }).on('error', reject);
  });
}

function formatStatus(event) {
  const prog = event.strProgress || '';
  const status = event.strStatus || '';
  if (status === 'Match Finished') return { short: 'FT', elapsed: 90 };
  if (prog && prog !== '0') return { short: '1H', elapsed: parseInt(prog) };
  return { short: 'NS', elapsed: null };
}

function transformEvent(event) {
  const statusObj = formatStatus(event);
  return {
    fixture: {
      id: event.idEvent,
      date: event.strTimestamp || `${event.dateEvent}T${event.strTime || '00:00:00'}Z`,
      status: statusObj
    },
    league: {
      id: event.idLeague,
      name: event.strLeague,
      country: event.strCountry || '',
      logo: event.strLeagueBadge || null
    },
    teams: {
      home: {
        id: event.idHomeTeam,
        name: event.strHomeTeam,
        logo: event.strHomeTeamBadge || `https://www.thesportsdb.com/images/media/team/badge/${event.strHomeTeam?.replace(/ /g, '_')}.png`
      },
      away: {
        id: event.idAwayTeam,
        name: event.strAwayTeam,
        logo: event.strAwayTeamBadge || `https://www.thesportsdb.com/images/media/team/badge/${event.strAwayTeam?.replace(/ /g, '_')}.png`
      }
    },
    goals: {
      home: event.intHomeScore !== null && event.intHomeScore !== '' ? parseInt(event.intHomeScore) : null,
      away: event.intAwayScore !== null && event.intAwayScore !== '' ? parseInt(event.intAwayScore) : null
    }
  };
}

// Major leagues to fetch (TheSportsDB IDs)
const LEAGUES = [
  { id: '4328', name: 'الدوري الإنجليزي' },    // English Premier League
  { id: '4335', name: 'الدوري الإسباني' },    // La Liga
  { id: '4332', name: 'الدوري الألماني' },    // Bundesliga
  { id: '4331', name: 'الدوري الفرنسي' },     // Ligue 1
  { id: '4334', name: 'الدوري الإيطالي' },    // Serie A
  { id: '4480', name: 'دوري أبطال أوروبا' },  // Champions League
];

const cacheStore = new Map();
function getCache(key) {
  const entry = cacheStore.get(key);
  if (!entry) return null;
  if (Date.now() > entry.expiresAt) { cacheStore.delete(key); return null; }
  return entry.data;
}
function setCache(key, data, ttl) {
  cacheStore.set(key, { data, expiresAt: Date.now() + ttl * 1000 });
}

exports.handler = async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  const path = event.path || '';
  const segments = path.split('/').filter(Boolean);
  const endpoint = segments[segments.length - 1];

  try {
    // Live matches
    if (endpoint === 'liveMatches') {
      const cached = getCache('live');
      if (cached) return { statusCode: 200, headers, body: JSON.stringify(cached) };

      const data = await fetchJSON(`${SPORTSDB_BASE}/livescore.php?sport=Soccer`);
      const matches = (data.events || []).map(transformEvent);
      setCache('live', matches, 60); // cache 60s
      return { statusCode: 200, headers, body: JSON.stringify(matches) };
    }

    // Today's matches - fetch from multiple leagues
    if (endpoint === 'todayMatches') {
      const cached = getCache('today');
      if (cached) return { statusCode: 200, headers, body: JSON.stringify(cached) };

      const today = new Date().toISOString().split('T')[0];
      const data = await fetchJSON(`${SPORTSDB_BASE}/eventsday.php?d=${today}&s=Soccer`);
      const matches = (data.events || []).map(transformEvent);
      setCache('today', matches, 300); // cache 5 min
      return { statusCode: 200, headers, body: JSON.stringify(matches) };
    }

    // Match detail by ID
    if (endpoint.startsWith('match') || (segments.length > 1 && segments[segments.length - 2] === 'match')) {
      const matchId = segments[segments.length - 1];
      if (matchId && matchId !== 'match') {
        const data = await fetchJSON(`${SPORTSDB_BASE}/lookupevent.php?id=${matchId}`);
        const events = data.events || [];
        if (events.length > 0) {
          return { statusCode: 200, headers, body: JSON.stringify(transformEvent(events[0])) };
        }
      }
    }

    // Standings
    if (segments[segments.length - 2] === 'standings') {
      const leagueId = endpoint;
      const data = await fetchJSON(`${SPORTSDB_BASE}/lookuptable.php?l=${leagueId}&s=2023-2024`);
      return { statusCode: 200, headers, body: JSON.stringify(data.table || []) };
    }

    return { statusCode: 404, headers, body: JSON.stringify({ error: 'Not found' }) };

  } catch (err) {
    console.error('[API Error]', err.message);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Server error', message: err.message })
    };
  }
};
