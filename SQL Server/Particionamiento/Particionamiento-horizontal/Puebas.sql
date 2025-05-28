-- =====================================================
-- SCRIPT DE PRUEBA DE PARTICIONAMIENTO
-- Base de datos: FabiaNatura
-- =====================================================

USE FabiaNatura;
GO

-- PASO 1: Insertar datos de prueba en las tablas originales
-- (Ejecuta primero tu script de inserts aquí)

-- PASO 2: Verificar datos en tablas originales
PRINT '=== VERIFICACIÓN DE DATOS ORIGINALES ===';
SELECT 'Facturas' as Tabla, COUNT(*) as TotalRegistros FROM Ventas.Facturas;
SELECT 'Detalle_Facturas' as Tabla, COUNT(*) as TotalRegistros FROM Ventas.Detalle_Facturas;

-- Ver distribución de facturas por mes
SELECT 
    YEAR(fecha_registro) as Año,
    MONTH(fecha_registro) as Mes,
    COUNT(*) as CantidadFacturas
FROM Ventas.Facturas
GROUP BY YEAR(fecha_registro), MONTH(fecha_registro)
ORDER BY Año, Mes;

-- Primero, eliminar los registros de la tabla de detalles
--DELETE FROM Ventas.Detalle_Facturas_Particionada;

-- Luego, eliminar los registros de la tabla principal
--DELETE FROM Ventas.Facturas_Particionada;

-- Para reiniciar los contadores de identidad
--DBCC CHECKIDENT ('Ventas.Facturas_Particionada', RESEED, 0);

-- PASO 3: Ejecutar migración a tablas particionadas
PRINT '=== INICIANDO MIGRACIÓN A TABLAS PARTICIONADAS ===';
EXEC Ventas.MigrarDatosAParticion;

-- PASO 4: Verificar migración exitosa
PRINT '=== VERIFICACIÓN POST-MIGRACIÓN ===';
SELECT 'Facturas_Particionada' as Tabla, COUNT(*) as TotalRegistros FROM Ventas.Facturas_Particionada;
SELECT 'Detalle_Facturas_Particionada' as Tabla, COUNT(*) as TotalRegistros FROM Ventas.Detalle_Facturas_Particionada;

-- PASO 5: Verificar información de particiones
PRINT '=== INFORMACIÓN DE PARTICIONES ===';
EXEC Ventas.ConsultarInformacionParticiones;

-- PASO 6: Consultar qué partición está siendo utilizada para consultas específicas
PRINT '=== PRUEBA DE ELIMINACIÓN DE PARTICIONES ===';

-- Ver en qué partición caen diferentes fechas
SELECT 
    '$PARTITION.PF_Facturas_PorMes(''2025-01-15'')' as ParticionEnero,
    '$PARTITION.PF_Facturas_PorMes(''2025-02-15'')' as ParticionFebrero,
    '$PARTITION.PF_Facturas_PorMes(''2025-06-15'')' as ParticionJunio,
    '$PARTITION.PF_Facturas_PorMes(''2025-12-15'')' as ParticionDiciembre;

-- PASO 7: Probar consultas con eliminación de particiones
PRINT '=== PRUEBA DE PARTITION ELIMINATION ===';

-- Consulta que debería usar solo una partición (enero 2025)
SET STATISTICS IO ON;
PRINT 'Consulta específica para enero 2025:';
SELECT COUNT(*) as FacturasEnero2025
FROM Ventas.Facturas_Particionada 
WHERE fecha_registro >= '2025-01-01' AND fecha_registro < '2025-02-01';

-- Consulta que debería usar múltiples particiones
PRINT 'Consulta para primer trimestre 2025:';
SELECT COUNT(*) as FacturasPrimerTrimestre
FROM Ventas.Facturas_Particionada 
WHERE fecha_registro >= '2025-01-01' AND fecha_registro < '2025-04-01';

-- Consulta sin filtro de fecha (usa todas las particiones)
PRINT 'Consulta sin filtro de fecha:';
SELECT COUNT(*) as TotalFacturas
FROM Ventas.Facturas_Particionada;
SET STATISTICS IO OFF;

-- PASO 8: Comparar rendimiento entre tabla original y particionada
PRINT '=== COMPARACIÓN DE RENDIMIENTO ===';

DECLARE @inicio DATETIME2, @fin DATETIME2, @duracion BIGINT;

-- Consulta en tabla original
SET @inicio = SYSDATETIME();
SELECT COUNT(*) FROM Ventas.Facturas WHERE fecha_registro >= '2025-01-01' AND fecha_registro < '2025-02-01';
SET @fin = SYSDATETIME();
SET @duracion = DATEDIFF(MICROSECOND, @inicio, @fin);
PRINT 'Tabla original: ' + CAST(@duracion AS VARCHAR) + ' microsegundos';

-- Consulta en tabla particionada
SET @inicio = SYSDATETIME();
SELECT COUNT(*) FROM Ventas.Facturas_Particionada WHERE fecha_registro >= '2025-01-01' AND fecha_registro < '2025-02-01';
SET @fin = SYSDATETIME();
SET @duracion = DATEDIFF(MICROSECOND, @inicio, @fin);
PRINT 'Tabla particionada: ' + CAST(@duracion AS VARCHAR) + ' microsegundos';

-- PASO 9: Probar creación de nueva partición
PRINT '=== PRUEBA DE NUEVA PARTICIÓN ===';
-- Crear partición para enero 2026
EXEC Ventas.AgregarNuevaParticionMensual @fecha = '2026-01-01';

-- Verificar nueva partición
EXEC Ventas.ConsultarInformacionParticiones;

-- PASO 10: Insertar datos en la nueva partición para probar
PRINT '=== PRUEBA DE INSERCIÓN EN NUEVA PARTICIÓN ===';

-- Primero necesitamos datos de referencia válidos
DECLARE @dni_cliente CHAR(8), @cod_vendedor INT, @cod_asesor INT;
SELECT TOP 1 @dni_cliente = dni FROM RecursosHumanos.Clientes;
SELECT TOP 1 @cod_vendedor = cod_vendedor FROM RecursosHumanos.Vendedores;
SELECT TOP 1 @cod_asesor = cod_asesor FROM RecursosHumanos.Asesores;

-- Insertar factura de prueba en 2026
INSERT INTO Ventas.Facturas_Particionada (dni, cod_vendedor, cod_asesor, fecha_registro)
VALUES (@dni_cliente, @cod_vendedor, @cod_asesor, '2026-01-15 10:30:00');

-- Verificar en qué partición cayó el registro
SELECT 
    '$PARTITION.PF_Facturas_PorMes(fecha_registro)' as NumeroParticion,
    fecha_registro,
    cod_factura
FROM Ventas.Facturas_Particionada 
WHERE fecha_registro >= '2026-01-01';

-- PASO 11: Consultas de análisis detallado
PRINT '=== ANÁLISIS DETALLADO DE PARTICIONES ===';

-- Ver distribución de datos por partición
SELECT 
    '$PARTITION.PF_Facturas_PorMes(fecha_registro)' as NumeroParticion,
    MIN(fecha_registro) as FechaMinima,
    MAX(fecha_registro) as FechaMaxima,
    COUNT(*) as CantidadRegistros
FROM Ventas.Facturas_Particionada
GROUP BY $PARTITION.PF_Facturas_PorMes(fecha_registro)
ORDER BY NumeroParticion;

-- Ver detalles de la función de partición
SELECT 
    pf.name AS NombreFuncion,
    pf.type_desc AS TipoFuncion,
    prv.boundary_id AS IdLimite,
    prv.value AS Valor
FROM sys.partition_functions pf
LEFT JOIN sys.partition_range_values prv ON pf.function_id = prv.function_id
WHERE pf.name = 'PF_Facturas_PorMes'
ORDER BY prv.boundary_id;

-- PASO 12: Limpiar datos de prueba (opcional)
PRINT '=== LIMPIEZA (OPCIONAL) ===';
-- DELETE FROM Ventas.Facturas_Particionada WHERE fecha_registro >= '2026-01-01';

-- PASO 13: Consultas de monitoreo continuo
PRINT '=== CONSULTAS DE MONITOREO ===';

-- Consulta para ver el uso del espacio por partición
SELECT 
    OBJECT_NAME(p.object_id) AS NombreTabla,
    p.partition_number AS NumeroParticion,
    fg.name AS Filegroup,
    p.rows AS NumeroFilas,
    au.total_pages * 8 / 1024.0 AS TamañoMB,
    au.used_pages * 8 / 1024.0 AS EspacioUsadoMB,
    au.data_pages * 8 / 1024.0 AS EspacioDatosMB
FROM sys.partitions p
INNER JOIN sys.allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON p.object_id = OBJECT_ID('Ventas.Facturas_Particionada')
INNER JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id 
    AND p.partition_number = dds.destination_id
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
WHERE p.object_id = OBJECT_ID('Ventas.Facturas_Particionada')
AND p.rows > 0  -- Solo particiones con datos
ORDER BY p.partition_number;

-- Consulta básica de facturas con sus detalles(tablas particionadas)
SELECT 
    f.cod_factura,
    f.fecha_registro,
    df.cod_producto,
    p.nombre AS producto,
    df.cantidad,
    p.precio_venta,
    (df.cantidad * p.precio_venta) AS subtotal
FROM Ventas.Facturas_Particionada f
JOIN Ventas.Detalle_Facturas_Particionada df ON f.cod_factura = df.cod_factura
JOIN Inventario.Productos p ON df.cod_producto = p.cod_producto
ORDER BY f.cod_factura, df.cod_producto;