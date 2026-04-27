async function test() {
    const API_KEY = 'd31b5701ddmshadf6c49da2901cep1473dfjsn517950e3fe2f';
    
    // اختبار 3 أيام: أمس، اليوم، غداً
    const dates = ['20260426', '20260427', '20260428'];
    
    for (const d of dates) {
        console.log(`Checking date: ${d}...`);
        try {
            const response = await fetch(
                `https://free-api-live-football-data.p.rapidapi.com/football-get-matches-by-date?date=${d}`,
                {
                    headers: {
                        'x-rapidapi-key': API_KEY,
                        'x-rapidapi-host': 'free-api-live-football-data.p.rapidapi.com'
                    }
                }
            );

            const result = await response.json();
            if (result.status === "success" && result.response.matches) {
                const found = result.response.matches.filter(m => 
                    m.home?.name?.toLowerCase().includes('manchester') || 
                    m.away?.name?.toLowerCase().includes('manchester')
                );
                if (found.length > 0) {
                    console.log(`FOUND on ${d}:`, JSON.stringify(found, null, 2));
                } else {
                    console.log(`Not found on ${d}. Total matches: ${result.response.matches.length}`);
                }
            }
        } catch (e) {
            console.error(`Failed for ${d}:`, e.message);
        }
    }
}

test();
