import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';
import { footballAPI, MOCK_MATCHES } from '@/services/footballService';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Skeleton } from '@/components/ui/skeleton';
import MatchHeader from '@/components/matches/MatchHeader';
import MatchEvents from '@/components/matches/MatchEvents';
import LineupPitch from '@/components/matches/LineupPitch';
import AdBanner from '@/components/layout/AdBanner';

const GET_MOCK_EVENTS = (id) => {
  if (id !== '101') return [];
  return [
    { time: { elapsed: 12 }, type: 'Goal', detail: 'Normal Goal', player: { name: 'Vinícius Jr.' }, team: { name: 'ريال مدريد' } },
    { time: { elapsed: 34 }, type: 'Card', detail: 'Yellow Card', player: { name: 'Rodri' }, team: { name: 'مان سيتي' } },
    { time: { elapsed: 45 }, type: 'Goal', detail: 'Penalty', player: { name: 'Haaland' }, team: { name: 'مان سيتي' } },
    { time: { elapsed: 67 }, type: 'Goal', detail: 'Normal Goal', player: { name: 'Bellingham' }, team: { name: 'ريال مدريد' } },
    { time: { elapsed: 78 }, type: 'subst', detail: 'Substitution', player: { name: 'Modric' }, team: { name: 'ريال مدريد' } },
  ];
};

export default function MatchDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [match, setMatch] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchMatch = async () => {
      setLoading(true);
      try {
        const data = await footballAPI.getMatch(id);
        if (data) {
          setMatch(data);
        } else {
          // Fallback: find in mock data
          const found = MOCK_MATCHES.find(m => String(m.fixture?.id) === id);
          setMatch(found || MOCK_MATCHES[0]);
        }
      } catch (e) {
        const found = MOCK_MATCHES.find(m => String(m.fixture?.id) === id);
        setMatch(found || MOCK_MATCHES[0]);
      } finally {
        setLoading(false);
      }
    };
    fetchMatch();
  }, [id]);

  if (loading) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-4 space-y-4">
        <Skeleton className="h-8 w-24 rounded-lg" />
        <Skeleton className="h-40 w-full rounded-xl" />
        <Skeleton className="h-10 w-full rounded-lg" />
        <Skeleton className="h-64 w-full rounded-xl" />
      </div>
    );
  }

  if (!match) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-16 text-center">
        <p className="text-4xl mb-4">🔍</p>
        <p className="text-lg font-bold mb-2">المباراة غير موجودة</p>
        <button onClick={() => navigate(-1)} className="text-primary hover:underline text-sm">
          العودة للخلف
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto px-4 py-4 space-y-4">
      <button
        onClick={() => navigate(-1)}
        className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
      >
        <ArrowRight size={16} />
        العودة
      </button>

      <MatchHeader match={match} onRefresh={() => {}} />

      <AdBanner size="leaderboard" className="hidden md:flex" />

      <Tabs defaultValue="events" dir="rtl">
        <TabsList className="w-full grid grid-cols-3">
          <TabsTrigger value="events">الأحداث</TabsTrigger>
          <TabsTrigger value="lineup">التشكيلة</TabsTrigger>
          <TabsTrigger value="stats">الإحصاءات</TabsTrigger>
        </TabsList>

        <TabsContent value="events" className="mt-4">
          <MatchEvents events={GET_MOCK_EVENTS(match.fixture.id)} teams={match.teams} />
        </TabsContent>

        <TabsContent value="lineup" className="mt-4">
          <LineupPitch lineups={null} teams={match.teams} />
        </TabsContent>

        <TabsContent value="stats" className="mt-4">
          <div className="text-center py-12 text-muted-foreground">
            <p className="text-3xl mb-3">📊</p>
            <p className="font-medium">الإحصاءات غير متاحة</p>
            <p className="text-xs mt-1">متوفرة في النسخة المدفوعة من API</p>
          </div>
        </TabsContent>
      </Tabs>

      <AdBanner size="mobile" className="md:hidden" />
    </div>
  );
}
