-- Crear la base de datos si no existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'FabiaNatura')
BEGIN
    CREATE DATABASE FabiaNatura;
END;
GO

USE FabiaNatura;
GO

-- Tabla de Personas
CREATE TABLE Personas (
    dni CHAR(8) NOT NULL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    apellido_paterno VARCHAR(20) NOT NULL,
    apellido_materno VARCHAR(20) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE()
);

-- Teléfonos de Personas
CREATE TABLE Telefonos_Personas (
    telefono CHAR(9) NOT NULL PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON UPDATE CASCADE
);

-- Direcciones de Personas
CREATE TABLE Direcciones_Personas (
    id_direccion INT IDENTITY(1,1) PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    direccion VARCHAR(100),
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON UPDATE CASCADE
);

-- Empleados
CREATE TABLE Empleados (
    cod_empleado INT IDENTITY(1,1) PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    estado VARCHAR(10) CHECK (estado IN ('activo', 'inactivo')) NOT NULL DEFAULT 'activo',
    contraseña VARCHAR(30),
    es_administrador BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON UPDATE CASCADE
);

-- Vendedores
CREATE TABLE Vendedores (
    cod_vendedor INT IDENTITY(1,1) PRIMARY KEY,
    cod_empleado INT NOT NULL,
    rol VARCHAR(20),
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON UPDATE CASCADE
);

-- Asesores
CREATE TABLE Asesores (
    cod_asesor INT IDENTITY(1,1) PRIMARY KEY,
    cod_empleado INT NOT NULL,
    experiencia INT NOT NULL,
    especialidad VARCHAR(20) NOT NULL,
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON UPDATE CASCADE
);

-- Clientes
CREATE TABLE Clientes (
    dni CHAR(8) NOT NULL PRIMARY KEY,
    tipo_cliente VARCHAR(10) CHECK (tipo_cliente IN ('regular', 'frecuente')) NOT NULL DEFAULT 'regular',
    FOREIGN KEY (dni) REFERENCES Personas(dni) ON UPDATE CASCADE
);

-- Contratos
CREATE TABLE Contratos (
    cod_contrato INT IDENTITY(1,1) PRIMARY KEY,
    cod_empleado INT NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    salario_men FLOAT NOT NULL,
    observaciones TEXT,
    estado VARCHAR(10) CHECK (estado IN ('activo', 'inactivo')) NOT NULL DEFAULT 'activo',
    FOREIGN KEY (cod_empleado) REFERENCES Empleados(cod_empleado) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Proveedores
CREATE TABLE Proveedores (
    ruc CHAR(11) NOT NULL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE()
);

-- Teléfonos de Proveedores
CREATE TABLE Telefonos_Proveedores (
    ruc CHAR(11) NOT NULL,
    telefono CHAR(15) NOT NULL PRIMARY KEY,
    FOREIGN KEY (ruc) REFERENCES Proveedores(ruc) ON UPDATE CASCADE
);

-- Categorías
CREATE TABLE Categorias (
    cod_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE()
);

-- Productos
CREATE TABLE Productos (
    cod_producto INT IDENTITY(1,1) PRIMARY KEY,
    cod_categoria INT,
    ruc CHAR(11),
    nombre VARCHAR(100) UNIQUE NOT NULL,
    linea VARCHAR(100),
    descripcion TEXT,
    precio_compra FLOAT NOT NULL,
    precio_venta FLOAT NOT NULL,
    stock INT NOT NULL,
    estado VARCHAR(10) CHECK (estado IN ('disponible', 'agotado')) NOT NULL DEFAULT 'disponible',
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (cod_categoria) REFERENCES Categorias(cod_categoria) ON UPDATE CASCADE,
    FOREIGN KEY (ruc) REFERENCES Proveedores(ruc) ON UPDATE CASCADE
);

-- Facturas
CREATE TABLE Facturas (
    cod_factura INT IDENTITY(1,1) PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    cod_vendedor INT NOT NULL,
    cod_asesor INT,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (dni) REFERENCES Clientes(dni) ON UPDATE NO ACTION,
    FOREIGN KEY (cod_vendedor) REFERENCES Vendedores(cod_vendedor) ON UPDATE NO ACTION,
    FOREIGN KEY (cod_asesor) REFERENCES Asesores(cod_asesor) ON UPDATE NO ACTION
);

-- Detalles de Facturas
CREATE TABLE Detalle_Facturas (
    cod_factura INT NOT NULL,
    cod_producto INT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (cod_factura, cod_producto),
    FOREIGN KEY (cod_factura) REFERENCES Facturas(cod_factura) ON UPDATE CASCADE,
    FOREIGN KEY (cod_producto) REFERENCES Productos(cod_producto) ON UPDATE CASCADE
);