import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Zap, Tv2, Trophy, TrendingUp, RefreshCw, WifiOff } from 'lucide-react';
import { footballAPI, MOCK_NEWS } from '@/services/footballService';
import { Skeleton } from '@/components/ui/skeleton';
import SectionHeader from '@/components/layout/SectionHeader';
import AdBanner from '@/components/layout/AdBanner';
import NewsCard from '@/components/news/NewsCard';

function MatchRow({ match }) {
  const navigate = useNavigate();
  const { fixture, teams, goals } = match;
  const status = fixture?.status?.short;
  const isLive = ['LIVE', '1H', '2H', 'HT', 'ET'].includes(status);
  const isFinished = ['FT', 'AET', 'PEN'].includes(status);

  const getTime = () => {
    if (!fixture?.date) return '--:--';
    return new Date(fixture.date).toLocaleTimeString('ar-SA', { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div
      onClick={() => navigate(`/match/${fixture?.id}`)}
      className={`flex items-center gap-2 px-3 py-2.5 rounded-lg border cursor-pointer transition-all hover:shadow-md hover:border-primary/40 ${isLive ? 'border-red-200 bg-red-50/20 dark:bg-red-900/10' : 'border-border bg-card'}`}
    >
      <div className="flex-1 flex items-center gap-2 justify-end">
        <span className="text-sm font-semibold text-right truncate max-w-[100px]">{teams?.home?.name}</span>
        <img src={teams?.home?.logo} alt="" className="w-7 h-7 object-contain" onError={e => e.target.style.display='none'} />
      </div>
      <div className="flex flex-col items-center min-w-[60px]">
        {(isLive || isFinished) ? (
          <span className={`text-base font-black ${isLive ? 'text-red-500' : ''}`}>
            {goals?.home ?? 0} - {goals?.away ?? 0}
          </span>
        ) : (
          <span className="text-xs text-muted-foreground font-medium">{getTime()}</span>
        )}
        {isLive && <span className="text-[10px] bg-red-500 text-white px-1.5 rounded live-pulse font-bold">مباشر</span>}
        {isFinished && <span className="text-[10px] text-muted-foreground">انتهت</span>}
        {status === 'NS' && <span className="text-[10px] text-muted-foreground">قادمة</span>}
      </div>
      <div className="flex-1 flex items-center gap-2">
        <img src={teams?.away?.logo} alt="" className="w-7 h-7 object-contain" onError={e => e.target.style.display='none'} />
        <span className="text-sm font-semibold truncate max-w-[100px]">{teams?.away?.name}</span>
      </div>
    </div>
  );
}

function LeagueGroup({ leagueName, leagueLogo, matches }) {
  return (
    <div className="bg-card border border-border rounded-xl overflow-hidden mb-3">
      <div className="flex items-center gap-2 px-3 py-2 bg-muted/50 border-b border-border">
        {leagueLogo && <img src={leagueLogo} alt={leagueName} className="w-5 h-5 object-contain" onError={e => e.target.style.display='none'} />}
        <span className="text-xs font-bold text-foreground">{leagueName}</span>
      </div>
      <div className="divide-y divide-border">
        {matches.map((m, i) => (
          <div key={i} className="px-2 py-1">
            <MatchRow match={m} />
          </div>
        ))}
      </div>
    </div>
  );
}

function ErrorState({ onRetry }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 gap-4 text-center">
      <div className="w-16 h-16 rounded-full bg-muted flex items-center justify-center">
        <WifiOff size={28} className="text-muted-foreground" />
      </div>
      <div>
        <p className="font-bold text-base mb-1">تعذّر تحميل المباريات</p>
        <p className="text-sm text-muted-foreground">تحقق من اتصالك بالإنترنت وحاول مجدداً</p>
      </div>
      <button
        onClick={onRetry}
        className="flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-lg text-sm font-medium hover:bg-primary/90 transition-colors"
      >
        <RefreshCw size={15} />
        إعادة المحاولة
      </button>
    </div>
  );
}

export default function HomePage() {
  const [matches, setMatches] = useState([]);
  const [news] = useState(MOCK_NEWS);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [lastUpdate, setLastUpdate] = useState(null);
  const navigate = useNavigate();

  const fetchData = async () => {
    setLoading(true);
    setError(false);
    try {
      const data = await footballAPI.getTodayMatches();
      if (data && data.length > 0) {
        setMatches(data);
        setLastUpdate(new Date());
      } else {
        setError(true);
      }
    } catch (e) {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  const liveMatches = matches.filter(m => ['LIVE', '1H', '2H', 'HT', 'ET'].includes(m.fixture?.status?.short));

  const grouped = matches.reduce((acc, m) => {
    const key = m.league?.name || 'أخرى';
    if (!acc[key]) acc[key] = { logo: m.league?.logo, matches: [] };
    acc[key].matches.push(m);
    return acc;
  }, {});

  return (
    <div className="max-w-7xl mx-auto px-4 py-4 space-y-5">
      <AdBanner size="leaderboard" className="hidden md:flex" />

      {/* Live strip */}
      {liveMatches.length > 0 && (
        <div className="bg-gradient-to-l from-red-600/10 to-red-500/5 border border-red-200 dark:border-red-800 rounded-xl p-3">
          <div className="flex items-center gap-2 mb-2">
            <span className="w-2.5 h-2.5 rounded-full bg-red-500 live-pulse inline-block" />
            <span className="text-sm font-bold text-red-500">مباريات مباشرة الآن</span>
            {lastUpdate && (
              <span className="text-xs text-muted-foreground mr-auto">
                {lastUpdate.toLocaleTimeString('ar-SA', { hour: '2-digit', minute: '2-digit' })}
              </span>
            )}
            <button onClick={fetchData} className="text-muted-foreground hover:text-primary p-1 rounded transition-colors">
              <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
            </button>
          </div>
          <div className="grid gap-2 sm:grid-cols-2">
            {liveMatches.map((m, i) => <MatchRow key={i} match={m} />)}
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        <div className="lg:col-span-2 space-y-4">
          <SectionHeader title="مباريات اليوم" icon="⚽" action={() => navigate('/football')} actionLabel="عرض الكل" />

          {loading ? (
            <div className="space-y-3">
              {[1,2,3].map(i => <Skeleton key={i} className="h-20 w-full rounded-xl" />)}
            </div>
          ) : error ? (
            <ErrorState onRetry={fetchData} />
          ) : (
            Object.entries(grouped).map(([league, { logo, matches: lm }]) => (
              <LeagueGroup key={league} leagueName={league} leagueLogo={logo} matches={lm} />
            ))
          )}
        </div>

        <div className="space-y-4">
          <AdBanner size="rectangle" className="hidden md:flex mx-auto" />
          <div className="grid grid-cols-2 gap-2">
            {[
              { icon: Tv2, label: 'مباشر', path: '/live', color: 'text-red-500', bg: 'bg-red-50 dark:bg-red-900/20 border-red-200' },
              { icon: Trophy, label: 'الدوريات', path: '/football', color: 'text-yellow-500', bg: 'bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200' },
              { icon: TrendingUp, label: 'الأخبار', path: '/news', color: 'text-blue-500', bg: 'bg-blue-50 dark:bg-blue-900/20 border-blue-200' },
              { icon: Zap, label: 'رياضات', path: '/sports', color: 'text-purple-500', bg: 'bg-purple-50 dark:bg-purple-900/20 border-purple-200' },
            ].map(({ icon: Icon, label, path, color, bg }) => (
              <button key={path} onClick={() => navigate(path)} className={`flex flex-col items-center gap-2 p-4 rounded-xl border transition-all hover:shadow-md ${bg}`}>
                <Icon className={color} size={22} />
                <span className="text-xs font-bold">{label}</span>
              </button>
            ))}
          </div>
          <div>
            <SectionHeader title="آخر الأخبار" icon="📰" action={() => navigate('/news')} />
            <div className="space-y-2">
              {news.slice(0, 3).map(article => <NewsCard key={article.id} article={article} />)}
            </div>
          </div>
        </div>
      </div>
      <AdBanner size="mobile" className="md:hidden" />
    </div>
  );
}
