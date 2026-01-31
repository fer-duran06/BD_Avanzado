import { getReportData } from '../../../lib/actions';
import DataTable from '../../../components/DataTable';
import Link from 'next/link';

const REPORT_META: Record<string, { title: string; desc: string }> = {
  '1': { title: 'Top Productos', desc: 'Productos más vendidos con clasificación de éxito.' },
  '2': { title: 'Ventas Mensuales', desc: 'Tendencias de ventas y KPIs por periodo.' },
  '3': { title: 'Valor de Clientes', desc: 'Segmentación de clientes VIP, Frecuentes y Nuevos.' },
  '4': { title: 'Performance Categorías', desc: 'Comparativa vs Promedio Global (CTE).' },
  '5': { title: 'Ranking Avanzado', desc: 'Análisis detallado con Window Functions.' },
};

// Definimos los tipos como Promesas (Requisito de Next.js 15/16)
type Props = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
};

export default async function ReportPage(props: Props) {
  // 1. Esperamos (await) a que los parámetros estén listos
  const params = await props.params;
  const searchParams = await props.searchParams;
  
  const { id } = params;
  const meta = REPORT_META[id];
  
  // Debug: Si no encuentra el reporte, mostramos qué ID intentó buscar
  if (!meta) return <div className="p-10 text-red-600">Reporte no encontrado (ID: {id})</div>;

  // 2. Llamamos a la base de datos con los parámetros ya procesados
  const { data, error, pagination } = await getReportData(id, searchParams);

  const currentPage = Number(pagination?.page || 1);

  return (
    <main className="p-8 max-w-7xl mx-auto">
      <Link href="/" className="text-blue-600 hover:underline mb-6 inline-block font-medium">
        &larr; Volver al Dashboard
      </Link>
      
      <div className="mb-8 bg-white p-6 rounded-lg shadow-sm border">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">{meta.title}</h1>
        <p className="text-gray-600">{meta.desc}</p>
      </div>

      {/* Filtro de Año (Solo para reporte 2) */}
      {id === '2' && (
        <form className="mb-6 flex gap-3 items-end bg-gray-50 p-4 rounded border">
          <label className="text-sm font-medium text-gray-700">
            Filtrar por Año:
            <input 
              name="anio" 
              type="number" 
              placeholder="Ej: 2024" 
              defaultValue={String(searchParams.anio || '')}
              className="block mt-1 border border-gray-300 p-2 rounded w-32" 
            />
          </label>
          <button type="submit" className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded transition-colors">
            Aplicar Filtro
          </button>
        </form>
      )}

      {error ? (
        <div className="p-4 bg-red-50 text-red-700 border border-red-200 rounded">
          <strong>Error:</strong> {error}
          <p className="text-sm mt-2 text-gray-600">Verifica que tu base de datos esté corriendo en Docker.</p>
        </div>
      ) : (
        <>
          <DataTable data={data || []} />
          
          {/* Paginación */}
          {id !== '4' && (
            <div className="mt-6 flex gap-3 justify-end items-center">
               <Link 
                 href={`/reports/${id}?page=${currentPage > 1 ? currentPage - 1 : 1}`}
                 className={`px-4 py-2 border rounded ${currentPage <= 1 ? 'opacity-50 pointer-events-none bg-gray-100' : 'hover:bg-gray-50 bg-white'}`}
               >
                 Anterior
               </Link>
               <span className="text-sm font-medium">Pág {currentPage}</span>
               <Link 
                 href={`/reports/${id}?page=${currentPage + 1}`}
                 className="px-4 py-2 border rounded bg-white hover:bg-gray-50"
               >
                 Siguiente
               </Link>
            </div>
          )}
        </>
      )}
    </main>
  );
}