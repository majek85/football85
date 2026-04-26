import AdBanner from '@/components/layout/AdBanner';
import { Activity, Trophy, Dumbbell, Bike, Waves } from 'lucide-react';

const SPORTS = [
  { icon: '🏀', name: 'كرة السلة', matches: 8, live: 2 },
  { icon: '🎾', name: 'التنس', matches: 12, live: 5 },
  { icon: '🏐', name: 'كرة الطائرة', matches: 4, live: 0 },
  { icon: '🏏', name: 'الكريكيت', matches: 3, live: 1 },
  { icon: '🥊', name: 'الملاكمة', matches: 2, live: 0 },
  { icon: '🏊', name: 'السباحة', matches: 6, live: 3 },
  { icon: '🚴', name: 'الدراجات', matches: 2, live: 1 },
  { icon: '🤼', name: 'المصارعة', matches: 4, live: 0 },
];

export default function SportsPage() {
  return (
    <div className="max-w-7xl mx-auto px-4 py-4 space-y-4">
      <AdBanner size="leaderboard" className="hidden md:flex" />

      <h1 className="text-xl font-black flex items-center gap-2">
        <Activity size={22} className="text-primary" />
        رياضات أخرى
      </h1>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
        {SPORTS.map(sport => (
          <div
            key={sport.name}
            className="bg-card border border-border rounded-xl p-4 hover:shadow-md hover:border-primary/30 transition-all cursor-pointer group"
          >
            <div className="text-4xl mb-3 group-hover:scale-110 transition-transform">{sport.icon}</div>
            <h3 className="font-bold text-sm mb-1">{sport.name}</h3>
            <div className="flex items-center gap-2">
              <span className="text-xs text-muted-foreground">{sport.matches} مباراة</span>
              {sport.live > 0 && (
                <span className="text-[10px] bg-red-500 text-white px-1.5 py-0.5 rounded-full live-pulse font-bold">
                  {sport.live} مباشر
                </span>
              )}
            </div>
          </div>
        ))}
      </div>

      <div className="bg-card border border-border rounded-xl p-6 text-center">
        <p className="text-2xl mb-2">🏆</p>
        <p className="font-bold text-base mb-1">قريباً — تغطية كاملة لجميع الرياضات</p>
        <p className="text-sm text-muted-foreground">سيتم إضافة نتائج ومباريات مباشرة لجميع الألعاب الرياضية</p>
      </div>

      <AdBanner size="mobile" className="md:hidden" />
    </div>
  );
}
