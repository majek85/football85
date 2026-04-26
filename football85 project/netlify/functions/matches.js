exports.handler = async (event) => {
    const today = new Date().toISOString().split('T')[0];
    const mockMatches = [
        { id: 102, league: 'Premier League 🏴󠁧󠁢󠁥󠁮󠁧󠁿', homeTeam: 'Arsenal', awayTeam: 'Chelsea', score: { home: 0, away: 0 }, status: 'NS', date: today, elapsed: '0' },
        { id: 103, league: 'Saudi Pro League 🇸🇦', homeTeam: 'Al Hilal', awayTeam: 'Al Nassr', score: { home: 3, away: 2 }, status: 'FT', date: today, elapsed: '90' }
    ];

    return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify(mockMatches)
    };
};
