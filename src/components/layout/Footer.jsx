export default function Footer() {
  return (
    <footer className="mt-10 border-t border-border bg-card">
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2 font-cairo font-black text-lg">
            <span className="bg-primary text-primary-foreground px-2 py-0.5 rounded text-sm">⚽</span>
            <span>85<span className="text-primary">"</span></span>
          </div>
          <p className="text-xs text-muted-foreground text-center">
            جميع الحقوق محفوظة © 2026 — بيانات المباريات مقدمة من API-Football
          </p>
          <div className="flex gap-4 text-xs text-muted-foreground">
            <a href="#" className="hover:text-primary transition-colors">عن الموقع</a>
            <a href="#" className="hover:text-primary transition-colors">تواصل معنا</a>
            <a href="#" className="hover:text-primary transition-colors">سياسة الخصوصية</a>
          </div>
        </div>
      </div>
    </footer>
  );
}
