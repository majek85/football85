async function test() {
    const API_KEY = '64687d5598msh2e079b76c8888bcp1f0ecfjsn5f939e607424'; // المفتاح الذي زودني به المستخدم سابقا
    const today = new Date().toISOString().slice(0, 10);
    
    console.log(`Testing API-Football for date: ${today}...`);
    
    try {
        const response = await fetch(
            `https://api-football-v1.p.rapidapi.com/v3/fixtures?date=${today}`,
            {
                headers: {
                    'x-rapidapi-key': API_KEY,
                    'x-rapidapi-host': 'api-football-v1.p.rapidapi.com'
                }
            }
        );

        const result = await response.json();
        const count = result.response ? result.response.length : 0;
        
        console.log(`Status: ${response.status}`);
        console.log(`Matches found: ${count}`);
        
        if (count > 0) {
            console.log('Sample Match:', JSON.stringify({
                home: result.response[0].teams.home.name,
                away: result.response[0].teams.away.name,
                score: result.response[0].goals.home + '-' + result.response[0].goals.away,
                status: result.response[0].fixture.status.short
            }, null, 2));
        } else {
            console.log('No matches found. This might be due to API limitations or no games today.');
        }
    } catch (e) {
        console.error('Test Failed:', e.message);
    }
}

test();
