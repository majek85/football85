function load(type) {
    const content = document.getElementById("content");
    content.innerHTML = '<div class="loading">جاري تحميل البيانات من السيرفر...</div>';

    // The function files are named 'matches.js' and 'liveMatches.js'
    // This matches the folder structure: netlify/functions/matches.js
    const functionName = type === 'todayMatches' || type === 'matches' ? 'matches' : 'liveMatches';

    console.log("Fetching from:", `/.netlify/functions/${functionName}`);

    fetch(`/.netlify/functions/${functionName}`)
        .then(res => {
            if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
            return res.json();
        })
        .then(data => {
            if (!data || data.length === 0) {
                content.innerHTML = '<p>لا توجد مباريات متاحة حالياً</p>';
                return;
            }
            content.innerHTML = data.map(m => `
                <div class="match-item">
                    <div class="league-name">${m.league}</div>
                    <div class="match-teams">
                        <span class="team">${m.homeTeam}</span>
                        <span class="score">${m.score.home} - ${m.score.away}</span>
                        <span class="team">${m.awayTeam}</span>
                    </div>
                    <div class="match-status">${m.status} ${m.elapsed ? `(${m.elapsed}')` : ''}</div>
                </div>
            `).join('');
        })
        .catch(err => {
            console.error("Fetch failed:", err);
            content.innerHTML = `<div class="error">فشل الاتصال: ${err.message}. تأكد من رفع المجلد netlify/functions</div>`;
        });
}

window.onload = () => load('matches');
