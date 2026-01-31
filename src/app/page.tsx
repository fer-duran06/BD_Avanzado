import Link from 'next/link';

export default function Home() {
  const reports = [
    { id: 1, name: "Top Productos", desc: "Ranking de ventas y clasificación", color: "bg-blue-500" },
    { id: 2, name: "Ventas Mensuales", desc: "Tendencias y KPIs por mes", color: "bg-green-500" },
    { id: 3, name: "Valor de Clientes", desc: "Segmentación VIP y frecuencias", color: "bg-purple-500" },
    { id: 4, name: "Performance Categorías", desc: "Comparativa vs Promedio (CTE)", color: "bg-orange-500" },
    { id: 5, name: "Ranking Avanzado", desc: "Window Functions Analytics", color: "bg-red-500" },
  ];

  return (
    <main className="min-h-screen p-10 max-w-5xl mx-auto">
      <div className="mb-10 text-center">
        <h1 className="text-4xl font-extrabold text-gray-900 mb-2">Dashboard Equipo E</h1>
        <p className="text-gray-600">Sistema de Reportes SQL Avanzados</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {reports.map((r) => (
          <Link key={r.id} href={`/reports/${r.id}`} className="block group">
            <div className="bg-white rounded-xl shadow-sm border p-6 hover:shadow-md transition-all hover:-translate-y-1 h-full">
              <div className={`w-12 h-12 ${r.color} rounded-lg mb-4 flex items-center justify-center text-white font-bold text-xl`}>
                {r.id}
              </div>
              <h2 className="text-xl font-bold text-gray-800 group-hover:text-blue-600 transition-colors">
                {r.name}
              </h2>
              <p className="text-gray-500 mt-2 text-sm">
                {r.desc}
              </p>
            </div>
          </Link>
        ))}
      </div>
    </main>
  );
}