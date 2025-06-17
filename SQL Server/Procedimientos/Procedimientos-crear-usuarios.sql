USE [FabiaNatura]
GO

-- Crear roles si no existen
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_asesor')
BEGIN
    CREATE ROLE rol_asesor;
    PRINT 'Rol rol_asesor creado exitosamente.';
END

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_vendedor')
BEGIN
    CREATE ROLE rol_vendedor;
    PRINT 'Rol rol_vendedor creado exitosamente.';
END
GO

-- Procedimiento para asignar rol de vendedor a un empleado existente
CREATE OR ALTER PROCEDURE [RecursosHumanos].[sp_AsignarVendedor]
    @cod_empleado INT,
    @rol VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @nombre_usuario VARCHAR(100);
    DECLARE @contrasena VARCHAR(30);
    DECLARE @dni CHAR(8);
    DECLARE @nombre VARCHAR(20);
    DECLARE @apellido_paterno VARCHAR(20);
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @error_message NVARCHAR(4000);
    
    BEGIN TRY
        -- Verificar si el empleado existe
        IF NOT EXISTS (SELECT 1 FROM RecursosHumanos.Empleados WHERE cod_empleado = @cod_empleado)
        BEGIN
            THROW 50001, 'El empleado no existe.', 1;
        END
        
        -- Verificar si ya es vendedor
        IF EXISTS (SELECT 1 FROM RecursosHumanos.Vendedores v 
                  INNER JOIN RecursosHumanos.Empleados e ON v.cod_empleado = e.cod_empleado
                  WHERE e.cod_empleado = @cod_empleado)
        BEGIN
            THROW 50002, 'El empleado ya tiene asignado el rol de vendedor.', 1;
        END
        
        -- Verificar si es asesor
        IF EXISTS (SELECT 1 FROM RecursosHumanos.Asesores a 
                  INNER JOIN RecursosHumanos.Empleados e ON a.cod_empleado = e.cod_empleado
                  WHERE e.cod_empleado = @cod_empleado)
        BEGIN
            THROW 50003, 'El empleado ya tiene asignado el rol de asesor.', 1;
        END
        
        -- Obtener información del empleado
        SELECT 
            @nombre = p.nombre,
            @apellido_paterno = p.apellido_paterno,
            @contrasena = e.contraseña,
            @dni = e.dni
        FROM RecursosHumanos.Empleados e
        INNER JOIN RecursosHumanos.Personas p ON e.dni = p.dni
        WHERE e.cod_empleado = @cod_empleado;
        
        -- Generar nombre de usuario
        SET @nombre_usuario = LOWER(LEFT(@nombre, 1) + @apellido_paterno);
        
        -- Iniciar transacción
        BEGIN TRANSACTION;
        
        -- 1. Insertar en la tabla Vendedores (no Vendedor)
        INSERT INTO RecursosHumanos.Vendedores (cod_empleado, rol)
        VALUES (@cod_empleado, @rol);
        
        -- 2. Verificar si el usuario ya existe
        IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @nombre_usuario)
        BEGIN
            -- Crear login
            SET @sql = 'CREATE LOGIN [' + @nombre_usuario + '] WITH PASSWORD = ''' + @contrasena + ''', CHECK_POLICY = OFF';
            EXEC sp_executesql @sql;
            
            -- Crear usuario
            SET @sql = 'CREATE USER [' + @nombre_usuario + '] FOR LOGIN [' + @nombre_usuario + ']';
            EXEC sp_executesql @sql;
        END
        
        -- 3. Verificar si existe el rol y crearlo si no existe
        IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_vendedor' AND type = 'R')
        BEGIN
            CREATE ROLE rol_vendedor;
        END
        
        -- 4. Asignar rol de vendedor
        SET @sql = 'ALTER ROLE rol_vendedor ADD MEMBER [' + @nombre_usuario + ']';
        EXEC sp_executesql @sql;
        
        -- Confirmar transacción
        COMMIT;
        
        -- Retornar información
        SELECT 
            'Vendedor asignado exitosamente' AS Mensaje,
            @nombre_usuario AS Usuario,
            @rol AS Rol,
            @cod_empleado AS cod_empleado,
            @dni AS DNI;

    END TRY
    BEGIN CATCH
        -- Si hay un error, deshacer cambios
        IF @@TRANCOUNT > 0
            ROLLBACK;
            
        -- Lanzar el error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Procedimiento para asignar rol de asesor a un empleado existente
CREATE OR ALTER PROCEDURE [RecursosHumanos].[sp_AsignarAsesor]
    @cod_empleado INT,
    @especialidad VARCHAR(20),
    @anios_experiencia INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @nombre_usuario VARCHAR(100);
    DECLARE @contrasena VARCHAR(30);
    DECLARE @dni CHAR(8);
    DECLARE @nombre VARCHAR(20);
    DECLARE @apellido_paterno VARCHAR(20);
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @error_message NVARCHAR(4000);
    
    BEGIN TRY
        -- Verificar si el empleado existe
        IF NOT EXISTS (SELECT 1 FROM RecursosHumanos.Empleados WHERE cod_empleado = @cod_empleado)
        BEGIN
            THROW 50001, 'El empleado no existe.', 1;
        END
        
        -- Verificar si ya es asesor
        IF EXISTS (SELECT 1 FROM RecursosHumanos.Asesores a 
                  INNER JOIN RecursosHumanos.Empleados e ON a.cod_empleado = e.cod_empleado
                  WHERE e.cod_empleado = @cod_empleado)
        BEGIN
            THROW 50002, 'El empleado ya tiene asignado el rol de asesor.', 1;
        END
        
        -- Verificar si es vendedor
        IF EXISTS (SELECT 1 FROM RecursosHumanos.Vendedores v 
                  INNER JOIN RecursosHumanos.Empleados e ON v.cod_empleado = e.cod_empleado
                  WHERE e.cod_empleado = @cod_empleado)
        BEGIN
            THROW 50003, 'El empleado ya tiene asignado el rol de vendedor.', 1;
        END
        
        -- Obtener información del empleado
        SELECT 
            @nombre = p.nombre,
            @apellido_paterno = p.apellido_paterno,
            @contrasena = e.contraseña,
            @dni = e.dni
        FROM RecursosHumanos.Empleados e
        INNER JOIN RecursosHumanos.Personas p ON e.dni = p.dni
        WHERE e.cod_empleado = @cod_empleado;
        
        -- Generar nombre de usuario
        SET @nombre_usuario = LOWER(LEFT(@nombre, 1) + @apellido_paterno);
        
        -- Iniciar transacción
        BEGIN TRANSACTION;
        
        -- 1. Insertar en la tabla Asesores (no Asesor)
        INSERT INTO RecursosHumanos.Asesores (cod_empleado, especialidad, experiencia)
        VALUES (@cod_empleado, @especialidad, @anios_experiencia);
        
        -- 2. Verificar si el usuario ya existe
        IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @nombre_usuario)
        BEGIN
            -- Crear login
            SET @sql = 'CREATE LOGIN [' + @nombre_usuario + '] WITH PASSWORD = ''' + @contrasena + ''', CHECK_POLICY = OFF';
            EXEC sp_executesql @sql;
            
            -- Crear usuario
            SET @sql = 'CREATE USER [' + @nombre_usuario + '] FOR LOGIN [' + @nombre_usuario + ']';
            EXEC sp_executesql @sql;
        END
        
        -- 3. Verificar si existe el rol y crearlo si no existe
        IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_asesor' AND type = 'R')
        BEGIN
            CREATE ROLE rol_asesor;
        END
        
        -- 4. Asignar rol de asesor
        SET @sql = 'ALTER ROLE rol_asesor ADD MEMBER [' + @nombre_usuario + ']';
        EXEC sp_executesql @sql;
        
        -- Confirmar transacción
        COMMIT;
        
        -- Retornar información
        SELECT 
            'Asesor asignado exitosamente' AS Mensaje,
            @nombre_usuario AS Usuario,
            @especialidad AS Especialidad,
            @anios_experiencia AS AniosExperiencia,
            @cod_empleado AS cod_empleado,
            @dni AS DNI;

    END TRY
    BEGIN CATCH
        -- Si hay un error, deshacer cambios
        IF @@TRANCOUNT > 0
            ROLLBACK;
            
        -- Lanzar el error con más detalles
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Ejemplos de uso:
-- 1. Insertar la persona
INSERT INTO RecursosHumanos.Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento) 
VALUES ('12345678', 'Juan', 'Pérez', 'Gómez', '1990-05-15');

-- 2. Insertar teléfono
INSERT INTO RecursosHumanos.Telefonos_Personas (telefono, dni) 
VALUES ('987654321', '12345678');

-- 3. Insertar dirección
INSERT INTO RecursosHumanos.Direcciones_Personas (dni, direccion) 
VALUES ('12345678', 'Calle Las Flores 123');

-- 4. Insertar empleado
INSERT INTO RecursosHumanos.Empleados (dni, contraseña, es_administrador, estado)
VALUES ('12345678', 'admin', 0, 'Activo');

--Mostrar el empleado creado
SELECT 
    p.dni,
    p.nombre,
    p.apellido_paterno,
    p.apellido_materno,
    p.fecha_nacimiento,
    t.telefono,
    d.direccion,
    e.contraseña,
    e.es_administrador,
    e.estado,
    e.cod_empleado
FROM 
    RecursosHumanos.Personas p
LEFT JOIN 
    RecursosHumanos.Telefonos_Personas t ON p.dni = t.dni
LEFT JOIN 
    RecursosHumanos.Direcciones_Personas d ON p.dni = d.dni
LEFT JOIN 
    RecursosHumanos.Empleados e ON p.dni = e.dni
WHERE 
    p.dni = '12345678';

-- 5. Asignar rol de vendedor al empleado
EXEC [RecursosHumanos].[sp_AsignarVendedor] 
    @cod_empleado = '1',  
    @rol = 'Vendedor Junior';      