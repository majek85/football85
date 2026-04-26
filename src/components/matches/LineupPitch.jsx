function groupByPosition(players) {
  const order = { G: 0, D: 1, M: 2, F: 3 };
  const groups = { G: [], D: [], M: [], F: [] };
  players.forEach(p => {
    const pos = p.player?.pos || 'M';
    if (groups[pos]) groups[pos].push(p.player);
    else groups['M'].push(p.player);
  });
  return ['G', 'D', 'M', 'F'].map(pos => groups[pos]).filter(g => g.length > 0);
}

function PlayerDot({ player, color }) {
  return (
    <div className="flex flex-col items-center gap-1 cursor-default group">
      <div className={`w-9 h-9 rounded-full border-2 border-white flex items-center justify-center text-white text-xs font-bold shadow-md ${color}`}>
        {player?.number || '?'}
      </div>
      <span className="text-[10px] font-semibold text-white text-center leading-tight drop-shadow max-w-[60px] truncate">
        {player?.name?.split(' ').slice(-1)[0] || '—'}
      </span>
    </div>
  );
}

function TeamLineup({ players, formation, color, reverse }) {
  const rows = groupByPosition(players);
  const display = reverse ? [...rows].reverse() : rows;

  return (
    <div className={`flex flex-col ${reverse ? 'justify-start' : 'justify-start'} gap-3 py-2`}>
      {display.map((row, i) => (
        <div key={i} className="flex justify-around items-center">
          {row.map((player, j) => (
            <PlayerDot key={j} player={player} color={color} />
          ))}
        </div>
      ))}
    </div>
  );
}

export default function LineupPitch({ lineups, teams }) {
  if (!lineups) {
    return <div className="text-center py-12 text-muted-foreground text-sm">التشكيلة غير متاحة</div>;
  }

  const homePlayers = lineups?.home?.startXI || [];
  const awayPlayers = lineups?.away?.startXI || [];
  const homeFormation = lineups?.home?.formation || '';
  const awayFormation = lineups?.away?.formation || '';

  return (
    <div className="space-y-4">
      {/* Formation Labels */}
      <div className="flex justify-between items-center px-2">
        <div className="text-center">
          <p className="text-sm font-bold">{teams?.home?.name}</p>
          <p className="text-xs text-muted-foreground">{homeFormation}</p>
        </div>
        <div className="text-center">
          <p className="text-sm font-bold">{teams?.away?.name}</p>
          <p className="text-xs text-muted-foreground">{awayFormation}</p>
        </div>
      </div>

      {/* Pitch */}
      <div
        className="relative rounded-xl overflow-hidden"
        style={{ background: 'linear-gradient(180deg, #1a6b2f 0%, #1d7a35 50%, #1a6b2f 100%)', minHeight: '520px' }}
      >
        {/* Pitch lines */}
        <svg className="absolute inset-0 w-full h-full opacity-20" viewBox="0 0 300 520" preserveAspectRatio="none">
          {/* Border */}
          <rect x="10" y="10" width="280" height="500" fill="none" stroke="white" strokeWidth="1.5" />
          {/* Center line */}
          <line x1="10" y1="260" x2="290" y2="260" stroke="white" strokeWidth="1.5" />
          {/* Center circle */}
          <circle cx="150" cy="260" r="40" fill="none" stroke="white" strokeWidth="1.5" />
          <circle cx="150" cy="260" r="2" fill="white" />
          {/* Home penalty area */}
          <rect x="70" y="10" width="160" height="70" fill="none" stroke="white" strokeWidth="1.5" />
          <rect x="105" y="10" width="90" height="30" fill="none" stroke="white" strokeWidth="1.5" />
          {/* Away penalty area */}
          <rect x="70" y="440" width="160" height="70" fill="none" stroke="white" strokeWidth="1.5" />
          <rect x="105" y="480" width="90" height="30" fill="none" stroke="white" strokeWidth="1.5" />
        </svg>

        {/* Home team (top half) */}
        <div className="absolute top-0 left-0 right-0 h-1/2 px-4 pt-3">
          <TeamLineup players={awayPlayers} formation={awayFormation} color="bg-red-500" reverse={false} />
        </div>

        {/* Away team (bottom half) */}
        <div className="absolute bottom-0 left-0 right-0 h-1/2 px-4 pb-3">
          <TeamLineup players={homePlayers} formation={homeFormation} color="bg-blue-600" reverse={true} />
        </div>

        {/* Labels */}
        <div className="absolute top-2 left-2 text-white text-[10px] font-bold opacity-70">{teams?.away?.name}</div>
        <div className="absolute bottom-2 left-2 text-white text-[10px] font-bold opacity-70">{teams?.home?.name}</div>
      </div>

      {/* Legend */}
      <div className="flex justify-center gap-6 text-xs text-muted-foreground">
        <div className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-blue-600 inline-block"></span>{teams?.home?.name}</div>
        <div className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-red-500 inline-block"></span>{teams?.away?.name}</div>
      </div>

      {/* Player Lists */}
      <div className="grid grid-cols-2 gap-3 mt-4">
        {[
          { label: teams?.home?.name, players: homePlayers, color: 'border-blue-400' },
          { label: teams?.away?.name, players: awayPlayers, color: 'border-red-400' },
        ].map(({ label, players, color }) => (
          <div key={label} className={`bg-card border ${color} border-l-4 rounded-lg p-3`}>
            <p className="text-xs font-bold mb-2 text-muted-foreground">{label}</p>
            <div className="space-y-1">
              {players.map((p, i) => (
                <div key={i} className="flex items-center gap-2 text-xs">
                  <span className="w-5 text-center font-bold text-muted-foreground">{p.player?.number}</span>
                  <span className="text-[10px] bg-muted px-1 rounded text-muted-foreground">{p.player?.pos}</span>
                  <span className="font-medium truncate">{p.player?.name}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
