// components/KPICard.tsx
interface KPICardProps {
  label: string;
  value: string | number;
}

export default function KPICard({ label, value }: KPICardProps) {
  return (
    <div style={{
      backgroundColor: '#f3f4f6',
      padding: '1.5rem',
      borderRadius: '0.5rem',
      border: '1px solid #e5e7eb'
    }}>
      <p style={{ fontSize: '0.875rem', color: '#6b7280', marginBottom: '0.5rem' }}>
        {label}
      </p>
      <p style={{ fontSize: '1.875rem', fontWeight: 'bold', color: '#111827' }}>
        {value}
      </p>
    </div>
  );
}