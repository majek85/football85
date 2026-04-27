async function test() {
    const API_KEY = 'd31b5701ddmshadf6c49da2901cep1473dfjsn517950e3fe2f';
    const today = new Date().toISOString().slice(0, 10);
    
    console.log(`Testing Free Football API with NEW KEY for date: ${today}...`);
    
    try {
        const response = await fetch(
            `https://free-api-live-football-data.p.rapidapi.com/football-popular-leagues`,
            {
                headers: {
                    'x-rapidapi-key': API_KEY,
                    'x-rapidapi-host': 'free-api-live-football-data.p.rapidapi.com'
                }
            }
        );

        const result = await response.json();
        console.log(`Status: ${response.status}`);
        
        if (result.response && result.response.matches) {
            console.log(`Success! Found ${result.response.matches.length} matches.`);
            console.log('Sample:', result.response.matches[0].home.name, 'vs', result.response.matches[0].away.name);
        } else {
            console.log('No matches found or structure changed:', JSON.stringify(result).slice(0, 200));
        }
    } catch (e) {
        console.error('Test Failed:', e.message);
    }
}

test();
