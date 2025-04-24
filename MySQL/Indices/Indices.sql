USE FabiaNatura;
GO

-- Crear índices para mejorar el rendimiento de las búsquedas más comunes.

-- 1. Buscar Categorías por Nombre
-- El nombre de la categoría se usará con frecuencia para filtrar o buscar categorías.
-- Creamos un índice no clusterizado en la columna nombre de la tabla Categorias.
CREATE NONCLUSTERED INDEX idx_categorias_nombre 
ON Inventario.Categorias (nombre);
-- Este índice mejora el rendimiento de las búsquedas cuando se filtra por el nombre de la categoría.

-- 2. Buscar Productos por Nombre
-- El nombre del producto es una columna clave para realizar búsquedas de productos.
-- Creamos un índice no clusterizado en la columna nombre de la tabla Productos.
CREATE NONCLUSTERED INDEX idx_productos_nombre 
ON Inventario.Productos (nombre);
-- Este índice mejora las consultas de productos basadas en su nombre.

-- 3. Buscar Proveedores por Nombre
-- El nombre del proveedor es una columna importante para realizar búsquedas en la tabla Proveedores.
-- Creamos un índice no clusterizado en la columna nombre de la tabla Proveedores.
CREATE NONCLUSTERED INDEX idx_proveedores_nombre 
ON Inventario.Proveedores (nombre);
-- Este índice facilita la búsqueda eficiente de proveedores por su nombre.

-- 4. Buscar Persona por Nombre, Apellido Paterno o Apellido Materno
-- Las personas se pueden buscar por su nombre o apellido, por lo que estas columnas son clave en las búsquedas.
-- Creamos un índice compuesto no clusterizado en nombre, apellido_paterno y apellido_materno para optimizar las búsquedas.
CREATE NONCLUSTERED INDEX idx_personas_nombre_apellido 
ON RecursosHumanos.Personas (nombre, apellido_paterno, apellido_materno);
-- Este índice es útil para realizar búsquedas rápidas por nombre y apellido, cubriendo varios casos de búsqueda.

-- 5. Buscar Factura por Fecha de Registro o Rango de Fechas
-- La búsqueda de facturas por fecha es común, especialmente cuando se generan informes de facturación.
-- Creamos un índice no clusterizado en la columna fecha_registro para optimizar estas consultas.
CREATE NONCLUSTERED INDEX idx_facturas_fecha_registro 
ON Ventas.Facturas (fecha_registro);
-- Este índice acelera las consultas que buscan facturas dentro de un rango de fechas específico.


-- Ver los indices
--EXEC sp_helpindex 'nombre del esquema.nombre de la tabla';