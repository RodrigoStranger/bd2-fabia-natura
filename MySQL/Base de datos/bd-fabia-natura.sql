CREATE DATABASE IF NOT EXISTS FabiaNatura;
USE FabiaNatura;

-- Tabla de Personas
CREATE TABLE IF NOT EXISTS Personas (
    dni VARCHAR(8) NOT NULL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    apellido_paterno VARCHAR(20) NOT NULL,
    apellido_materno VARCHAR(20) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Teléfonos de Personas
CREATE TABLE IF NOT EXISTS Telefonos_Personas (
    telefono VARCHAR(9) NOT NULL PRIMARY KEY,
    dni VARCHAR(8) NOT NULL,
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Direcciones de Personas
CREATE TABLE IF NOT EXISTS Direcciones_Personas (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(8) NOT NULL,
    direccion VARCHAR(100),
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Empleados
CREATE TABLE IF NOT EXISTS Empleados (
    cod_empleado INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(8) NOT NULL,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Vendedores
CREATE TABLE IF NOT EXISTS Vendedores (
    cod_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    cod_empleado INT NOT NULL,
    rol VARCHAR(20),
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Asesores
CREATE TABLE IF NOT EXISTS Asesores (
    cod_asesor INT AUTO_INCREMENT PRIMARY KEY,
    cod_empleado INT NOT NULL,
    experiencia INT NOT NULL,
    especialidad VARCHAR(20) NOT NULL,
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Clientes
CREATE TABLE IF NOT EXISTS Clientes (
    dni VARCHAR(8) NOT NULL PRIMARY KEY,
    tipo_cliente ENUM('regular', 'frecuente') NOT NULL DEFAULT 'regular',
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Contratos
CREATE TABLE IF NOT EXISTS Contratos (
    cod_contrato INT AUTO_INCREMENT PRIMARY KEY,
    cod_empleado INT NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    salario_men FLOAT NOT NULL,
    observaciones TEXT,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Proveedores
CREATE TABLE IF NOT EXISTS Proveedores (
    ruc VARCHAR(11) NOT NULL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Teléfonos de Proveedores
CREATE TABLE IF NOT EXISTS Telefonos_Proveedores (
    ruc VARCHAR(11) NOT NULL,
    telefono VARCHAR(15) NOT NULL PRIMARY KEY,
    FOREIGN KEY (ruc) REFERENCES Proveedores(ruc) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Categorías
CREATE TABLE IF NOT EXISTS Categorias (
    cod_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Productos
CREATE TABLE IF NOT EXISTS Productos (
    cod_producto INT AUTO_INCREMENT PRIMARY KEY,
    cod_categoria INT,
    ruc VARCHAR(11),
    nombre VARCHAR(100) UNIQUE NOT NULL,
    linea VARCHAR(100),
    descripcion TEXT,
    precio_compra FLOAT NOT NULL,
    precio_venta FLOAT NOT NULL,
    stock INT NOT NULL,
    estado ENUM('disponible', 'agotado') NOT NULL DEFAULT 'disponible',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cod_categoria) REFERENCES Categorias(cod_categoria) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (ruc) REFERENCES Proveedores(ruc) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Facturas
CREATE TABLE IF NOT EXISTS Facturas (
    cod_factura INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(8) NOT NULL,
    cod_vendedor INT NOT NULL,
    cod_asesor INT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dni) REFERENCES Clientes(dni) ON UPDATE CASCADE,
    FOREIGN KEY (cod_vendedor) REFERENCES Vendedores(cod_vendedor) ON UPDATE CASCADE,
    FOREIGN KEY (cod_asesor) REFERENCES Asesores(cod_asesor) ON UPDATE CASCADE
);

-- Detalles de Facturas
CREATE TABLE IF NOT EXISTS Detalle_Facturas (
    cod_factura INT NOT NULL,
    cod_producto INT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (cod_factura, cod_producto),
    FOREIGN KEY (cod_factura) REFERENCES Facturas(cod_factura) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cod_producto) REFERENCES Productos(cod_producto) ON DELETE CASCADE ON UPDATE CASCADE
);