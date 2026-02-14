-- ============================================
-- 02-seed.sql
-- Inserta datos de prueba para los reportes
-- ============================================

-- ============================================
-- Categories
-- ============================================
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Physical and digital books'),
('Home & Garden', 'Home improvement and garden supplies'),
('Sports & Outdoors', 'Sports equipment and outdoor gear'),
('Toys & Games', 'Toys for children and board games'),
('Food & Beverages', 'Groceries and drinks'),
('Beauty & Personal Care', 'Cosmetics and personal hygiene products');

-- ============================================
-- Products
-- ============================================
INSERT INTO products (product_name, category_id, price, stock_quantity, reorder_level) VALUES
-- Electronics
('Laptop Pro 15"', 1, 24999.99, 45, 10),
('Wireless Mouse', 1, 599.99, 120, 20),
('USB-C Hub', 1, 899.99, 80, 15),
('Bluetooth Headphones', 1, 1999.99, 65, 15),
('4K Monitor 27"', 1, 8999.99, 30, 8),
('Mechanical Keyboard', 1, 1499.99, 55, 12),
('Webcam HD', 1, 799.99, 40, 10),
('External SSD 1TB', 1, 2499.99, 50, 10),

-- Clothing
('Cotton T-Shirt', 2, 299.99, 200, 50),
('Jeans Classic Fit', 2, 699.99, 150, 40),
('Hoodie Premium', 2, 899.99, 100, 25),
('Running Shoes', 2, 1299.99, 80, 20),
('Winter Jacket', 2, 1999.99, 60, 15),

-- Books
('Programming in Python', 3, 599.99, 75, 20),
('Data Science Handbook', 3, 799.99, 50, 15),
('Fiction Bestseller', 3, 399.99, 100, 25),
('Cookbook Mexican', 3, 449.99, 60, 15),

-- Home & Garden
('LED Desk Lamp', 4, 499.99, 90, 20),
('Garden Tools Set', 4, 1299.99, 40, 10),
('Storage Containers', 4, 299.99, 150, 30),
('Wall Clock', 4, 399.99, 70, 15),

-- Sports & Outdoors
('Yoga Mat', 5, 499.99, 100, 25),
('Dumbbell Set 20kg', 5, 1999.99, 35, 10),
('Camping Tent 4P', 5, 3999.99, 20, 5),
('Mountain Bike', 5, 12999.99, 15, 5),

-- Toys & Games
('Board Game Classic', 6, 599.99, 80, 20),
('Action Figure Set', 6, 899.99, 60, 15),
('Building Blocks 500pcs', 6, 799.99, 70, 20),
('Puzzle 1000pcs', 6, 499.99, 50, 15),

-- Food & Beverages
('Organic Coffee 1kg', 7, 399.99, 200, 50),
('Green Tea Box', 7, 199.99, 150, 40),
('Protein Bar Pack', 7, 249.99, 180, 45),
('Dark Chocolate', 7, 149.99, 120, 30),

-- Beauty & Personal Care
('Shampoo Natural', 8, 199.99, 140, 35),
('Face Cream SPF50', 8, 399.99, 90, 25),
('Body Lotion', 8, 299.99, 110, 30),
('Perfume Eau de Toilette', 8, 1299.99, 50, 12);

-- ============================================
-- Customers
-- ============================================
INSERT INTO customers (customer_name, email, phone, city, country, registration_date) VALUES
('Juan Pérez', 'juan.perez@email.com', '9611234567', 'Tuxtla Gutiérrez', 'Mexico', '2023-01-15'),
('María García', 'maria.garcia@email.com', '9617654321', 'San Cristóbal', 'Mexico', '2023-02-20'),
('Carlos López', 'carlos.lopez@email.com', '9619876543', 'Comitán', 'Mexico', '2023-03-10'),
('Ana Martínez', 'ana.martinez@email.com', '9615678901', 'Tapachula', 'Mexico', '2023-04-05'),
('Luis Rodríguez', 'luis.rodriguez@email.com', '9612345678', 'Tuxtla Gutiérrez', 'Mexico', '2023-05-12'),
('Carmen Sánchez', 'carmen.sanchez@email.com', '9618765432', 'Chiapa de Corzo', 'Mexico', '2023-06-18'),
('Roberto Díaz', 'roberto.diaz@email.com', '9613456789', 'Tuxtla Gutiérrez', 'Mexico', '2023-07-22'),
('Laura Torres', 'laura.torres@email.com', '9616543210', 'San Cristóbal', 'Mexico', '2023-08-30'),
('Miguel Ramírez', 'miguel.ramirez@email.com', '9619012345', 'Tonalá', 'Mexico', '2023-09-14'),
('Patricia Flores', 'patricia.flores@email.com', '9614567890', 'Tuxtla Gutiérrez', 'Mexico', '2023-10-25'),
('Fernando Jiménez', 'fernando.jimenez@email.com', '9617890123', 'Palenque', 'Mexico', '2023-11-08'),
('Gabriela Morales', 'gabriela.morales@email.com', '9612109876', 'Tuxtla Gutiérrez', 'Mexico', '2023-12-15'),
('Diego Hernández', 'diego.hernandez@email.com', '9615432109', 'Cintalapa', 'Mexico', '2024-01-20'),
('Sofía Ruiz', 'sofia.ruiz@email.com', '9618901234', 'Tuxtla Gutiérrez', 'Mexico', '2024-02-10'),
('Alejandro Castro', 'alejandro.castro@email.com', '9613210987', 'Arriaga', 'Mexico', '2024-03-05');

-- ============================================
-- Sales (datos realistas distribuidos a lo largo de 2024-2025)
-- ============================================
-- Ventas Q1 2024
INSERT INTO sales (product_id, customer_id, sale_date, sale_amount, quantity, cost) VALUES
(1, 1, '2024-01-05', 24999.99, 1, 18000.00),
(2, 1, '2024-01-05', 599.99, 1, 300.00),
(9, 2, '2024-01-12', 899.97, 3, 450.00),
(14, 3, '2024-01-18', 599.99, 1, 300.00),
(18, 4, '2024-01-25', 499.99, 1, 250.00),
(30, 5, '2024-02-03', 1199.97, 3, 600.00),
(4, 6, '2024-02-10', 1999.99, 1, 1200.00),
(12, 7, '2024-02-15', 1299.99, 1, 800.00),
(23, 8, '2024-02-22', 499.99, 1, 250.00),
(26, 9, '2024-03-01', 899.99, 1, 500.00),
(15, 10, '2024-03-08', 799.99, 1, 400.00),
(31, 11, '2024-03-15', 797.97, 2, 400.00),
(5, 12, '2024-03-22', 8999.99, 1, 6500.00),

-- Ventas Q2 2024
(10, 1, '2024-04-02', 2099.97, 3, 1050.00),
(11, 2, '2024-04-09', 899.99, 1, 500.00),
(13, 3, '2024-04-16', 1999.99, 1, 1200.00),
(22, 4, '2024-04-23', 299.99, 1, 150.00),
(24, 5, '2024-05-01', 1999.99, 1, 1200.00),
(7, 6, '2024-05-08', 799.99, 1, 400.00),
(8, 7, '2024-05-15', 2499.99, 1, 1500.00),
(16, 8, '2024-05-22', 399.99, 1, 200.00),
(19, 9, '2024-06-01', 1299.99, 1, 700.00),
(27, 10, '2024-06-08', 899.99, 1, 500.00),
(33, 11, '2024-06-15', 399.99, 1, 200.00),
(35, 12, '2024-06-22', 597.97, 2, 300.00),

-- Ventas Q3 2024
(1, 13, '2024-07-03', 24999.99, 1, 18000.00),
(3, 14, '2024-07-10', 899.99, 1, 500.00),
(6, 15, '2024-07-17', 1499.99, 1, 900.00),
(14, 1, '2024-07-24', 1199.98, 2, 600.00),
(20, 2, '2024-08-02', 1299.99, 1, 700.00),
(21, 3, '2024-08-09', 299.99, 1, 150.00),
(25, 4, '2024-08-16', 3999.99, 1, 2500.00),
(28, 5, '2024-08-23', 599.99, 1, 350.00),
(32, 6, '2024-09-01', 249.99, 1, 125.00),
(34, 7, '2024-09-08', 149.99, 1, 75.00),
(36, 8, '2024-09-15', 399.99, 1, 200.00),
(9, 9, '2024-09-22', 1199.97, 4, 600.00),

-- Ventas Q4 2024
(4, 10, '2024-10-01', 1999.99, 1, 1200.00),
(12, 11, '2024-10-08', 2599.98, 2, 1600.00),
(17, 12, '2024-10-15', 449.99, 1, 225.00),
(23, 13, '2024-10-22', 999.98, 2, 500.00),
(29, 14, '2024-11-01', 499.99, 1, 250.00),
(30, 15, '2024-11-08', 3599.91, 9, 1800.00),
(2, 1, '2024-11-15', 1199.98, 2, 600.00),
(5, 2, '2024-11-22', 8999.99, 1, 6500.00),
(15, 3, '2024-12-01', 1599.98, 2, 800.00),
(26, 4, '2024-12-08', 1799.98, 2, 1000.00),
(31, 5, '2024-12-15', 1197.96, 3, 600.00),
(37, 6, '2024-12-22', 299.99, 1, 150.00),

-- Ventas Q1 2025
(1, 7, '2025-01-05', 49999.98, 2, 36000.00),
(8, 8, '2025-01-12', 2499.99, 1, 1500.00),
(11, 9, '2025-01-19', 1799.98, 2, 1000.00),
(18, 10, '2025-01-26', 499.99, 1, 250.00),
(22, 11, '2025-02-02', 899.97, 3, 450.00),
(27, 12, '2025-02-09', 899.99, 1, 500.00),
(33, 13, '2025-02-16', 799.98, 2, 400.00);

-- ============================================
-- Orders y Order Items
-- ============================================
-- Orden 1
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_cost) VALUES
(1, '2024-01-05 10:30:00', 'delivered', 25749.98, 150.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent) VALUES
(1, 1, 1, 24999.99, 0),
(1, 2, 1, 599.99, 0);

-- Orden 2
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_cost) VALUES
(2, '2024-01-12 14:20:00', 'delivered', 899.97, 50.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent) VALUES
(2, 9, 3, 299.99, 0);

-- Orden 3
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_cost) VALUES
(5, '2025-01-05 09:15:00', 'processing', 52649.97, 200.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent) VALUES
(3, 1, 2, 24999.99, 5),
(3, 8, 1, 2499.99, 0);

-- ============================================
-- Verificación
-- ============================================
SELECT 'Data seeded successfully!' as message;
SELECT 'Categories: ' || COUNT(*) FROM categories;
SELECT 'Products: ' || COUNT(*) FROM products;
SELECT 'Customers: ' || COUNT(*) FROM customers;
SELECT 'Sales: ' || COUNT(*) FROM sales;
SELECT 'Orders: ' || COUNT(*) FROM orders;
SELECT 'Order Items: ' || COUNT(*) FROM order_items;
