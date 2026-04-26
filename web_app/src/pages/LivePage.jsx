import { useState, useEffect } from 'react';
import { footballAPI, MOCK_MATCHES } from '@/services/footballService';
import MatchCard from '@/components/matches/MatchCard';
import AdBanner from '@/components/layout/AdBanner';
import { Skeleton } from '@/components/ui/skeleton';
import { RefreshCw } from 'lucide-react';

const LIVE_STATUSES = ['LIVE', '1H', '2H', 'HT', 'ET'];

export default function LivePage() {
  const [liveMatches, setLiveMatches] = useState([]);
  const [loading, setLoading] = useState(true);
  const [lastUpdate, setLastUpdate] = useState(new Date());

  const fetchData = async () => {
    setLoading(true);
    try {
      const data = await footballAPI.getLiveMatches();
      if (data && Array.isArray(data)) setLiveMatches(data);
    } catch (e) {
      // fallback — filter from mock
      setLiveMatches(MOCK_MATCHES.filter(m => LIVE_STATUSES.includes(m.fixture?.status?.short)));
    } finally {
      setLoading(false);
      setLastUpdate(new Date());
    }
  };

  useEffect(() => {
    fetchData();
    // Auto-refresh every 60 seconds
    const interval = setInterval(fetchData, 60000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="max-w-7xl mx-auto px-4 py-4 space-y-4">
      <AdBanner size="leaderboard" className="hidden md:flex" />

      <div className="flex items-center gap-3">
        <span className="w-3 h-3 rounded-full bg-red-500 live-pulse inline-block" />
        <h1 className="text-xl font-black text-red-500">مباريات مباشرة</h1>
        {!loading && (
          <span className="text-xs bg-red-100 dark:bg-red-900/30 text-red-500 px-2 py-0.5 rounded-full font-bold">
            {liveMatches.length} مباراة
          </span>
        )}
        <div className="mr-auto flex items-center gap-2 text-xs text-muted-foreground">
          <span>{lastUpdate.toLocaleTimeString('ar-SA', { hour: '2-digit', minute: '2-digit' })}</span>
          <button onClick={fetchData} className="hover:text-primary transition-colors">
            <RefreshCw size={13} className={loading ? 'animate-spin' : ''} />
          </button>
        </div>
      </div>

      {loading ? (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {[1,2,3].map(i => <Skeleton key={i} className="h-24 w-full rounded-xl" />)}
        </div>
      ) : liveMatches.length === 0 ? (
        <div className="text-center py-20 text-muted-foreground">
          <p className="text-5xl mb-4">📡</p>
          <p className="text-lg font-bold mb-2">لا توجد مباريات مباشرة الآن</p>
          <p className="text-sm">يتم التحديث تلقائياً كل دقيقة</p>
        </div>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {liveMatches.map((match, i) => <MatchCard key={i} match={match} />)}
        </div>
      )}

      <AdBanner size="mobile" className="md:hidden" />
    </div>
  );
}
