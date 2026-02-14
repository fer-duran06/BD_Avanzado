// app/layout.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Dashboard de Reportes',
  description: 'Sistema de análisis de ventas, inventario y clientes',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es">
      <body style={{ margin: 0, fontFamily: 'system-ui, -apple-system, sans-serif' }}>
        {children}
      </body>
    </html>
  );
}