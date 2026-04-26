exports.handler = async (event) => {
    const today = new Date().toISOString().split('T')[0];
    const liveMatch = [
        { id: 101, league: 'Champions League 🇪🇺', homeTeam: 'Real Madrid', awayTeam: 'Man City', score: { home: 1, away: 1 }, status: 'In Progress', elapsed: '45', date: today }
    ];

    return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify(liveMatch)
    };
};
