// مكون الإعلانات - يمكن ربطه لاحقاً بشبكة إعلانات مثل Google AdSense أو أي شبكة أخرى
export default function AdBanner({ size = 'leaderboard', className = '' }) {
  const sizes = {
    leaderboard: { w: '100%', h: '90px', label: '728×90 - Leaderboard' },
    rectangle: { w: '300px', h: '250px', label: '300×250 - Rectangle' },
    mobile: { w: '100%', h: '50px', label: '320×50 - Mobile Banner' },
  };

  const s = sizes[size] || sizes.leaderboard;

  return (
    <div
      className={`flex items-center justify-center bg-muted/50 border border-dashed border-border rounded-lg text-muted-foreground text-xs font-cairo ${className}`}
      style={{ width: s.w, minHeight: s.h }}
    >
      <span>📢 مساحة إعلانية — {s.label}</span>
    </div>
  );
}
