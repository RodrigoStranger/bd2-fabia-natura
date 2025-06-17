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
CREATE DATABASE AUDIT SPECIFICATION AuditoriaFBJPerez
FOR SERVER AUDIT AuditoriaServidor
ADD (SELECT, INSERT, UPDATE ON OBJECT::[Ventas].[Facturas] BY JPérez),
ADD (SELECT, INSERT, UPDATE ON OBJECT::[Ventas].[Detalle_Facturas] BY JPérez),
ADD (SELECT, INSERT, UPDATE ON OBJECT::[RecursosHumanos].[Clientes] BY JPérez),
ADD (SELECT, INSERT, UPDATE ON OBJECT::[Inventario].[Productos] BY JPérez),
ADD (SELECT, INSERT, UPDATE ON OBJECT::[Inventario].[Categorias] BY JPérez);
GO
ALTER DATABASE AUDIT SPECIFICATION AuditoriaFBJPerez WITH (STATE = ON);