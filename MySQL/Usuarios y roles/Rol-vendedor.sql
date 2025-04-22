-- Crear el rol vendedor_role
CREATE ROLE 'vendedor_role';

-- Asignar permisos necesarios al rol vendedor_role
GRANT SELECT ON `FabiaNatura`.`Clientes` TO 'vendedor_role';
GRANT INSERT ON `FabiaNatura`.`Clientes` TO 'vendedor_role';

GRANT SELECT ON `FabiaNatura`.`Direcciones_Personas` TO 'vendedor_role';
GRANT SELECT ON `FabiaNatura`.`Telefonos_Personas` TO 'vendedor_role';

GRANT SELECT ON `FabiaNatura`.`Contratos` TO 'vendedor_role';
GRANT SELECT ON `FabiaNatura`.`Proveedores` TO 'vendedor_role';
GRANT SELECT ON `FabiaNatura`.`Telefonos_Proveedores` TO 'vendedor_role';

GRANT SELECT ON `FabiaNatura`.`Asesores` TO 'vendedor_role';
GRANT SELECT ON `FabiaNatura`.`Categorias` TO 'vendedor_role';
GRANT SELECT ON `FabiaNatura`.`Productos` TO 'vendedor_role';

GRANT SELECT ON `FabiaNatura`.`Vendedores` TO 'vendedor_role';
GRANT SELECT ON `FabiaNatura`.`Empleados` TO 'vendedor_role';

GRANT INSERT ON `FabiaNatura`.`Facturas` TO 'vendedor_role';
GRANT INSERT ON `FabiaNatura`.`Detalle_Facturas` TO 'vendedor_role';

GRANT SELECT ON `FabiaNatura`.`Detalle_Facturas` TO 'vendedor_role';
GRANT SELECT ON `FabiaNatura`.`Facturas` TO 'vendedor_role';

-- Parte demostrativa
CREATE USER 'vendedor1'@'localhost' IDENTIFIED BY 'tu_contraseña_segura';
GRANT 'vendedor_role' TO 'vendedor1'@'localhost';
SET DEFAULT ROLE 'vendedor_role' TO 'vendedor1'@'localhost';

SHOW GRANTS FOR 'vendedor1'@'localhost';