export default function NewsCard({ article, featured = false }) {
  if (featured) {
    return (
      <div className="relative rounded-xl overflow-hidden cursor-pointer group bg-card border border-border hover:shadow-lg transition-all">
        <div className="aspect-[16/7] overflow-hidden">
          <img
            src={article.image}
            alt={article.title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
        </div>
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />
        <div className="absolute bottom-0 p-4 text-white">
          <span className="text-xs bg-primary text-primary-foreground px-2 py-0.5 rounded mb-2 inline-block">
            {article.category}
          </span>
          <h2 className="text-lg font-bold leading-snug">{article.title}</h2>
          <p className="text-xs text-white/70 mt-1">{article.time}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex gap-3 bg-card rounded-lg border border-border p-3 hover:shadow-md hover:border-primary/30 transition-all cursor-pointer group">
      <div className="w-20 h-16 rounded-md overflow-hidden flex-shrink-0">
        <img
          src={article.image}
          alt={article.title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
        />
      </div>
      <div className="flex-1 min-w-0">
        <span className="text-xs text-primary font-medium">{article.category}</span>
        <h3 className="text-sm font-semibold leading-snug line-clamp-2 mt-0.5">{article.title}</h3>
        <p className="text-xs text-muted-foreground mt-1">{article.time}</p>
      </div>
    </div>
  );
}
