import { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, Tv2, Newspaper, Trophy, Activity, Zap } from 'lucide-react';

const navLinks = [
  { path: '/', label: 'الرئيسية', icon: Zap },
  { path: '/football', label: 'كرة القدم', icon: Trophy },
  { path: '/sports', label: 'رياضات أخرى', icon: Activity },
  { path: '/news', label: 'الأخبار', icon: Newspaper },
  { path: '/live', label: 'مباشر', icon: Tv2 },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const location = useLocation();

  return (
    <header className="sticky top-0 z-50 bg-card border-b border-border shadow-sm">
      <div className="max-w-7xl mx-auto px-4">
        <div className="flex items-center justify-between h-14">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2 font-cairo font-black text-xl">
            <span className="bg-primary text-primary-foreground px-2 py-0.5 rounded text-sm font-black">⚽</span>
            <span className="text-foreground">85<span className="text-primary">"</span></span>
          </Link>

          {/* Desktop Nav */}
          <nav className="hidden md:flex items-center gap-1">
            {navLinks.map(({ path, label, icon: Icon }) => {
              const isActive = location.pathname === path;
              const isLive = path === '/live';
              return (
                <Link
                  key={path}
                  to={path}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm font-medium transition-colors ${
                    isActive
                      ? 'bg-primary text-primary-foreground'
                      : isLive
                      ? 'text-red-500 hover:bg-red-50'
                      : 'text-muted-foreground hover:text-foreground hover:bg-muted'
                  }`}
                >
                  {isLive && <span className="w-2 h-2 rounded-full bg-red-500 live-pulse" />}
                  <Icon size={14} />
                  {label}
                </Link>
              );
            })}
          </nav>

          {/* Mobile Toggle */}
          <button
            className="md:hidden p-2 rounded-md hover:bg-muted"
            onClick={() => setOpen(!open)}
          >
            {open ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {open && (
        <div className="md:hidden border-t border-border bg-card">
          <nav className="flex flex-col p-2 gap-1">
            {navLinks.map(({ path, label, icon: Icon }) => {
              const isActive = location.pathname === path;
              const isLive = path === '/live';
              return (
                <Link
                  key={path}
                  to={path}
                  onClick={() => setOpen(false)}
                  className={`flex items-center gap-2 px-3 py-2.5 rounded-md text-sm font-medium transition-colors ${
                    isActive
                      ? 'bg-primary text-primary-foreground'
                      : isLive
                      ? 'text-red-500'
                      : 'text-muted-foreground hover:text-foreground hover:bg-muted'
                  }`}
                >
                  {isLive && <span className="w-2 h-2 rounded-full bg-red-500 live-pulse" />}
                  <Icon size={16} />
                  {label}
                </Link>
              );
            })}
          </nav>
        </div>
      )}
    </header>
  );
}
