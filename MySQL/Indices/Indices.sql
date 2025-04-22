USE FabiaNatura;

-- Índices para Personas
CREATE INDEX idx_personas_nombre ON Personas(nombre);
CREATE INDEX idx_personas_apellido_paterno ON Personas(apellido_paterno);
CREATE INDEX idx_personas_apellido_materno ON Personas(apellido_materno);

-- Índices para Productos
CREATE INDEX idx_productos_nombre ON Productos(nombre);
CREATE INDEX idx_productos_categoria ON Productos(cod_categoria);

-- Índices para Proveedores
CREATE INDEX idx_proveedores_nombre ON Proveedores(nombre);
