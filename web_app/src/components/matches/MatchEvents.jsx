export default function MatchEvents({ events, teams }) {
  if (!events || events.length === 0) {
    return <div className="text-center py-12 text-muted-foreground text-sm">لا توجد أحداث حتى الآن</div>;
  }

  const getEventIcon = (type, detail) => {
    if (type === 'Goal') return detail === 'Penalty' ? '⚽ ر' : '⚽';
    if (type === 'Card') return detail === 'Yellow Card' ? '🟨' : '🟥';
    if (type === 'subst') return '🔄';
    return '•';
  };

  const getEventLabel = (type, detail) => {
    if (type === 'Goal') return detail === 'Penalty' ? 'هدف (ركلة جزاء)' : 'هدف';
    if (type === 'Card') return detail === 'Yellow Card' ? 'إنذار' : 'طرد';
    if (type === 'subst') return 'تبديل';
    return detail;
  };

  return (
    <div className="space-y-2">
      {events.map((ev, i) => {
        const isHome = ev.team?.name === teams?.home?.name;
        return (
          <div key={i} className={`flex items-center gap-3 p-3 rounded-lg bg-card border border-border ${isHome ? 'flex-row' : 'flex-row-reverse'}`}>
            <span className="text-2xl">{getEventIcon(ev.type, ev.detail)}</span>
            <div className={`flex-1 ${isHome ? 'text-right' : 'text-left'}`}>
              <p className="text-sm font-semibold">{ev.player?.name}</p>
              <p className="text-xs text-muted-foreground">{getEventLabel(ev.type, ev.detail)} — {ev.team?.name}</p>
            </div>
            <span className="text-sm font-black text-primary min-w-[32px] text-center">{ev.time?.elapsed}'</span>
          </div>
        );
      })}
    </div>
  );
}
