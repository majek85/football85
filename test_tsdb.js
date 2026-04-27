async function test() {
    const todayDashes = '2026-04-27';
    console.log(`Testing TheSportsDB for date: ${todayDashes}...`);
    
    try {
        const tsdbRes = await fetch(`https://www.thesportsdb.com/api/v1/json/3/eventsday.php?d=${todayDashes}&l=4328`);
        const tsdbData = await tsdbRes.json();
        
        if (tsdbData.events) {
            console.log(`Success! Found ${tsdbData.events.length} matches in TheSportsDB.`);
            tsdbData.events.forEach(ev => {
                console.log(`- ${ev.strHomeTeam} vs ${ev.strAwayTeam} @ ${ev.strTimestamp}`);
            });
        } else {
            console.log('No matches found in TheSportsDB:', JSON.stringify(tsdbData));
        }
    } catch (e) {
        console.error('Test Failed:', e.message);
    }
}

test();
