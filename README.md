#  Tarea 6: Next.js Reports Dashboard

Dashboard de reportes SQL construido con Next.js, PostgreSQL Views y Docker Compose.

##  Objetivo

Demostrar competencia en:
- Diseño de VIEWS con funciones agregadas, GROUP BY, HAVING, CTEs y Window Functions
- Conexión segura de Next.js a PostgreSQL
- Empaquetado reproducible con Docker Compose
- Seguridad: SQL injection prevention, least privilege, credential management

---

##  Inicio Rápido

### Prerrequisitos
- Docker y Docker Compose instalados
- Git

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <tu-repo-url>
   cd tarea6-reports-dashboard
   ```

2. **Configurar variables de entorno**
   ```bash
   cp .env.example .env
   # Editar .env con tus credenciales (NO usar las del ejemplo en producción)
   ```

3. **Levantar el proyecto completo**
   ```bash
   docker compose up --build
   ```

4. **Acceder a la aplicación**
   - Frontend: http://localhost:3000
   - PostgreSQL: localhost:5432

### Verificación Rápida
```bash
# Verificar que la base de datos y las views están funcionando
./scripts/verify.sh
```

##  Esquema de Base de Datos

### Tablas Base
- `products` - Catálogo de productos
- `categories` - Categorías de productos
- `sales` - Transacciones de venta
- `customers` - Información de clientes
- `orders` - Órdenes de compra

### VIEWS (Reportes)
1. **view_sales_by_category** - Ventas por categoría con ranking (CTE + Window Function)
2. **view_customer_lifetime_value** - Valor de vida del cliente (CASE, COALESCE, HAVING)
3. **view_product_performance** - Desempeño de productos (funciones agregadas)
4. **view_monthly_trends** - Tendencias mensuales (Window Functions)
5. **view_inventory_status** - Estado de inventario (campos calculados, HAVING)

---

##  Seguridad (Threat Model)

### 1. **SQL Injection Prevention**
-  Solo queries parametrizadas (`$1`, `$2`, ...) - nunca concatenación de strings
-  Validación de inputs con Zod antes de ejecutar queries
-  Whitelist de columnas permitidas para ORDER BY y filtros
-  Solo operaciones SELECT permitidas en la app

### 2. **Credential Exposure**
-  Credenciales solo en variables de entorno (`.env`)
-  `.env` en `.gitignore` - nunca commiteado al repositorio
-  `.env.example` con valores placeholder, no reales
-  No hay credenciales hardcodeadas en código

### 3. **Least Privilege (Principio de Mínimo Privilegio)**
-  Usuario `reports_user` solo tiene permisos SELECT en VIEWS
-  Usuario de app NO tiene acceso directo a tablas base
-  Usuario de app NO puede ejecutar DROP/ALTER/INSERT/UPDATE/DELETE
-  Separación entre usuario admin (init) y usuario app (runtime)

### 4. **Data Exposure**
-  Paginación server-side para evitar cargar datasets completos
-  LIMIT en todas las queries para prevenir DoS
-  No se exponen credenciales en mensajes de error del cliente
-  Rate limiting implícito por paginación

### 5. **Docker Security**
-  Secrets manejados vía variables de entorno
-  Network isolation entre servicios (red privada)
-  Healthcheck para asegurar DB lista antes de conectar app
-  Usuario no privilegiado en contenedores

### 6. **Input Validation**
-  Todos los filtros validados con Zod schemas
-  Sanitización de inputs numéricos (limit, offset, page)
-  Rechazo de inputs fuera de rangos permitidos
-  Validación de tipos en runtime con TypeScript

---

##  Performance y Optimización

### Índices Creados

1. **idx_sales_date** - Índice en `sales.sale_date`
   - **Justificación**: Acelera filtros por rango de fechas en reportes temporales
   - **Evidencia EXPLAIN**: [Ver captura en `/docs/explain_sales_date.txt`]

2. **idx_sales_product** - Índice en `sales.product_id`
   - **Justificación**: Optimiza JOINs entre sales y products
   - **Evidencia EXPLAIN**: [Ver captura en `/docs/explain_sales_product.txt`]

3. **idx_products_category** - Índice en `products.category_id`
   - **Justificación**: Mejora GROUP BY por categoría
   - **Evidencia EXPLAIN**: [Ver captura en `/docs/explain_products_category.txt`]

### Trade-offs (SQL vs Next.js)

**Calculado en SQL (en VIEWS):**
-  Agregaciones (SUM, AVG, COUNT) - más eficiente en DB
-  Rankings y window functions - requieren acceso completo al dataset
-  Campos calculados (ratios, porcentajes) - mejor performance en DB
-  Filtros con HAVING - operan sobre datos agregados

**Calculado en Next.js:**
-  Formateo de números y fechas - mejor UX con locale del cliente
-  Paginación UI - control de estado en el cliente
-  Interactividad (sorting UI, filtros dinámicos) - mejor UX
-  Gráficos y visualizaciones - librerías JS especializadas

**Razón**: Maximizar performance moviendo cómputo pesado a PostgreSQL, mientras mantenemos la flexibilidad de UI en el frontend.

---

##  VIEWS - Documentación Detallada

### View 1: view_sales_by_category
**Propósito**: Analizar ventas por categoría con ranking de desempeño  
**Grain**: Una fila por categoría de producto  
**Métricas**:
- `total_sales`: Suma total de ventas (SUM)
- `avg_sale`: Promedio de venta (AVG)
- `num_transactions`: Conteo de transacciones (COUNT)
- `sales_percentage`: % del total de ventas (campo calculado)
- `category_rank`: Ranking por ventas (Window Function: RANK)

**Técnicas SQL**:
- CTE (`category_totals`, `grand_total`)
- Window Function (RANK)
- CASE para clasificación
- HAVING para filtrar categorías con < 10 transacciones

**VERIFY Queries**:
```sql
-- Total debe coincidir con suma de tabla base
SELECT SUM(total_sales) FROM view_sales_by_category;
-- % total debe ser 100
SELECT SUM(sales_percentage) FROM view_sales_by_category;
```

[... Documentación similar para views 2-5 ...]

---

##  Testing y Validación

### Script de Verificación
```bash
./scripts/verify.sh
```

Ejecuta:
1. Verificación de conexión a DB
2. Lista todas las VIEWS creadas (`\dv`)
3. Ejecuta 1 query VERIFY por cada VIEW
4. Verifica que el usuario `reports_user` solo tiene SELECT

### Tests de Seguridad
- Intentar INSERT con `reports_user` → DEBE FALLAR
- Intentar SELECT en tabla base con `reports_user` → DEBE FALLAR
- Validar SQL injection con inputs maliciosos → DEBE RECHAZAR

---

##  Bitácora de IA

### Prompts Clave Utilizados

1. **"Ayúdame a diseñar 5 VIEWS con CTE y window functions para un dashboard de reportes"**
   - **Validé**: La sintaxis SQL y que cumpliera con los requisitos (GROUP BY, HAVING, etc.)
   - **Corregí**: Ajusté los VERIFY queries para que fueran más específicos

2. **"Cómo implementar paginación server-side en Next.js con PostgreSQL"**
   - **Validé**: Que usara parámetros ($1, $2) y no concatenación de strings
   - **Corregí**: Añadí validación Zod para limit y offset

3. **"Configuración de roles y permisos en PostgreSQL para least privilege"**
   - **Validé**: Probé manualmente que el usuario solo tuviera SELECT en VIEWS
   - **Corregí**: Añadí REVOKE ALL para asegurar permisos mínimos

### Áreas donde la IA necesitó corrección
- Inicialmente sugirió exponer DATABASE_URL en el cliente
- No incluyó healthcheck en docker-compose
- Faltaba validación de inputs con Zod

---

##  Ponderación de la Tarea

- **SQL (40%)**: 5+ views con todas las reglas, CTE, window functions, VERIFY
- **Next.js (15%)**: 5 pantallas, fetching seguro, filtros + paginación
- **Docker Compose (10%)**: One command run, init automático, healthcheck
- **Defensa + evidencia (35%)**: Explicación sin leer, evidencia de performance y seguridad

---

##  Comandos Útiles

### Docker
```bash
# Levantar servicios
docker compose up --build

# Ver logs
docker compose logs -f web
docker compose logs -f db

# Detener servicios
docker compose down

# Reiniciar solo un servicio
docker compose restart web

# Limpiar todo (incluyendo volúmenes)
docker compose down -v
```

### Base de Datos
```bash
# Conectarse a PostgreSQL
docker compose exec db psql -U postgres -d reports_dashboard

# Listar VIEWS
docker compose exec db psql -U postgres -d reports_dashboard -c "\dv"

# Ejecutar query
docker compose exec db psql -U postgres -d reports_dashboard -c "SELECT * FROM view_sales_by_category LIMIT 5;"
```

### Next.js
```bash
# Instalar dependencias (si no usas Docker)
cd app && npm install

# Desarrollo local
npm run dev

# Build de producción
npm run build
npm start
```

---

## 👥 Autor

- **Nombre**: [Tu nombre]
- **Materia**: Base de Datos Avanzados
- **Institución**: Universidad Politécnica de Chiapas
- **Fecha**: Febrero 2026

---

##  Licencia

Este proyecto es parte de una tarea académica y no está bajo ninguna licencia de código abierto.

---


