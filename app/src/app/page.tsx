// app/page.tsx
'use client';

import Link from 'next/link';
import { useState } from 'react';

const REPORTS_METADATA = [
  {
    id: 1,
    title: 'Ventas por Categoría',
    description: 'Análisis de ventas totales, ranking y porcentaje por categoría de producto',
    icon: '📊',
  },
  {
    id: 2,
    title: 'Valor de Vida del Cliente',
    description: 'Valor total, frecuencia y segmentación de clientes (CLV)',
    icon: '👥',
  },
  {
    id: 3,
    title: 'Desempeño de Productos',
    description: 'Análisis de ventas, inventario y rentabilidad por producto',
    icon: '📦',
  },
  {
    id: 4,
    title: 'Tendencias Mensuales',
    description: 'Análisis de ventas mes a mes con crecimiento y comparaciones',
    icon: '📈',
  },
  {
    id: 5,
    title: 'Análisis de Inventario',
    description: 'Productos que necesitan reorden basado en stock y demanda',
    icon: '📋',
  },
];

function ReportCard({ report }: { report: typeof REPORTS_METADATA[0] }) {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <Link href={`/reports/${report.id}`} style={{ textDecoration: 'none' }}>
      <div
        style={{
          backgroundColor: 'white',
          padding: '1.5rem',
          borderRadius: '0.5rem',
          border: '1px solid #e5e7eb',
          cursor: 'pointer',
          transition: 'all 0.2s',
          boxShadow: isHovered ? '0 10px 15px rgba(0,0,0,0.1)' : 'none',
          transform: isHovered ? 'translateY(-2px)' : 'translateY(0)',
        }}
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>
          {report.icon}
        </div>
        <h2 style={{
          fontSize: '1.25rem',
          fontWeight: '600',
          color: '#111827',
          marginBottom: '0.5rem'
        }}>
          {report.title}
        </h2>
        <p style={{ fontSize: '0.875rem', color: '#6b7280', lineHeight: '1.5' }}>
          {report.description}
        </p>
        <div style={{
          marginTop: '1rem',
          fontSize: '0.875rem',
          color: '#3b82f6',
          fontWeight: '500'
        }}>
          Ver reporte →
        </div>
      </div>
    </Link>
  );
}

export default function HomePage() {
  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f9fafb' }}>
      <header style={{
        backgroundColor: 'white',
        borderBottom: '1px solid #e5e7eb',
        padding: '1.5rem 2rem'
      }}>
        <h1 style={{ fontSize: '1.875rem', fontWeight: 'bold', color: '#111827' }}>
          📊 Dashboard de Reportes
        </h1>
        <p style={{ color: '#6b7280', marginTop: '0.5rem' }}>
          Sistema de análisis de ventas, inventario y clientes
        </p>
      </header>

      <main style={{ maxWidth: '1280px', margin: '0 auto', padding: '2rem' }}>
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
          gap: '1.5rem'
        }}>
          {REPORTS_METADATA.map((report) => (
            <ReportCard key={report.id} report={report} />
          ))}
        </div>

        <div style={{
          marginTop: '3rem',
          padding: '1.5rem',
          backgroundColor: 'white',
          borderRadius: '0.5rem',
          border: '1px solid #e5e7eb'
        }}>
          <h3 style={{ fontSize: '1.125rem', fontWeight: '600', marginBottom: '1rem' }}>
            ℹ️ Información del Sistema
          </h3>
          <ul style={{ listStyle: 'none', padding: 0, color: '#6b7280' }}>
            <li>✅ Base de datos: PostgreSQL 16</li>
            <li>✅ 5 VIEWS con análisis avanzado</li>
            <li>✅ Índices optimizados para performance</li>
            <li>✅ Seguridad: Usuario con privilegios mínimos</li>
          </ul>
        </div>
      </main>
    </div>
  );
}