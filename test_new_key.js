async function test() {
    const API_KEY = 'd31b5701ddmshadf6c49da2901cep1473dfjsn517950e3fe2f';
    const todayNoDashes = '20260427';
    
    console.log(`Testing Free Football API with NEW KEY for date: ${todayNoDashes}...`);
    
    try {
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
            console.log(`Total Matches Found Today: ${result.response.matches.length}`);
            const search = result.response.matches.filter(m => 
                m.home?.name?.toLowerCase().includes('manchester') || 
                m.away?.name?.toLowerCase().includes('manchester') ||
                m.home?.name?.toLowerCase().includes('brentford') ||
                m.away?.name?.toLowerCase().includes('brentford')
            );
            console.log('Search Results:', JSON.stringify(search, null, 2));
        } else {
            console.log('No matches found in standard structure:', JSON.stringify(result).slice(0, 500));
        }
    } catch (e) {
        console.error('Test Failed:', e.message);
    }
}

test();
