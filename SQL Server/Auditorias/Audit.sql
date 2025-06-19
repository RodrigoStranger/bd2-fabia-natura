USE master;
GO
-- Crear la auditoría del servidor
CREATE SERVER AUDIT AuditoriaServidor
TO FILE (FILEPATH = 'C:\SQLAudit\');

GO
ALTER SERVER AUDIT AuditoriaServidor WITH (STATE = ON);
GO
USE FabiaNatura;
GO
-- Crear la especificación de auditoría a nivel de base de datos
CREATE DATABASE AUDIT SPECIFICATION Auditoriausuario01
FOR SERVER AUDIT AuditoriaServidor
ADD (SELECT, INSERT, UPDATE ON OBJECT::[Ventas].[Facturas] BY usuario01),
ADD (SELECT, INSERT, UPDATE ON OBJECT::[Ventas].[Detalle_Facturas] BY usuario01),
ADD (SELECT, INSERT, UPDATE ON OBJECT::[RecursosHumanos].[Clientes] BY usuario01),
ADD (SELECT, INSERT, UPDATE ON OBJECT::[Inventario].[Productos] BY usuario01),
ADD (SELECT, INSERT, UPDATE ON OBJECT::[Inventario].[Categorias] BY usuario01);
GO
ALTER DATABASE AUDIT SPECIFICATION Auditoriausuario01 WITH (STATE = ON);