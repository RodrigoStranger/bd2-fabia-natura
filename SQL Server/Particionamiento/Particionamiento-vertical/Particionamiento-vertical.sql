USE [master];
GO

-- Verificar si la base de datos existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'FabiaNatura')
BEGIN
    RAISERROR('La base de datos FabiaNatura no existe. Por favor, créala primero.', 16, 1);
    RETURN;
END
GO

USE FabiaNatura;
GO

-- 1. Agregar filegroups si no existen
IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_Auditoria_Metadatos')
BEGIN
    ALTER DATABASE FabiaNatura 
    ADD FILEGROUP FG_Auditoria_Metadatos;
    PRINT 'Filegroup FG_Auditoria_Metadatos creado.';
END

IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_Auditoria_Datos')
BEGIN
    ALTER DATABASE FabiaNatura 
    ADD FILEGROUP FG_Auditoria_Datos;
    PRINT 'Filegroup FG_Auditoria_Datos creado.';
END
GO

-- 2. Agregar archivos de datos a los filegroups
DECLARE @data_path NVARCHAR(256);
SELECT @data_path = physical_name 
FROM sys.master_files 
WHERE database_id = 1 AND file_id = 1;
SET @data_path = LEFT(@data_path, LEN(@data_path) - CHARINDEX('/', REVERSE(@data_path))) + '/FabiaNatura_';

-- Agregar archivo para metadatos
IF NOT EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'FabiaNatura_Auditoria_Metadatos')
BEGIN
    DECLARE @sql_metadatos NVARCHAR(MAX) = 
    N'ALTER DATABASE FabiaNatura 
    ADD FILE 
    (
        NAME = ''FabiaNatura_Auditoria_Metadatos'',
        FILENAME = ''' + @data_path + 'Auditoria_Metadatos.ndf'',
        SIZE = 100MB,
        FILEGROWTH = 50MB
    ) TO FILEGROUP FG_Auditoria_Metadatos;';
    
    EXEC sp_executesql @sql_metadatos;
    PRINT 'Archivo de datos para metadatos creado.';
END

-- Agregar archivo para datos
IF NOT EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'FabiaNatura_Auditoria_Datos')
BEGIN
    DECLARE @sql_datos NVARCHAR(MAX) = 
    N'ALTER DATABASE FabiaNatura 
    ADD FILE 
    (
        NAME = ''FabiaNatura_Auditoria_Datos'',
        FILENAME = ''' + @data_path + 'Auditoria_Datos.ndf'',
        SIZE = 200MB,
        FILEGROWTH = 100MB
    ) TO FILEGROUP FG_Auditoria_Datos;';
    
    EXEC sp_executesql @sql_datos;
    PRINT 'Archivo de datos para auditoría creado.';
END
GO

-- 3. Crear el esquema de auditoría si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Auditoria')
BEGIN
    EXEC('CREATE SCHEMA Auditoria');
    PRINT 'Esquema Auditoria creado exitosamente.';
END
GO

-- 4. Crear tabla para metadatos de auditoría (búsquedas frecuentes)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditoriaVentas_Metadatos' AND schema_id = SCHEMA_ID('Auditoria'))
BEGIN
    CREATE TABLE Auditoria.AuditoriaVentas_Metadatos
    (
        id_auditoria INT IDENTITY(1,1) NOT NULL,
        fecha_hora DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        usuario NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
        tabla_afectada NVARCHAR(128) NOT NULL,
        operacion CHAR(1) NOT NULL, -- I: Insert, U: Update, D: Delete
        id_entidad INT NULL, -- ID del registro afectado
        ip_origen NVARCHAR(50) NULL,
        CONSTRAINT PK_AuditoriaVentas_Metadatos PRIMARY KEY (id_auditoria)
    ) ON [FG_Auditoria_Metadatos]; -- Filegroup para metadatos
    
    PRINT 'Tabla de metadatos de auditoría creada.';
END
ELSE
BEGIN
    PRINT 'La tabla de metadatos de auditoría ya existe.';
END
GO

-- 5. Crear tabla para datos detallados (consultados con menos frecuencia)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditoriaVentas_Datos' AND schema_id = SCHEMA_ID('Auditoria'))
BEGIN
    CREATE TABLE Auditoria.AuditoriaVentas_Datos
    (
        id_auditoria INT NOT NULL,
        datos_anteriores NVARCHAR(MAX) NULL,
        datos_nuevos NVARCHAR(MAX) NULL,
        CONSTRAINT PK_AuditoriaVentas_Datos PRIMARY KEY (id_auditoria),
        CONSTRAINT FK_AuditoriaVentas_Datos_Metadatos FOREIGN KEY (id_auditoria) 
            REFERENCES Auditoria.AuditoriaVentas_Metadatos(id_auditoria)
    ) ON [FG_Auditoria_Datos]; -- Filegroup para datos
    
    PRINT 'Tabla de datos de auditoría creada.';
END
ELSE
BEGIN
    PRINT 'La tabla de datos de auditoría ya existe.';
END
GO

-- 6. Crear vista para mantener compatibilidad
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'Vista_AuditoriaVentas_Completa' AND schema_id = SCHEMA_ID('Auditoria'))
BEGIN
    EXEC('
    CREATE VIEW Auditoria.Vista_AuditoriaVentas_Completa
    AS
    SELECT 
        m.id_auditoria,
        m.fecha_hora,
        m.usuario,
        m.tabla_afectada,
        m.operacion,
        m.id_entidad,
        d.datos_anteriores,
        d.datos_nuevos,
        m.ip_origen
    FROM Auditoria.AuditoriaVentas_Metadatos m
    JOIN Auditoria.AuditoriaVentas_Datos d ON m.id_auditoria = d.id_auditoria;');
    
    PRINT 'Vista de auditoría creada.';
END
ELSE
BEGIN
    PRINT 'La vista de auditoría ya existe.';
END
GO

-- 7. Crear procedimiento para insertar en ambas tablas
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'RegistrarAuditoria' AND schema_id = SCHEMA_ID('Auditoria'))
BEGIN
    EXEC('
    CREATE PROCEDURE Auditoria.RegistrarAuditoria
        @tabla_afectada NVARCHAR(128),
        @operacion CHAR(1),
        @id_entidad INT = NULL,
        @datos_anteriores NVARCHAR(MAX) = NULL,
        @datos_nuevos NVARCHAR(MAX) = NULL,
        @usuario NVARCHAR(128) = NULL,
        @ip_origen NVARCHAR(50) = NULL
    AS
    BEGIN
        SET NOCOUNT ON;
        
        DECLARE @id_auditoria INT;
        
        BEGIN TRY
            BEGIN TRANSACTION;
            
            -- Insertar en metadatos
            INSERT INTO Auditoria.AuditoriaVentas_Metadatos
            (fecha_hora, usuario, tabla_afectada, operacion, id_entidad, ip_origen)
            VALUES
            (
                SYSUTCDATETIME(),
                ISNULL(@usuario, SYSTEM_USER),
                @tabla_afectada,
                @operacion,
                @id_entidad,
                ISNULL(@ip_origen, CONVERT(NVARCHAR(50), CONNECTIONPROPERTY(''client_net_address'')))
            );
            
            -- Obtener el ID insertado
            SET @id_auditoria = SCOPE_IDENTITY();
            
            -- Insertar en datos detallados
            INSERT INTO Auditoria.AuditoriaVentas_Datos
            (id_auditoria, datos_anteriores, datos_nuevos)
            VALUES
            (@id_auditoria, @datos_anteriores, @datos_nuevos);
            
            COMMIT TRANSACTION;
            RETURN @id_auditoria;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
                
            PRINT ''Error al registrar auditoría: '' + ERROR_MESSAGE();
            THROW;
        END CATCH
    END');
    
    PRINT 'Procedimiento RegistrarAuditoria creado.';
END
ELSE
BEGIN
    PRINT 'El procedimiento RegistrarAuditoria ya existe.';
END
GO

-- 8. Crear trigger de ejemplo para Ventas.Facturas
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_Ventas_Facturas_Auditoria' AND parent_id = OBJECT_ID('Ventas.Facturas'))
BEGIN
    EXEC('
    CREATE TRIGGER TR_Ventas_Facturas_Auditoria
    ON Ventas.Facturas
    AFTER INSERT, UPDATE, DELETE
    AS
    BEGIN
        SET NOCOUNT ON;
        
        DECLARE @operacion CHAR(1);
        DECLARE @id_entidad INT;
        DECLARE @datos_anteriores NVARCHAR(MAX) = NULL;
        DECLARE @datos_nuevos NVARCHAR(MAX) = NULL;
        
        -- Determinar el tipo de operación
        IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        BEGIN
            SET @operacion = ''U''; -- Update
            SELECT @id_entidad = cod_factura FROM inserted;
            SELECT @datos_anteriores = (SELECT * FROM deleted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
            SELECT @datos_nuevos = (SELECT * FROM inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        END
        ELSE IF EXISTS (SELECT * FROM inserted)
        BEGIN
            SET @operacion = ''I''; -- Insert
            SELECT @id_entidad = cod_factura, 
                   @datos_nuevos = (SELECT * FROM inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) 
            FROM inserted;
        END
        ELSE
        BEGIN
            SET @operacion = ''D''; -- Delete
            SELECT @id_entidad = cod_factura, 
                   @datos_anteriores = (SELECT * FROM deleted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) 
            FROM deleted;
        END
        
        -- Registrar la auditoría
        EXEC Auditoria.RegistrarAuditoria
            @tabla_afectada = ''Ventas.Facturas'',
            @operacion = @operacion,
            @id_entidad = @id_entidad,
            @datos_anteriores = @datos_anteriores,
            @datos_nuevos = @datos_nuevos;
    END');
    
    PRINT 'Trigger TR_Ventas_Facturas_Auditoria creado.';
END
ELSE
BEGIN
    PRINT 'El trigger TR_Ventas_Facturas_Auditoria ya existe.';
END
GO

-- 9. Procedimiento para consultar auditoría
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ConsultarAuditoria' AND schema_id = SCHEMA_ID('Auditoria'))
BEGIN
    EXEC('
    CREATE PROCEDURE Auditoria.ConsultarAuditoria
        @fecha_desde DATETIME2 = NULL,
        @fecha_hasta DATETIME2 = NULL,
        @tabla NVARCHAR(128) = NULL,
        @operacion CHAR(1) = NULL,
        @usuario NVARCHAR(128) = NULL
    AS
    BEGIN
        SET NOCOUNT ON;
        
        SELECT 
            m.id_auditoria,
            m.fecha_hora,
            m.usuario,
            m.tabla_afectada,
            CASE m.operacion
                WHEN ''I'' THEN ''Inserción''
                WHEN ''U'' THEN ''Actualización''
                WHEN ''D'' THEN ''Eliminación''
                ELSE m.operacion
            END as operacion,
            m.id_entidad,
            d.datos_anteriores,
            d.datos_nuevos,
            m.ip_origen
        FROM Auditoria.AuditoriaVentas_Metadatos m
        JOIN Auditoria.AuditoriaVentas_Datos d ON m.id_auditoria = d.id_auditoria
        WHERE (@fecha_desde IS NULL OR m.fecha_hora >= @fecha_desde)
          AND (@fecha_hasta IS NULL OR m.fecha_hora <= @fecha_hasta)
          AND (@tabla IS NULL OR m.tabla_afectada = @tabla)
          AND (@operacion IS NULL OR m.operacion = @operacion)
          AND (@usuario IS NULL OR m.usuario = @usuario)
        ORDER BY m.fecha_hora DESC;
    END');
    
    PRINT 'Procedimiento ConsultarAuditoria creado.';
END
ELSE
BEGIN
    PRINT 'El procedimiento ConsultarAuditoria ya existe.';
END
GO

PRINT 'Estructura de auditoría con particionamiento vertical configurada exitosamente.';
PRINT 'Filegroups:';
PRINT '- FG_Auditoria_Metadatos: Para metadatos de auditoría (búsquedas frecuentes)';
PRINT '- FG_Auditoria_Datos: Para datos detallados de auditoría (consultas menos frecuentes)';
GO