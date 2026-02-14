// components/Pagination.tsx
'use client';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

export default function Pagination({ currentPage, totalPages, onPageChange }: PaginationProps) {
  return (
    <div style={{
      display: 'flex',
      gap: '0.5rem',
      justifyContent: 'center',
      marginTop: '2rem'
    }}>
      <button
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage <= 1}
        style={{
          padding: '0.5rem 1rem',
          backgroundColor: currentPage <= 1 ? '#e5e7eb' : '#3b82f6',
          color: currentPage <= 1 ? '#9ca3af' : 'white',
          border: 'none',
          borderRadius: '0.375rem',
          cursor: currentPage <= 1 ? 'not-allowed' : 'pointer'
        }}
      >
        Anterior
      </button>
      
      <span style={{
        padding: '0.5rem 1rem',
        display: 'flex',
        alignItems: 'center',
        color: '#374151'
      }}>
        Página {currentPage} de {totalPages}
      </span>
      
      <button
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage >= totalPages}
        style={{
          padding: '0.5rem 1rem',
          backgroundColor: currentPage >= totalPages ? '#e5e7eb' : '#3b82f6',
          color: currentPage >= totalPages ? '#9ca3af' : 'white',
          border: 'none',
          borderRadius: '0.375rem',
          cursor: currentPage >= totalPages ? 'not-allowed' : 'pointer'
        }}
      >
        Siguiente
      </button>
    </div>
  );
}