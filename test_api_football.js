async function test() {
    const API_KEY = 'd31b5701ddmshadf6c49da2901cep1473dfjsn517950e3fe2f';
    const today = '2026-04-27';
    
    console.log(`Testing API-Football with NEW KEY for date: ${today}...`);
    
    try {
        const response = await fetch(
            `https://api-football-v1.p.rapidapi.com/v3/fixtures?date=${today}&league=39&season=2025`,
            {
                headers: {
                    'x-rapidapi-key': API_KEY,
                    'x-rapidapi-host': 'api-football-v1.p.rapidapi.com'
                }
            }
        );

        const result = await response.json();
        console.log(`Status: ${response.status}`);
        
        if (result.response && result.response.length > 0) {
            console.log(`Success! Found ${result.response.length} matches in API-Football.`);
            result.response.forEach(item => {
                console.log(`- ${item.teams.home.name} vs ${item.teams.away.name} @ ${item.fixture.date}`);
            });
        } else {
            console.log('No matches found in API-Football:', JSON.stringify(result).slice(0, 500));
        }
    } catch (e) {
        console.error('Test Failed:', e.message);
    }
}

test();
