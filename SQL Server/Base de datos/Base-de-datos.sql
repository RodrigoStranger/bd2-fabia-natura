-- Crear la base de datos con filegroups y asignación de tamaño si no existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'FabiaNatura')
BEGIN
    CREATE DATABASE FabiaNatura
    ON 
    PRIMARY (NAME = 'FabiaNatura_data', FILENAME = 'C:\FabiaNaturaBD\FabiaNatura_data.mdf', SIZE = 2GB, FILEGROWTH = 200MB),
    FILEGROUP FG_RecursosHumanos (NAME = 'RecursosHumanos_data', FILENAME = 'C:\FabiaNaturaBD\RecursosHumanos_data.ndf', SIZE = 1GB, FILEGROWTH = 100MB),
    FILEGROUP FG_Ventas (NAME = 'Ventas_data', FILENAME = 'C:\FabiaNaturaBD\Ventas_data.ndf', SIZE = 1GB, FILEGROWTH = 100MB),
    FILEGROUP FG_Inventario (NAME = 'Inventario_data', FILENAME = 'C:\FabiaNaturaBD\Inventario_data.ndf', SIZE = 1GB, FILEGROWTH = 100MB)
    LOG ON (NAME = 'FabiaNatura_log', FILENAME = 'C:\FabiaNaturaBD\FabiaNatura_log.ldf', SIZE = 500MB, FILEGROWTH = 50MB);
END;
GO

USE FabiaNatura;
GO

-- Crear esquemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'RecursosHumanos')
BEGIN
    EXEC('CREATE SCHEMA RecursosHumanos');
END;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ventas')
BEGIN
    EXEC('CREATE SCHEMA Ventas');
END;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Inventario')
BEGIN
    EXEC('CREATE SCHEMA Inventario');
END;
GO

-- Crear tablas en el esquema Inventario

-- Proveedores
CREATE TABLE Inventario.Proveedores (
    ruc CHAR(11) NOT NULL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE()
) ON [FG_Inventario];

-- Teléfonos de Proveedores
CREATE TABLE Inventario.Telefonos_Proveedores (
    ruc CHAR(11) NOT NULL,
    telefono CHAR(15) NOT NULL PRIMARY KEY,
    FOREIGN KEY (ruc) REFERENCES Inventario.Proveedores(ruc) ON UPDATE CASCADE
) ON [FG_Inventario];

-- Categorías
CREATE TABLE Inventario.Categorias (
    cod_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE()
) ON [FG_Inventario];

-- Productos
CREATE TABLE Inventario.Productos (
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
    FOREIGN KEY (cod_categoria) REFERENCES Inventario.Categorias(cod_categoria) ON UPDATE CASCADE,
    FOREIGN KEY (ruc) REFERENCES Inventario.Proveedores(ruc) ON UPDATE CASCADE
) ON [FG_Inventario];

-- Crear tablas en el esquema RecursosHumanos

-- Tabla de Personas
CREATE TABLE RecursosHumanos.Personas (
    dni CHAR(8) NOT NULL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    apellido_paterno VARCHAR(20) NOT NULL,
    apellido_materno VARCHAR(20) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE()
) ON [FG_RecursosHumanos];

-- Teléfonos de Personas
CREATE TABLE RecursosHumanos.Telefonos_Personas (
    telefono CHAR(9) NOT NULL PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    FOREIGN KEY (dni) REFERENCES RecursosHumanos.Personas(dni) ON UPDATE CASCADE
) ON [FG_RecursosHumanos];

-- Direcciones de Personas
CREATE TABLE RecursosHumanos.Direcciones_Personas (
    id_direccion INT IDENTITY(1,1) PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    direccion VARCHAR(100),
    FOREIGN KEY (dni) REFERENCES RecursosHumanos.Personas(dni) ON UPDATE CASCADE
) ON [FG_RecursosHumanos];

-- Empleados
CREATE TABLE RecursosHumanos.Empleados (
    cod_empleado INT IDENTITY(1,1) PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    estado VARCHAR(10) CHECK (estado IN ('activo', 'inactivo')) NOT NULL DEFAULT 'activo',
    contraseña VARCHAR(30),
    es_administrador BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (dni) REFERENCES RecursosHumanos.Personas(dni) ON UPDATE CASCADE
) ON [FG_RecursosHumanos];

-- Vendedores
CREATE TABLE RecursosHumanos.Vendedores (
    cod_vendedor INT IDENTITY(1,1) PRIMARY KEY,
    cod_empleado INT NOT NULL,
    rol VARCHAR(20),
    FOREIGN KEY (cod_empleado) REFERENCES RecursosHumanos.Empleados(cod_empleado) ON UPDATE CASCADE
) ON [FG_RecursosHumanos];

-- Asesores
CREATE TABLE RecursosHumanos.Asesores (
    cod_asesor INT IDENTITY(1,1) PRIMARY KEY,
    cod_empleado INT NOT NULL,
    experiencia INT NOT NULL,
    especialidad VARCHAR(20) NOT NULL,
    FOREIGN KEY (cod_empleado) REFERENCES RecursosHumanos.Empleados(cod_empleado) ON UPDATE CASCADE
) ON [FG_RecursosHumanos];

-- Clientes
CREATE TABLE RecursosHumanos.Clientes (
    dni CHAR(8) NOT NULL PRIMARY KEY,
    tipo_cliente VARCHAR(10) CHECK (tipo_cliente IN ('regular', 'frecuente')) NOT NULL DEFAULT 'regular',
    FOREIGN KEY (dni) REFERENCES RecursosHumanos.Personas(dni) ON UPDATE CASCADE
) ON [FG_RecursosHumanos];

-- Contratos
CREATE TABLE RecursosHumanos.Contratos (
    cod_contrato INT IDENTITY(1,1) PRIMARY KEY,
    cod_empleado INT NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    salario_men FLOAT NOT NULL,
    observaciones TEXT,
    estado VARCHAR(10) CHECK (estado IN ('activo', 'inactivo')) NOT NULL DEFAULT 'activo',
    FOREIGN KEY (cod_empleado) REFERENCES RecursosHumanos.Empleados(cod_empleado) ON UPDATE CASCADE
) ON [FG_RecursosHumanos];

-- Crear tablas en el esquema Ventas

-- Facturas
CREATE TABLE Ventas.Facturas (
    cod_factura INT IDENTITY(1,1) PRIMARY KEY,
    dni CHAR(8) NOT NULL,
    cod_vendedor INT NOT NULL,
    cod_asesor INT,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (dni) REFERENCES RecursosHumanos.Clientes(dni) ON UPDATE NO ACTION,
    FOREIGN KEY (cod_vendedor) REFERENCES RecursosHumanos.Vendedores(cod_vendedor) ON UPDATE NO ACTION,
    FOREIGN KEY (cod_asesor) REFERENCES RecursosHumanos.Asesores(cod_asesor) ON UPDATE NO ACTION
) ON [FG_Ventas];

-- Detalles de Facturas
CREATE TABLE Ventas.Detalle_Facturas (
    cod_factura INT NOT NULL,
    cod_producto INT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (cod_factura, cod_producto),
    FOREIGN KEY (cod_factura) REFERENCES Ventas.Facturas(cod_factura) ON UPDATE CASCADE,
    FOREIGN KEY (cod_producto) REFERENCES Inventario.Productos(cod_producto) ON UPDATE CASCADE
) ON [FG_Ventas];