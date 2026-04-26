import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from '@/components/layout/Layout';
import HomePage from '@/pages/HomePage';
import FootballPage from '@/pages/FootballPage';
import SportsPage from '@/pages/SportsPage';
import NewsPage from '@/pages/NewsPage';
import LivePage from '@/pages/LivePage';
import MatchDetailPage from '@/pages/MatchDetailPage';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<HomePage />} />
          <Route path="football" element={<FootballPage />} />
          <Route path="sports" element={<SportsPage />} />
          <Route path="news" element={<NewsPage />} />
          <Route path="live" element={<LivePage />} />
          <Route path="match/:id" element={<MatchDetailPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
