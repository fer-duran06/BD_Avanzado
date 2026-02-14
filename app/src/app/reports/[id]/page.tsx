// app/reports/[id]/page.tsx
import Link from 'next/link';
import { getReportData, getReportKPIs, REPORTS_METADATA } from '@/lib/reports';
import ReportTable from '@/components/ReportTable';
import KPICard from '@/components/KPICard';

interface PageProps {
  params: { id: string };
  searchParams: { page?: string };
}

export const dynamic = 'force-dynamic';
export const revalidate = 0;

export default async function ReportPage({ params, searchParams }: PageProps) {
  const reportId = parseInt(params.id);
  const page = parseInt(searchParams.page || '1');
  const limit = 10;

  const reportMeta = REPORTS_METADATA.find(r => r.id === reportId);
  
  if (!reportMeta) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center' }}>
        <h1>Reporte no encontrado</h1>
        <Link href="/" style={{ color: '#3b82f6' }}>
          ← Volver al dashboard
        </Link>
      </div>
    );
  }

  let data: any[] = [];
  let pagination = { page: 1, limit: 10, total: 0, totalPages: 0 };
  let metadata = reportMeta;
  let kpis: any[] = [];
  let error = null;

  try {
    const result = await getReportData(reportId, page, limit);
    data = result.data;
    pagination = result.pagination;
    metadata = result.metadata;
    kpis = await getReportKPIs(reportId);
  } catch (e) {
    error = e instanceof Error ? e.message : 'Error desconocido';
  }

  if (error) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center' }}>
        <h1>Error al cargar el reporte</h1>
        <p style={{ color: '#ef4444' }}>{error}</p>
        <Link href="/" style={{ color: '#3b82f6' }}>
          ← Volver al dashboard
        </Link>
      </div>
    );
  }

  const columns = data.length > 0 ? Object.keys(data[0]) : [];

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f9fafb' }}>
      <header style={{
        backgroundColor: 'white',
        borderBottom: '1px solid #e5e7eb',
        padding: '1.5rem 2rem'
      }}>
        <Link href="/" style={{
          color: '#3b82f6',
          textDecoration: 'none',
          fontSize: '0.875rem',
          marginBottom: '0.5rem',
          display: 'inline-block'
        }}>
          ← Volver al Dashboard
        </Link>
        <h1 style={{ fontSize: '1.875rem', fontWeight: 'bold', color: '#111827' }}>
          {metadata.icon} {metadata.title}
        </h1>
        <p style={{ color: '#6b7280', marginTop: '0.5rem' }}>
          {metadata.description}
        </p>
      </header>

      <main style={{ maxWidth: '1280px', margin: '0 auto', padding: '2rem' }}>
        {kpis.length > 0 && (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
            gap: '1rem',
            marginBottom: '2rem'
          }}>
            {kpis.map((kpi, idx) => (
              <KPICard key={idx} label={kpi.label} value={kpi.value} />
            ))}
          </div>
        )}

        <div style={{
          backgroundColor: 'white',
          padding: '1.5rem',
          borderRadius: '0.5rem',
          border: '1px solid #e5e7eb'
        }}>
          <div style={{ marginBottom: '1rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h2 style={{ fontSize: '1.25rem', fontWeight: '600', color: '#111827' }}>
              Datos del Reporte
            </h2>
            <span style={{ fontSize: '0.875rem', color: '#6b7280' }}>
              Total: {pagination.total} registros
            </span>
          </div>

          <ReportTable data={data} columns={columns} />

          {pagination.totalPages > 1 && (
            <div style={{
              display: 'flex',
              gap: '0.5rem',
              justifyContent: 'center',
              marginTop: '1.5rem'
            }}>
              {page > 1 && (
                <Link
                  href={`/reports/${reportId}?page=${page - 1}`}
                  style={{
                    padding: '0.5rem 1rem',
                    backgroundColor: '#3b82f6',
                    color: 'white',
                    textDecoration: 'none',
                    borderRadius: '0.375rem'
                  }}
                >
                  ← Anterior
                </Link>
              )}
              
              <span style={{
                padding: '0.5rem 1rem',
                color: '#374151',
                display: 'flex',
                alignItems: 'center'
              }}>
                Página {page} de {pagination.totalPages}
              </span>
              
              {page < pagination.totalPages && (
                <Link
                  href={`/reports/${reportId}?page=${page + 1}`}
                  style={{
                    padding: '0.5rem 1rem',
                    backgroundColor: '#3b82f6',
                    color: 'white',
                    textDecoration: 'none',
                    borderRadius: '0.375rem'
                  }}
                >
                  Siguiente →
                </Link>
              )}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}