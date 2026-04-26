import { Clock } from 'lucide-react';
import { format } from 'date-fns';
import { Link } from 'react-router-dom';

function TeamLogo({ logo, name }) {
  if (logo) {
    return (
      <img
        src={logo}
        alt={name}
        className="w-8 h-8 object-contain"
        onError={(e) => { e.target.style.display = 'none'; }}
      />
    );
  }
  return (
    <div className="w-8 h-8 rounded-full bg-muted flex items-center justify-center text-xs font-bold">
      {name?.[0]}
    </div>
  );
}

function StatusBadge({ status, elapsed }) {
  if (status === 'LIVE' || status === '1H' || status === '2H' || status === 'HT' || status === 'ET') {
    return (
      <div className="flex flex-col items-center gap-0.5">
        <span className="bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded live-pulse">مباشر</span>
        {elapsed && <span className="text-red-500 text-xs font-bold">{elapsed}'</span>}
      </div>
    );
  }
  if (status === 'FT' || status === 'AET' || status === 'PEN') {
    return <span className="text-muted-foreground text-xs">انتهت</span>;
  }
  if (status === 'NS') {
    return <span className="text-muted-foreground text-xs">لم تبدأ</span>;
  }
  return <span className="text-muted-foreground text-xs">{status}</span>;
}

export default function MatchCard({ match, compact = false }) {
  const { fixture, teams, goals, league } = match;
  const status = fixture?.status?.short;
  const elapsed = fixture?.status?.elapsed;
  const isLive = ['LIVE', '1H', '2H', 'HT', 'ET'].includes(status);
  const isFinished = ['FT', 'AET', 'PEN'].includes(status);

  const matchTime = fixture?.date
    ? format(new Date(fixture.date), 'HH:mm')
    : '--:--';

  return (
    <Link to={`/match/${fixture?.id || 1}`} className={`block bg-card rounded-lg border transition-all hover:shadow-md hover:border-primary/30 cursor-pointer ${isLive ? 'border-red-200 bg-red-50/30' : 'border-border'} ${compact ? 'p-2' : 'p-3'}`}>
      {/* League info */}
      {!compact && league && (
        <div className="flex items-center gap-1.5 mb-2 pb-2 border-b border-border">
          {league.logo && <img src={league.logo} alt={league.name} className="w-4 h-4 object-contain" onError={(e) => { e.target.style.display = 'none'; }} />}
          <span className="text-xs text-muted-foreground font-medium">{league.name}</span>
        </div>
      )}

      {/* Match row */}
      <div className="flex items-center gap-2">
        {/* Home team */}
        <div className="flex-1 flex items-center gap-2 justify-end">
          <span className={`text-sm font-semibold text-right ${compact ? 'text-xs' : ''}`}>{teams?.home?.name}</span>
          <TeamLogo logo={teams?.home?.logo} name={teams?.home?.name} />
        </div>

        {/* Score / Status */}
        <div className="flex flex-col items-center min-w-[64px]">
          {(isLive || isFinished) ? (
            <div className="flex items-center gap-1 text-base font-black">
              <span className={isLive ? 'text-red-500' : ''}>{goals?.home ?? 0}</span>
              <span className="text-muted-foreground text-xs">-</span>
              <span className={isLive ? 'text-red-500' : ''}>{goals?.away ?? 0}</span>
            </div>
          ) : (
            <div className="flex items-center gap-1 text-xs text-muted-foreground">
              <Clock size={12} />
              <span>{matchTime}</span>
            </div>
          )}
          <StatusBadge status={status} elapsed={elapsed} />
        </div>

        {/* Away team */}
        <div className="flex-1 flex items-center gap-2">
          <TeamLogo logo={teams?.away?.logo} name={teams?.away?.name} />
          <span className={`text-sm font-semibold ${compact ? 'text-xs' : ''}`}>{teams?.away?.name}</span>
        </div>
      </div>
    </Link>
  );
}
