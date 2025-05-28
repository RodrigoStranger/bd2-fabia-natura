USE FabiaNatura;
GO

-- =====================================================
-- SCRIPT DE PRUEBA SIMPLIFICADO
-- Prueba las auditorías con datos existentes
-- =====================================================

-- 1. Verificar tablas de auditoría
PRINT '=== VERIFICANDO ESTRUCTURA DE AUDITORÍA ===';
SELECT 
    t.name AS tabla,
    SCHEMA_NAME(t.schema_id) AS esquema
FROM sys.tables t
WHERE t.schema_id = SCHEMA_ID('Auditoria');
GO

-- 2. Mostrar datos iniciales
PRINT '=== DATOS INICIALES ===';
PRINT '-- Últimas 5 facturas --';
SELECT TOP 5 * FROM Ventas.Facturas ORDER BY cod_factura DESC;
PRINT '-- Últimos 5 registros de auditoría --';
EXEC Auditoria.ConsultarAuditoria;
GO

-- 3. Usar una tabla temporal para mantener el ID de la factura
CREATE TABLE #TempFactura (factura_id INT);
GO

-- 4. Obtener una factura existente para pruebas
INSERT INTO #TempFactura (factura_id)
SELECT TOP 1 cod_factura 
FROM Ventas.Facturas 
ORDER BY cod_factura DESC;

-- Mostrar datos que se usarán
PRINT '=== DATOS PARA PRUEBAS ===';
SELECT 
    'Factura ID' AS dato, CAST(factura_id AS VARCHAR(20)) AS valor 
FROM #TempFactura
UNION ALL
SELECT 
    'DNI Cliente', CAST(f.dni AS VARCHAR(20))
FROM #TempFactura t
JOIN Ventas.Facturas f ON t.factura_id = f.cod_factura
UNION ALL
SELECT 
    'ID Vendedor', CAST(f.cod_vendedor AS VARCHAR(20))
FROM #TempFactura t
JOIN Ventas.Facturas f ON t.factura_id = f.cod_factura;
GO

-- 5. Prueba de UPDATE
PRINT '=== PRUEBA 1: ACTUALIZAR FACTURA ===';
BEGIN TRY
    -- Mostrar estado actual
    SELECT 'ANTES' AS estado, * 
    FROM Ventas.Facturas f
    JOIN #TempFactura t ON f.cod_factura = t.factura_id;
    
    -- Actualizar la factura
    UPDATE f
    SET f.cod_asesor = 1,  -- Asignar un asesor
        f.fecha_registro = GETDATE()
    FROM Ventas.Facturas f
    JOIN #TempFactura t ON f.cod_factura = t.factura_id;
    
    -- Mostrar estado después
    SELECT 'DESPUÉS' AS estado, * 
    FROM Ventas.Facturas f
    JOIN #TempFactura t ON f.cod_factura = t.factura_id;
    
    -- Mostrar auditorías
    PRINT '-- Registros de auditoría generados --';
    DECLARE @factura_id INT;
    SELECT @factura_id = factura_id FROM #TempFactura;
    EXEC Auditoria.ConsultarAuditoria 
        @tabla = 'Ventas.Facturas',
        @id_entidad = @factura_id;
END TRY
BEGIN CATCH
    PRINT 'Error al actualizar factura: ' + ERROR_MESSAGE();
END CATCH
GO

-- 6. Mostrar resultados finales
PRINT '=== RESULTADOS FINALES ===';
PRINT '-- Últimas 5 facturas --';
SELECT TOP 5 * FROM Ventas.Facturas ORDER BY cod_factura DESC;
PRINT '-- Últimos 5 registros de auditoría --';
EXEC Auditoria.ConsultarAuditoria;
GO

-- 7. Limpiar
DROP TABLE #TempFactura;
GO

PRINT '=== PRUEBA COMPLETADA ===';
GO