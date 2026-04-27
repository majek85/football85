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
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const todayNoDashes = `${year}${month}${day}`;
        const todayDashes = `${year}-${month}-${day}`;

        // 1. محاولة جلب البيانات من المزود الأول (RapidAPI)
        let matches = [];
        try {
            const response = await fetch(
                `https://free-api-live-football-data.p.rapidapi.com/football-get-matches-by-date?date=${todayNoDashes}`,
                {
                    headers: {
                        'x-rapidapi-key': 'd31b5701ddmshadf6c49da2901cep1473dfjsn517950e3fe2f',
                        'x-rapidapi-host': 'free-api-live-football-data.p.rapidapi.com'
                    }
                }
            );
            const result = await response.json();
            matches = result.response?.matches?.filter(m => m.league?.id === 47) || [];
        } catch (e) {
            console.error('RapidAPI Fetch Error:', e.message);
        }

        // 2. إذا لم يجد مباريات، نجرب المزود الاحترافي المجاني (TheSportsDB)
        if (matches.length === 0) {
            console.log('Falling back to TheSportsDB for Premier League matches...');
            try {
                // نستخدم الدوري الإنجليزي الممتاز (ID: 4328 في TheSportsDB)
                const tsdbRes = await fetch(`https://www.thesportsdb.com/api/v1/json/3/eventsday.php?d=${todayDashes}&l=4328`);
                const tsdbData = await tsdbRes.json();
                
                if (tsdbData.events) {
                    matches = tsdbData.events.map(ev => ({
                        id: ev.idEvent,
                        home: { name: ev.strHomeTeam, logo: ev.strHomeTeamBadge },
                        away: { name: ev.strAwayTeam, logo: ev.strAwayTeamBadge },
                        status: { scoreStr: `${ev.intHomeScore || 0}-${ev.intAwayScore || 0}`, type: ev.strStatus, utcTime: ev.strTimestamp },
                        league: { id: 47 }
                    }));
                }
            } catch (e) {
                console.error('TheSportsDB Fetch Error:', e.message);
            }
        }

        if (matches.length === 0) {
            return res.status(200).json({ message: "No matches found today.", count: 0 });
        }

        // 3. تجهيز البيانات للرفع
        const formatted = matches.map(m => ({
            fixture_id: m.id,
            home_team: m.home?.name || "Unknown",
            away_team: m.away?.name || "Unknown",
            home_logo: m.home?.logo,
            away_logo: m.away?.logo,
            score: m.status?.scoreStr || "0-0",
            status: m.status?.type || "NS",
            match_time: m.status?.utcTime || new Date().toISOString(),
            created_at: new Date()
        }));

        // 4. حفظ البيانات في Supabase
        const { error: supaError } = await supabase
            .from('matches')
            .upsert(formatted, { onConflict: 'fixture_id' });

        if (supaError) throw supaError;

        return res.status(200).json({
            message: "Success!",
            count: formatted.length,
            data: formatted
        });

    } catch (e) {
        console.error('General Error:', e.message);
        return res.status(500).json({ error: e.message });
    }
}