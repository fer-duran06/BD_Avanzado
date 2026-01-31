export default function DataTable({ data }: { data: any[] }) {
  if (!data || data.length === 0) {
    return <div className="p-4 text-gray-500 bg-white rounded border">No hay datos para mostrar.</div>;
  }

  // Obtenemos los nombres de las columnas dinámicamente
  const headers = Object.keys(data[0]);

  return (
    <div className="overflow-x-auto border rounded-lg shadow-sm">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {headers.map((header) => (
              <th key={header} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {header.replace(/_/g, ' ')}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {data.map((row, i) => (
            <tr key={i} className="hover:bg-gray-50 transition-colors">
              {headers.map((header) => (
                <td key={`${i}-${header}`} className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                  {/* Si el dato es null o undefined, mostramos guión */}
                  {row[header] !== null ? String(row[header]) : '-'}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}