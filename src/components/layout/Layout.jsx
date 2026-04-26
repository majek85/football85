import { Outlet } from 'react-router-dom';
import Navbar from './Navbar';
import Footer from './Footer';
import AdBanner from './AdBanner';

export default function Layout() {
  return (
    <div className="min-h-screen bg-background flex flex-col font-cairo" dir="rtl">
      {/* Mobile Ad Top */}
      <div className="md:hidden px-4 pt-2">
        <AdBanner size="mobile" />
      </div>
      <Navbar />
      <main className="flex-1">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}
