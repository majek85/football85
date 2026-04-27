async function test() {
    const API_KEY = 'd31b5701ddmshadf6c49da2901cep1473dfjsn517950e3fe2f';
    const today = '2026-04-25';
    
    console.log(`Testing Free Football API with NEW KEY for date: ${today}...`);
    
    try {
        const todayNoDashes = '20260427';
        const response = await fetch(
            `https://free-api-live-football-data.p.rapidapi.com/football-get-matches-by-date?date=${todayNoDashes}`,
            {
                headers: {
                    'x-rapidapi-key': API_KEY,
                    'x-rapidapi-host': 'free-api-live-football-data.p.rapidapi.com'
                }
            }
        );

        const result = await response.json();
        console.log(`Status: ${response.status}`);
        
        if (result.status === "success" && result.response.matches) {
            const pl = result.response.matches.filter(m => m.league?.id === 47);
            console.log(`Success! Found ${pl.length} Premier League matches.`);
            if (pl.length > 0) {
                console.log('Sample:', pl[0].home.name, 'vs', pl[0].away.name);
            }
        } else {
            console.log('No matches found or structure changed:', JSON.stringify(result).slice(0, 1000));
        }
    } catch (e) {
        console.error('Test Failed:', e.message);
    }
}

test();
