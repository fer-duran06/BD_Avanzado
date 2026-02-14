-- ============================================
-- 03-roles.sql
-- Crea usuario de aplicación con privilegios mínimos
-- ============================================

-- ============================================
-- PRINCIPIO DE MÍNIMO PRIVILEGIO (Least Privilege)
-- ============================================
-- El usuario de la aplicación (reports_user) solo debe tener:
-- - SELECT en las VIEWS de reportes
-- - CONNECT a la base de datos
-- - NO acceso a tablas base
-- - NO permisos de escritura (INSERT/UPDATE/DELETE)
-- - NO permisos administrativos (CREATE/DROP/ALTER)
-- ============================================

-- Verificar si el usuario ya existe y eliminarlo si es necesario
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'reports_user') THEN
        RAISE NOTICE 'Usuario reports_user ya existe, eliminándolo...';
        DROP OWNED BY reports_user;
        DROP ROLE reports_user;
    END IF;
END
$$;

-- ============================================
-- Crear usuario de aplicación
-- ============================================
CREATE ROLE reports_user WITH
    LOGIN
    PASSWORD 'reports_app_password_456'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOINHERIT
    NOREPLICATION
    CONNECTION LIMIT 10;  -- Limitar conexiones simultáneas

COMMENT ON ROLE reports_user IS 'Usuario de aplicación con permisos mínimos (solo SELECT en VIEWS)';

-- ============================================
-- Permisos básicos necesarios
-- ============================================

-- Permitir conectarse a la base de datos
GRANT CONNECT ON DATABASE reports_dashboard TO reports_user;

-- Permitir usar el schema public
GRANT USAGE ON SCHEMA public TO reports_user;

-- ============================================
-- IMPORTANTE: NO dar permisos sobre tablas base
-- ============================================
-- El usuario NO debe tener acceso directo a:
-- - categories, products, customers, orders, order_items, sales
-- Solo tendrá acceso a las VIEWS que crearemos en 04-reports_vw.sql

-- Revocar cualquier permiso por defecto que pudiera tener
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM reports_user;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM reports_user;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM reports_user;

-- ============================================
-- Los permisos SELECT en VIEWS se darán en 04-reports_vw.sql
-- ============================================

-- ============================================
-- Configuración de seguridad adicional
-- ============================================

-- Establecer search_path para evitar ataques de schema injection
ALTER ROLE reports_user SET search_path = public;

-- Establecer statement_timeout para prevenir queries que corren por mucho tiempo
ALTER ROLE reports_user SET statement_timeout = '30s';

-- Establecer idle_in_transaction_session_timeout
ALTER ROLE reports_user SET idle_in_transaction_session_timeout = '60s';

-- ============================================
-- Verificación
-- ============================================

-- Mostrar información del usuario creado
SELECT 
    rolname as username,
    rolsuper as is_superuser,
    rolinherit as inherit_privileges,
    rolcreaterole as can_create_roles,
    rolcreatedb as can_create_databases,
    rolcanlogin as can_login,
    rolconnlimit as connection_limit,
    rolvaliduntil as valid_until
FROM pg_roles 
WHERE rolname = 'reports_user';

-- Mensaje de confirmación
SELECT 'Usuario reports_user creado exitosamente con privilegios mínimos' as message;
SELECT 'IMPORTANTE: Este usuario solo tendrá SELECT en las VIEWS (se configurará en 04-reports_vw.sql)' as note;