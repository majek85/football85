// ===================================================
// Football Data Service
// Uses TheSportsDB (free, no key) for historical data
// Falls back to mock data if API is unavailable
// ===================================================

import { supabase } from '../lib/supabase';

const SPORTSDB = 'https://www.thesportsdb.com/api/v1/json/2';

// Major league IDs on TheSportsDB
export const LEAGUE_IDS = {
  premierLeague: '4328',
  laLiga: '4335',
  bundesliga: '4332',
  ligue1: '4331',
  serieA: '4334',
  championsLeague: '4480',
};

function transformEvent(ev) {
  if (!ev) return null;
  const statusRaw = ev.strStatus || '';
  const progress = ev.strProgress || '';

  let statusShort = 'NS';
  let elapsed = null;

  if (statusRaw === 'Match Finished' || statusRaw === 'FT') {
    statusShort = 'FT'; elapsed = 90;
  } else if (statusRaw === 'Half Time' || statusRaw === 'HT') {
    statusShort = 'HT'; elapsed = 45;
  } else if (progress && progress !== '0' && progress !== '') {
    statusShort = '1H'; elapsed = parseInt(progress) || null;
  } else {
    statusShort = 'NS';
  }

  const homeScore = ev.intHomeScore !== null && ev.intHomeScore !== '' ? parseInt(ev.intHomeScore) : null;
  const awayScore = ev.intAwayScore !== null && ev.intAwayScore !== '' ? parseInt(ev.intAwayScore) : null;

  return {
    fixture: {
      id: ev.idEvent,
      date: ev.strTimestamp || `${ev.dateEvent}T${ev.strTime || '19:00:00'}Z`,
      status: { short: statusShort, elapsed }
    },
    league: {
      id: ev.idLeague,
      name: ev.strLeague || 'غير معروف',
      country: ev.strCountry || '',
      logo: ev.strLeagueBadge || null
    },
    teams: {
      home: { id: ev.idHomeTeam, name: ev.strHomeTeam || '—', logo: ev.strHomeTeamBadge || null },
      away: { id: ev.idAwayTeam, name: ev.strAwayTeam || '—', logo: ev.strAwayTeamBadge || null }
    },
    goals: { home: homeScore, away: awayScore }
  };
}

async function safeFetch(url) {
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.json();
  } catch (err) {
    console.warn('[API]', err.message, url);
    return null;
  }
}

// Fetch next events for a specific league
async function getLeagueNextEvents(leagueId) {
  const data = await safeFetch(`${SPORTSDB}/eventsnextleague.php?id=${leagueId}`);
  return (data?.events || []).map(transformEvent).filter(Boolean);
}

// Fetch last events for a specific league
async function getLeagueLastEvents(leagueId) {
  const data = await safeFetch(`${SPORTSDB}/eventspastleague.php?id=${leagueId}`);
  return (data?.events || []).map(transformEvent).filter(Boolean);
}

// Helper to transform Supabase match to App format
function transformSupabaseMatch(m) {
  let homeScore = null;
  let awayScore = null;
  if (m.score && m.score !== '0-0' && m.score !== '-') {
    const parts = m.score.split('-');
    homeScore = parseInt(parts[0]);
    awayScore = parseInt(parts[1]);
  }

  return {
    fixture: { 
      id: String(m.fixture_id), 
      date: m.match_time, 
      status: { short: m.status || 'NS', elapsed: null } 
    },
    league: { id: '0', name: 'أهم المباريات', country: '', logo: null },
    teams: {
      home: { id: m.home_team, name: m.home_team, logo: m.home_logo },
      away: { id: m.away_team, name: m.away_team, logo: m.away_logo }
    },
    goals: { home: homeScore, away: awayScore }
  };
}

export const footballAPI = {
  // Get upcoming + recent matches from top leagues
  getTodayMatches: async () => {
    try {
      // 1. Trigger Vercel to update Supabase (silent)
      // Use the actual production URL if available, or the current one
      fetch('https://football85.vercel.app/api/matches').catch(() => {});

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      // 2. نجلب المباريات من Supabase (مباريات اليوم فقط)
      const { data, error } = await supabase
        .from('matches')
        .select('*')
        .gte('match_time', today.toISOString())
        .lt('match_time', tomorrow.toISOString())
        .order('match_time', { ascending: true });

      if (error) throw error;

      if (data && data.length > 0) {
        return data.map(transformSupabaseMatch);
      }
      return MOCK_MATCHES;
    } catch (e) {
      console.error('Supabase fetch error:', e);
      return MOCK_MATCHES;
    }
  },

  // Live matches
  getLiveMatches: async () => {
    const data = await safeFetch(`${SPORTSDB}/livescore.php?sport=Soccer`);
    return (data?.events || []).map(transformEvent).filter(Boolean);
  },

  // Single match detail
  getMatch: async (id) => {
    try {
      // 1. Try Supabase first
      const { data, error } = await supabase
        .from('matches')
        .select('*')
        .eq('fixture_id', id)
        .single();

      if (data) return transformSupabaseMatch(data);

      // 2. Fallback to TheSportsDB
      const res = await safeFetch(`${SPORTSDB}/lookupevent.php?id=${id}`);
      const ev = res?.events?.[0];
      return ev ? transformEvent(ev) : null;
    } catch (e) {
      console.warn('Match detail fetch error:', e);
      return null;
    }
  },

  // League standings
  getStandings: async (leagueId, season = '2024-2025') => {
    const data = await safeFetch(`${SPORTSDB}/lookuptable.php?l=${leagueId}&s=${season}`);
    return data?.table || [];
  },

  // Next matches for a league
  getLeagueNext: getLeagueNextEvents,

  // Past matches for a league
  getLeagueLast: getLeagueLastEvents,
};

// ============ MOCK FALLBACK DATA ============
export const MOCK_MATCHES = [
  {
    fixture: { id: '101', date: new Date().toISOString(), status: { short: '2H', elapsed: 72 } },
    league: { id: '4480', name: 'دوري أبطال أوروبا', country: 'Europe', logo: null },
    teams: {
      home: { id: '541', name: 'ريال مدريد', logo: 'https://www.thesportsdb.com/images/media/team/badge/xzqdr11516580922.png' },
      away: { id: '50', name: 'مان سيتي', logo: 'https://www.thesportsdb.com/images/media/team/badge/vwjuus1473503711.png' },
    },
    goals: { home: 2, away: 1 },
  },
  {
    fixture: { id: '102', date: new Date(Date.now() + 3600000).toISOString(), status: { short: 'NS', elapsed: null } },
    league: { id: '4328', name: 'الدوري الإنجليزي', country: 'England', logo: null },
    teams: {
      home: { id: '42', name: 'أرسنال', logo: 'https://www.thesportsdb.com/images/media/team/badge/uyhbfe1612467562.png' },
      away: { id: '49', name: 'تشيلسي', logo: 'https://www.thesportsdb.com/images/media/team/badge/yvwvtu1448813215.png' },
    },
    goals: { home: null, away: null },
  },
  {
    fixture: { id: '103', date: new Date(Date.now() - 7200000).toISOString(), status: { short: 'FT', elapsed: 90 } },
    league: { id: '307', name: 'دوري روشن السعودي', country: 'Saudi Arabia', logo: null },
    teams: {
      home: { id: '2932', name: 'الهلال', logo: null },
      away: { id: '2933', name: 'النصر', logo: null },
    },
    goals: { home: 3, away: 2 },
  },
  {
    fixture: { id: '104', date: new Date(Date.now() + 7200000).toISOString(), status: { short: 'NS', elapsed: null } },
    league: { id: '4335', name: 'الدوري الإسباني', country: 'Spain', logo: null },
    teams: {
      home: { id: '529', name: 'برشلونة', logo: 'https://www.thesportsdb.com/images/media/team/badge/a7zu9n1409067051.png' },
      away: { id: '530', name: 'أتلتيكو مدريد', logo: 'https://www.thesportsdb.com/images/media/team/badge/uvuswu1448813986.png' },
    },
    goals: { home: null, away: null },
  },
  {
    fixture: { id: '105', date: new Date(Date.now() - 3600000).toISOString(), status: { short: 'FT', elapsed: 90 } },
    league: { id: '4332', name: 'الدوري الألماني', country: 'Germany', logo: null },
    teams: {
      home: { id: '133604', name: 'بايرن ميونخ', logo: 'https://www.thesportsdb.com/images/media/team/badge/tsqtu11516580399.png' },
      away: { id: '133615', name: 'دورتموند', logo: 'https://www.thesportsdb.com/images/media/team/badge/xzqdr11516580922.png' },
    },
    goals: { home: 1, away: 1 },
  },
];

export const MOCK_NEWS = [
  { id: 1, title: 'ريال مدريد يتأهل لنهائي دوري الأبطال بفوز دراماتيكي', category: 'دوري الأبطال', time: 'منذ 30 دقيقة', image: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800&auto=format&fit=crop' },
  { id: 2, title: 'محمد صلاح يحطم رقماً قياسياً جديداً في الدوري الإنجليزي', category: 'الدوري الإنجليزي', time: 'منذ ساعة', image: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&auto=format&fit=crop' },
  { id: 3, title: 'كريستيانو رونالدو: أنا الأفضل في تاريخ كرة القدم', category: 'تصريحات', time: 'منذ 2 ساعة', image: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800&auto=format&fit=crop' },
  { id: 4, title: 'برشلونة يضم نجماً جديداً بصفقة قياسية', category: 'انتقالات', time: 'منذ 3 ساعات', image: 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&auto=format&fit=crop' },
  { id: 5, title: 'الهلال يحقق لقب دوري روشن للمرة الثانية على التوالي', category: 'دوري روشن', time: 'منذ 5 ساعات', image: 'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?w=800&auto=format&fit=crop' },
];
