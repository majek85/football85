import { useState, useEffect } from 'react';
import { footballAPI } from '@/services/footballService';
import MatchCard from '@/components/matches/MatchCard';
import AdBanner from '@/components/layout/AdBanner';
import { Skeleton } from '@/components/ui/skeleton';
import { RefreshCw, WifiOff } from 'lucide-react';

const LEAGUES = [
  { id: 'all', name: 'الكل' },
  { id: '4328', name: 'الإنجليزي' },
  { id: '4335', name: 'الإسباني' },
  { id: '4332', name: 'الألماني' },
  { id: '4331', name: 'الفرنسي' },
  { id: '4334', name: 'الإيطالي' },
  { id: '4480', name: 'أبطال أوروبا' },
];

export default function FootballPage() {
  const [matches, setMatches] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [activeLeague, setActiveLeague] = useState('all');

  const fetchData = async () => {
    setLoading(true);
    setError(false);
    try {
      const data = await footballAPI.getTodayMatches();
      if (data && data.length > 0) setMatches(data);
      else setError(true);
    } catch (e) {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  const filtered = activeLeague === 'all'
    ? matches
    : matches.filter(m => String(m.league?.id) === activeLeague);

  return (
    <div className="max-w-7xl mx-auto px-4 py-4 space-y-4">
      <AdBanner size="leaderboard" className="hidden md:flex" />
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-black">⚽ كرة القدم</h1>
        <button onClick={fetchData} className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-primary transition-colors px-3 py-1.5 border border-border rounded-lg hover:bg-muted">
          <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
          تحديث
        </button>
      </div>

      <div className="flex gap-2 overflow-x-auto pb-1">
        {LEAGUES.map(l => (
          <button key={l.id} onClick={() => setActiveLeague(l.id)}
            className={`flex-shrink-0 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors border ${activeLeague === l.id ? 'bg-primary text-primary-foreground border-primary' : 'bg-card border-border text-muted-foreground hover:text-foreground hover:bg-muted'}`}
          >{l.name}</button>
        ))}
      </div>

      {loading ? (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {[1,2,3,4,5,6].map(i => <Skeleton key={i} className="h-24 w-full rounded-xl" />)}
        </div>
      ) : error ? (
        <div className="flex flex-col items-center justify-center py-16 gap-4 text-center">
          <div className="w-16 h-16 rounded-full bg-muted flex items-center justify-center">
            <WifiOff size={28} className="text-muted-foreground" />
          </div>
          <div>
            <p className="font-bold text-base mb-1">تعذّر تحميل المباريات</p>
            <p className="text-sm text-muted-foreground">تحقق من اتصالك بالإنترنت وحاول مجدداً</p>
          </div>
          <button onClick={fetchData} className="flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-lg text-sm font-medium hover:bg-primary/90 transition-colors">
            <RefreshCw size={15} />إعادة المحاولة
          </button>
        </div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <p className="text-4xl mb-3">⚽</p>
          <p className="font-medium">لا توجد مباريات في هذه الفئة</p>
        </div>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((match, i) => <MatchCard key={i} match={match} />)}
        </div>
      )}
      <AdBanner size="mobile" className="md:hidden" />
    </div>
  );
}
