import { useState } from 'react';
import { MOCK_NEWS } from '@/services/footballService';
import NewsCard from '@/components/news/NewsCard';
import AdBanner from '@/components/layout/AdBanner';

const CATEGORIES = ['الكل', 'دوري الأبطال', 'الدوري الإنجليزي', 'انتقالات', 'تصريحات', 'دوري روشن'];

export default function NewsPage() {
  const [activeCategory, setActiveCategory] = useState('الكل');

  const filtered = activeCategory === 'الكل'
    ? MOCK_NEWS
    : MOCK_NEWS.filter(a => a.category === activeCategory);

  const [featured, ...rest] = filtered;

  return (
    <div className="max-w-7xl mx-auto px-4 py-4 space-y-4">
      <AdBanner size="leaderboard" className="hidden md:flex" />

      <h1 className="text-xl font-black">📰 الأخبار الرياضية</h1>

      {/* Category filter */}
      <div className="flex gap-2 overflow-x-auto pb-1">
        {CATEGORIES.map(cat => (
          <button
            key={cat}
            onClick={() => setActiveCategory(cat)}
            className={`flex-shrink-0 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors border ${
              activeCategory === cat
                ? 'bg-primary text-primary-foreground border-primary'
                : 'bg-card border-border text-muted-foreground hover:text-foreground hover:bg-muted'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Featured */}
      {featured && <NewsCard article={featured} featured={true} />}

      {/* Rest */}
      <div className="grid gap-3 sm:grid-cols-2">
        {rest.map(article => (
          <NewsCard key={article.id} article={article} />
        ))}
      </div>

      <AdBanner size="mobile" className="md:hidden" />
    </div>
  );
}
