import { RefreshCw } from 'lucide-react';
import { format } from 'date-fns';

function TeamLogo({ logo, name }) {
  if (logo) return <img src={logo} alt={name} className="w-14 h-14 object-contain" onError={e => e.target.style.display='none'} />;
  return <div className="w-14 h-14 rounded-full bg-muted flex items-center justify-center text-xl font-bold">{name?.[0]}</div>;
}

function StatusBadge({ status, elapsed }) {
  const isLive = ['LIVE','1H','2H','HT','ET'].includes(status);
  const isFinished = ['FT','AET','PEN'].includes(status);
  if (isLive) return (
    <div className="flex flex-col items-center gap-0.5">
      <span className="bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded live-pulse">مباشر</span>
      {elapsed && <span className="text-red-500 text-sm font-bold">{elapsed}'</span>}
    </div>
  );
  if (isFinished) return <span className="text-xs text-muted-foreground bg-muted px-2 py-1 rounded">انتهت</span>;
  return <span className="text-xs text-muted-foreground">لم تبدأ</span>;
}

export default function MatchHeader({ match, onRefresh }) {
  const { fixture, teams, goals, league } = match;
  const status = fixture?.status?.short;
  const isLive = ['LIVE','1H','2H','HT','ET'].includes(status);
  const isFinished = ['FT','AET','PEN'].includes(status);
  const showScore = isLive || isFinished;

  return (
    <div className="bg-card border border-border rounded-xl overflow-hidden">
      {/* League bar */}
      <div className="flex items-center justify-between px-4 py-2 bg-muted/50 border-b border-border">
        <div className="flex items-center gap-2">
          {league?.logo && <img src={league.logo} alt={league.name} className="w-5 h-5 object-contain" onError={e=>e.target.style.display='none'} />}
          <span className="text-xs font-semibold text-muted-foreground">{league?.name} — {league?.country}</span>
        </div>
        <button onClick={onRefresh} className="text-muted-foreground hover:text-primary transition-colors p-1 rounded">
          <RefreshCw size={14} />
        </button>
      </div>

      {/* Teams & Score */}
      <div className="flex items-center justify-between px-6 py-6 gap-4">
        {/* Home */}
        <div className="flex-1 flex flex-col items-center gap-2">
          <TeamLogo logo={teams?.home?.logo} name={teams?.home?.name} />
          <span className="text-sm font-bold text-center">{teams?.home?.name}</span>
        </div>

        {/* Middle */}
        <div className="flex flex-col items-center gap-1 min-w-[100px]">
          {showScore ? (
            <div className={`text-4xl font-black ${isLive ? 'text-red-500' : 'text-foreground'}`}>
              {goals?.home ?? 0} - {goals?.away ?? 0}
            </div>
          ) : (
            <div className="text-lg font-bold text-muted-foreground">
              {fixture?.date ? format(new Date(fixture.date), 'HH:mm') : '--:--'}
            </div>
          )}
          <StatusBadge status={status} elapsed={fixture?.status?.elapsed} />
        </div>

        {/* Away */}
        <div className="flex-1 flex flex-col items-center gap-2">
          <TeamLogo logo={teams?.away?.logo} name={teams?.away?.name} />
          <span className="text-sm font-bold text-center">{teams?.away?.name}</span>
        </div>
      </div>
    </div>
  );
}
