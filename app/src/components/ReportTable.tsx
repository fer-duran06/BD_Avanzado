// components/ReportTable.tsx
interface ReportTableProps {
  data: any[];
  columns: string[];
}

export default function ReportTable({ data, columns }: ReportTableProps) {
  if (data.length === 0) {
    return <p>No hay datos disponibles</p>;
  }

  return (
    <div style={{ overflowX: 'auto' }}>
      <table style={{
        width: '100%',
        borderCollapse: 'collapse',
        backgroundColor: 'white',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
      }}>
        <thead style={{ backgroundColor: '#f9fafb' }}>
          <tr>
            {columns.map((col) => (
              <th key={col} style={{
                padding: '0.75rem 1rem',
                textAlign: 'left',
                fontSize: '0.875rem',
                fontWeight: '600',
                color: '#374151',
                borderBottom: '1px solid #e5e7eb'
              }}>
                {col.replace(/_/g, ' ').toUpperCase()}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, idx) => (
            <tr key={idx} style={{ borderBottom: '1px solid #e5e7eb' }}>
              {columns.map((col) => (
                <td key={col} style={{
                  padding: '0.75rem 1rem',
                  fontSize: '0.875rem',
                  color: '#111827'
                }}>
                  {formatValue(row[col])}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function formatValue(value: any): string {
  if (value === null || value === undefined) return '-';
  if (typeof value === 'number') {
    return value % 1 === 0 ? value.toString() : value.toFixed(2);
  }
  if (typeof value === 'boolean') return value ? 'Sí' : 'No';
  return String(value);
}