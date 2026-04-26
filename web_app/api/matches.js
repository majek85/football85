import { createClient } from '@supabase/supabase-js'
import fetch from 'node-fetch'

// الاتصال بـ Supabase
const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
)

export default async function handler(req, res) {
    const API_KEY = process.env.FOOTBALL_API_KEY

    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', 'application/json');

    try {
        // 1. جلب البيانات
        const response = await fetch(
            'https://free-api-live-football-data.p.rapidapi.com/football-all-matches',
            {
                headers: {
                    'x-rapidapi-key': API_KEY,
                    'x-rapidapi-host': 'free-api-live-football-data.p.rapidapi.com'
                }
            }
        )

        const result = await response.json()
        const matches = result.data || []

        // 2. تجهيز البيانات
        const formatted = matches.map(m => ({
            fixture_id: m.id,
            home_team: m.home_team_name,
            away_team: m.away_team_name,
            home_logo: m.home_team_logo,
            away_logo: m.away_team_logo,
            score: `${m.home_score || 0}-${m.away_score || 0}`,
            status: m.status,
            match_time: m.start_time
        }))

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