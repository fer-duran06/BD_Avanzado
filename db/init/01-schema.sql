-- ============================================
-- 01-schema.sql
-- Crea la estructura de tablas base
-- ============================================

-- Limpiar tablas existentes si las hay
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ============================================
-- Tabla: categories
-- Categorías de productos
-- ============================================
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Tabla: products
-- Catálogo de productos
-- ============================================
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id INTEGER NOT NULL REFERENCES categories(category_id),
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_level INTEGER NOT NULL DEFAULT 10,
    discontinued BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Tabla: customers
-- Información de clientes
-- ============================================
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Mexico',
    registration_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Tabla: orders
-- Órdenes de compra
-- ============================================
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    total_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Tabla: order_items
-- Detalles de items en cada orden
-- ============================================
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    discount_percent DECIMAL(5, 2) DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    subtotal DECIMAL(10, 2) GENERATED ALWAYS AS (
        quantity * unit_price * (1 - discount_percent / 100)
    ) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Tabla: sales
-- Vista simplificada de ventas (denormalizada para reportes rápidos)
-- ============================================
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    sale_date DATE NOT NULL,
    sale_amount DECIMAL(10, 2) NOT NULL CHECK (sale_amount >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    cost DECIMAL(10, 2) CHECK (cost >= 0),
    profit DECIMAL(10, 2) GENERATED ALWAYS AS (sale_amount - cost) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Comentarios de documentación
-- ============================================
COMMENT ON TABLE categories IS 'Catálogo de categorías de productos';
COMMENT ON TABLE products IS 'Catálogo de productos con inventario';
COMMENT ON TABLE customers IS 'Información de clientes registrados';
COMMENT ON TABLE orders IS 'Órdenes de compra realizadas';
COMMENT ON TABLE order_items IS 'Detalle de productos en cada orden';
COMMENT ON TABLE sales IS 'Registro de ventas (denormalizado para análisis)';

-- ============================================
-- Verificación
-- ============================================
SELECT 'Schema created successfully. Tables: ' || COUNT(*)::TEXT
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
