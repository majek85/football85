export default function SectionHeader({ title, icon, action, actionLabel }) {
  return (
    <div className="flex items-center justify-between mb-3">
      <div className="flex items-center gap-2">
        {icon && <span className="text-lg">{icon}</span>}
        <h2 className="text-base font-bold text-foreground">{title}</h2>
      </div>
      {action && (
        <button
          onClick={action}
          className="text-xs text-primary hover:underline font-medium"
        >
          {actionLabel || 'عرض الكل'}
        </button>
      )}
    </div>
  );
}
