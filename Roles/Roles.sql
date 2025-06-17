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

-- Permisos para el rol de vendedor
GRANT EXECUTE ON SCHEMA::[Ventas] TO rol_vendedor;
GRANT SELECT, INSERT ON [Ventas].[Facturas] TO rol_vendedor;
GRANT SELECT, INSERT ON [Ventas].[Detalle_Facturas] TO rol_vendedor;
GRANT SELECT, INSERT ON [RecursosHumanos].[Clientes] TO rol_vendedor;
GRANT SELECT, UPDATE, INSERT ON [Inventario].[Productos] TO rol_vendedor;
GRANT SELECT ON [Inventario].[Categorias] TO rol_vendedor;

-- Permisos para el rol de asesor
GRANT SELECT ON [RecursosHumanos].[Clientes] TO rol_asesor;
GRANT SELECT ON [Inventario].[Productos] TO rol_asesor;
GRANT SELECT ON [Inventario].[Categorias] TO rol_asesor;