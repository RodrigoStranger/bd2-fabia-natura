-- Crear el rol admin_role
CREATE ROLE 'admin_role';

-- Asignar todos los permisos al rol, menos los permisos de eliminación
GRANT ALL PRIVILEGES ON `FabiaNatura`.* TO 'admin_role' WITH GRANT OPTION;
REVOKE DELETE, CREATE, DROP ON `FabiaNatura`.* FROM 'admin_role';

-- Demostracion
CREATE USER 'admin1'@'localhost' IDENTIFIED BY 'tu_contraseña_segura';
GRANT 'admin_role' TO 'admin1'@'localhost';
SET DEFAULT ROLE 'admin_role' TO 'admin1'@'localhost';

SHOW GRANTS FOR 'admin1'@'localhost';