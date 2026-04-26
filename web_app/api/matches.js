import { createClient } from '@supabase/supabase-js'


export default async (req, res) => {
    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', 'application/json');

    const API_KEY = process.env.FOOTBALL_API_KEY;
    let SUPA_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;
    if (SUPA_URL) {
        SUPA_URL = SUPA_URL.replace(/\/rest\/v1\/?$/, '');
    }
    const SUPA_KEY = process.env.SUPABASE_ANON_KEY || process.env.VITE_SUPABASE_ANON_KEY;

    if (!SUPA_URL || !SUPA_KEY) {
        return res.status(500).json({ error: "Missing Supabase Environment Variables in Vercel." });
    }

    if (!API_KEY) {
        return res.status(500).json({ error: "Missing Football API Key in Vercel." });
    }
    // الاتصال بـ Supabase
    const supabase = createClient(SUPA_URL, SUPA_KEY);

    try {
        const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
        // 1. جلب البيانات
        const response = await fetch(
            `https://free-api-live-football-data.p.rapidapi.com/football-get-matches-by-date?date=${today}`,
            {
                headers: {
                    'x-rapidapi-key': API_KEY,
                    'x-rapidapi-host': 'free-api-live-football-data.p.rapidapi.com'
                }
            }
        )

        const result = await response.json();
        const matches = result.response?.matches || result.matches || [];

        // 2. تجهيز البيانات
        const formatted = matches.map(m => ({
            fixture_id: m.id,
            home_team: m.home?.name || 'Unknown',
            away_team: m.away?.name || 'Unknown',
            home_logo: null, // الـ API الجديد لا يرسل شعارات في هذه الصفحة
            away_logo: null,
            score: `${m.home?.score || 0}-${m.away?.score || 0}`,
            status: m.status?.finished ? 'FT' : (m.status?.started ? 'LIVE' : 'NS'),
            match_time: m.status?.utcTime || new Date().toISOString()
        }));

        // 3. حفظ في Supabase
        const { error } = await supabase
            .from('matches')
            .upsert(formatted, { onConflict: 'fixture_id' })

        if (error) throw error

        return res.status(200).json({
            message: 'Success!',
            count: matches.length,
            timestamp: new Date().toISOString()
        })
    } catch (e) {
        console.error('Error:', e.message)
        return res.status(500).json({ error: e.message })
    }
}