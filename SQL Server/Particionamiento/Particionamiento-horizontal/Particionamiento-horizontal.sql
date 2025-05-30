-- File: SQL Server\Particionamiento\1_particionamiento_horizontal_mejorado.sql
USE FabiaNatura;
GO

-- Crear función de partición por rango de fechas (mensual)
-- Se mantiene RANGE RIGHT para incluir el primer día del mes en cada partición
CREATE PARTITION FUNCTION PF_Facturas_PorMes (DATETIME)
AS RANGE RIGHT FOR VALUES (
    '2025-01-01', '2025-02-01', '2025-03-01', '2025-04-01', '2025-05-01',
    '2025-06-01', '2025-07-01', '2025-08-01', '2025-09-01', '2025-10-01',
    '2025-11-01', '2025-12-01'
);
GO

-- Crear esquema de partición
-- Usar el filegroup FG_Ventas existente para todas las particiones iniciales
CREATE PARTITION SCHEME PS_Facturas_PorMes
AS PARTITION PF_Facturas_PorMes
ALL TO ([FG_Ventas]);
GO

-- Crear tabla particionada Facturas
CREATE TABLE Ventas.Facturas_Particionada (
    cod_factura INT IDENTITY(1,1),
    dni CHAR(8) NOT NULL,
    cod_vendedor INT NOT NULL,
    cod_asesor INT,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Facturas_Particionada PRIMARY KEY (cod_factura, fecha_registro),
    -- Mantener las restricciones de integridad referencial
    FOREIGN KEY (dni) REFERENCES RecursosHumanos.Clientes(dni) ON UPDATE NO ACTION,
    FOREIGN KEY (cod_vendedor) REFERENCES RecursosHumanos.Vendedores(cod_vendedor) ON UPDATE NO ACTION,
    FOREIGN KEY (cod_asesor) REFERENCES RecursosHumanos.Asesores(cod_asesor) ON UPDATE NO ACTION
) ON PS_Facturas_PorMes(fecha_registro);
GO

-- Crear tabla particionada Detalle_Facturas
CREATE TABLE Ventas.Detalle_Facturas_Particionada (
    cod_factura INT NOT NULL,
    cod_producto INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Detalle_Facturas_Particionada PRIMARY KEY (cod_factura, cod_producto, fecha_registro),
    -- Relación con productos
    FOREIGN KEY (cod_producto) REFERENCES Inventario.Productos(cod_producto) ON UPDATE CASCADE,
    -- Relación con facturas particionadas - IMPORTANTE: Debe coincidir con la clave de partición
    FOREIGN KEY (cod_factura, fecha_registro) REFERENCES Ventas.Facturas_Particionada(cod_factura, fecha_registro) ON UPDATE CASCADE ON DELETE CASCADE
) ON PS_Facturas_PorMes(fecha_registro);
GO

CREATE OR ALTER PROCEDURE Ventas.MigrarYLimpiarDatos
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Verificar que hay datos para migrar
        IF NOT EXISTS (SELECT 1 FROM Ventas.Facturas)
        BEGIN
            RAISERROR('No hay datos para migrar en la tabla Facturas.', 16, 1);
            RETURN;
        END
        
        -- 2. Deshabilitar restricciones en tablas originales
        PRINT 'Deshabilitando restricciones en tablas originales...';
        ALTER TABLE Ventas.Detalle_Facturas NOCHECK CONSTRAINT ALL;
        ALTER TABLE Ventas.Facturas NOCHECK CONSTRAINT ALL;
        
        -- 3. Habilitar IDENTITY_INSERT para mantener los mismos códigos
        SET IDENTITY_INSERT Ventas.Facturas_Particionada ON;
        
        -- 4. Insertar facturas manteniendo los mismos códigos
        PRINT 'Migrando facturas...';
        INSERT INTO Ventas.Facturas_Particionada (cod_factura, dni, cod_vendedor, cod_asesor, fecha_registro)
        SELECT cod_factura, dni, cod_vendedor, cod_asesor, fecha_registro
        FROM Ventas.Facturas
        ORDER BY fecha_registro;
        
        SET IDENTITY_INSERT Ventas.Facturas_Particionada OFF;
        
        -- 5. Insertar detalles
        PRINT 'Migrando detalles de facturas...';
        INSERT INTO Ventas.Detalle_Facturas_Particionada (cod_factura, cod_producto, cantidad, fecha_registro)
        SELECT 
            df.cod_factura, 
            df.cod_producto, 
            df.cantidad, 
            f.fecha_registro
        FROM Ventas.Detalle_Facturas df
        INNER JOIN Ventas.Facturas f ON df.cod_factura = f.cod_factura;
        
        -- 6. Limpiar tablas originales
        PRINT 'Limpiando tablas originales...';
        DELETE FROM Ventas.Detalle_Facturas;
        DELETE FROM Ventas.Facturas;
        
        -- 7. Volver a habilitar restricciones
        PRINT 'Habilitando restricciones...';
        ALTER TABLE Ventas.Facturas CHECK CONSTRAINT ALL;
        ALTER TABLE Ventas.Detalle_Facturas CHECK CONSTRAINT ALL;
        
        COMMIT TRANSACTION;
        PRINT 'Migración y limpieza completadas exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error durante la migración: ' + ERROR_MESSAGE();
        THROW;
    END CATCH;
END;
GO

-- Crear procedimiento mejorado para agregar nueva partición
CREATE PROCEDURE Ventas.AgregarNuevaParticionMensual
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @sql NVARCHAR(MAX);
        DECLARE @nombreFilegroup VARCHAR(100) = 'FG_Ventas_' + FORMAT(@fecha, 'yyyyMM');
        DECLARE @nombreArchivo VARCHAR(100) = 'Ventas_data_' + FORMAT(@fecha, 'yyyyMM');
        DECLARE @rutaArchivo NVARCHAR(500) = 'C:\FabiaNaturaBD\' + @nombreArchivo + '.ndf';
        DECLARE @fechaParticion VARCHAR(10) = CONVERT(VARCHAR(10), @fecha, 121);
        
        -- Verificar que la fecha no esté ya en la función de partición
        IF EXISTS (
            SELECT 1 FROM sys.partition_range_values prv
            INNER JOIN sys.partition_functions pf ON prv.function_id = pf.function_id
            WHERE pf.name = 'PF_Facturas_PorMes'
            AND CONVERT(DATE, prv.value) = @fecha
        )
        BEGIN
            PRINT 'La partición para la fecha ' + @fechaParticion + ' ya existe.';
            RETURN;
        END
        
        -- Agregar nuevo filegroup si no existe
        IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = @nombreFilegroup)
        BEGIN
            SET @sql = N'ALTER DATABASE FabiaNatura ADD FILEGROUP [' + @nombreFilegroup + '];';
            EXEC sp_executesql @sql;
            PRINT 'Filegroup ' + @nombreFilegroup + ' creado.';
            
            SET @sql = N'ALTER DATABASE FabiaNatura 
                        ADD FILE (NAME = ''' + @nombreArchivo + ''', 
                                 FILENAME = ''' + @rutaArchivo + ''', 
                                 SIZE = 500MB, 
                                 FILEGROWTH = 100MB) 
                        TO FILEGROUP [' + @nombreFilegroup + '];';
            EXEC sp_executesql @sql;
            PRINT 'Archivo ' + @nombreArchivo + ' agregado al filegroup.';
        END
        
        -- Establecer el filegroup como el siguiente a usar
        SET @sql = N'ALTER PARTITION SCHEME PS_Facturas_PorMes NEXT USED [' + @nombreFilegroup + '];';
        EXEC sp_executesql @sql;
        
        -- Dividir el rango para crear la nueva partición
        SET @sql = N'ALTER PARTITION FUNCTION PF_Facturas_PorMes() SPLIT RANGE (''' + @fechaParticion + ''');';
        EXEC sp_executesql @sql;
        
        PRINT 'Nueva partición creada para el mes ' + FORMAT(@fecha, 'yyyy-MM') + '.';
        
    END TRY
    BEGIN CATCH
        PRINT 'Error al crear la partición: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- Crear vista para consultar datos de ambas tablas (original y particionada)
CREATE VIEW Ventas.VW_Facturas_Completas
AS
SELECT 
    'Original' as TipoTabla,
    cod_factura,
    dni,
    cod_vendedor,
    cod_asesor,
    fecha_registro
FROM Ventas.Facturas
UNION ALL
SELECT 
    'Particionada' as TipoTabla,
    cod_factura,
    dni,
    cod_vendedor,
    cod_asesor,
    fecha_registro
FROM Ventas.Facturas_Particionada;
GO

-- Crear procedimiento para consultar información de particiones
CREATE PROCEDURE Ventas.ConsultarInformacionParticiones
AS
BEGIN
    SELECT 
        p.partition_number AS NumeroParticion,
        fg.name AS NombreFilegroup,
        prv.value AS ValorLimite,
        p.rows AS NumeroFilas,
        au.total_pages * 8 / 1024.0 AS TamañoMB
    FROM sys.partitions p
    INNER JOIN sys.allocation_units au ON p.partition_id = au.container_id
    INNER JOIN sys.partition_schemes ps ON p.object_id = OBJECT_ID('Ventas.Facturas_Particionada')
    INNER JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id 
        AND p.partition_number = dds.destination_id
    INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
    LEFT JOIN sys.partition_range_values prv ON ps.function_id = prv.function_id 
        AND p.partition_number = prv.boundary_id + 1
    WHERE p.object_id = OBJECT_ID('Ventas.Facturas_Particionada')
    ORDER BY p.partition_number;
END;
GO
