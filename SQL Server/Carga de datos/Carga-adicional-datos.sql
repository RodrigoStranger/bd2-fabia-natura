USE FabiaNatura;
GO

-- Desactivar restricciones de clave foránea temporalmente para facilitar la inserción de datos
ALTER TABLE Ventas.Detalle_Facturas NOCHECK CONSTRAINT ALL;
ALTER TABLE Ventas.Facturas NOCHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Telefonos_Personas NOCHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Direcciones_Personas NOCHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Empleados NOCHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Vendedores NOCHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Asesores NOCHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Clientes NOCHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Contratos NOCHECK CONSTRAINT ALL;
GO

-- 1. Insertar 10 vendedores
INSERT INTO RecursosHumanos.Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento)
VALUES
('12345678', 'Juan', 'Perez', 'Gomez', '1985-05-15'),
('23456789', 'Maria', 'Lopez', 'Garcia', '1990-08-22'),
('34567890', 'Carlos', 'Martinez', 'Sanchez', '1988-03-10'),
('45678901', 'Ana', 'Gonzalez', 'Rodriguez', '1992-11-30'),
('56789012', 'Pedro', 'Ramirez', 'Diaz', '1987-07-25'),
('67890123', 'Laura', 'Torres', 'Vargas', '1991-04-18'),
('78901234', 'Jorge', 'Silva', 'Mendoza', '1989-09-12'),
('89012345', 'Sofia', 'Rojas', 'Peralta', '1993-02-28'),
('90123456', 'Diego', 'Castro', 'Rios', '1986-12-05'),
('01234567', 'Valeria', 'Flores', 'Campos', '1994-06-20');

-- Insertar teléfonos para vendedores
INSERT INTO RecursosHumanos.Telefonos_Personas (telefono, dni)
VALUES
('991234567', '12345678'),
('992345678', '23456789'),
('993456789', '34567890'),
('994567890', '45678901'),
('995678901', '56789012'),
('996789012', '67890123'),
('997890123', '78901234'),
('998901234', '89012345'),
('999012345', '90123456'),
('990123456', '01234567');

-- Insertar direcciones para vendedores
INSERT INTO RecursosHumanos.Direcciones_Personas (dni, direccion)
VALUES
('12345678', 'Av. Los Jardines 123, Lima'),
('23456789', 'Jr. Las Orquídeas 456, Lima'),
('34567890', 'Calle Los Pinos 789, Lima'),
('45678901', 'Av. Las Palmeras 321, Lima'),
('56789012', 'Jr. Las Rosas 654, Lima'),
('67890123', 'Av. Los Girasoles 987, Lima'),
('78901234', 'Calle Las Margaritas 654, Lima'),
('89012345', 'Av. Los Jazmines 321, Lima'),
('90123456', 'Jr. Las Gardenias 159, Lima'),
('01234567', 'Av. Las Azucenas 753, Lima');

-- Insertar como empleados
INSERT INTO RecursosHumanos.Empleados (dni, estado, es_administrador)
SELECT dni, 'activo', 0
FROM RecursosHumanos.Personas 
WHERE dni IN ('12345678', '23456789', '34567890', '45678901', '56789012', '67890123', '78901234', '89012345', '90123456', '01234567');

-- Insertar como vendedores
INSERT INTO RecursosHumanos.Vendedores (cod_empleado, rol)
SELECT cod_empleado, 'vendedor'
FROM RecursosHumanos.Empleados 
WHERE dni IN ('12345678', '23456789', '34567890', '45678901', '56789012', '67890123', '78901234', '89012345', '90123456', '01234567');

-- Insertar contratos para vendedores
INSERT INTO RecursosHumanos.Contratos (cod_empleado, fecha_inicio, fecha_fin, salario_men, estado)
SELECT 
    cod_empleado,
    '2024-01-01',
    '2024-12-31',
    CASE 
        WHEN dni IN ('12345678', '23456789') THEN 2500.00
        WHEN dni IN ('34567890', '45678901') THEN 2300.00
        ELSE 2100.00
    END,
    'activo'
FROM RecursosHumanos.Empleados 
WHERE dni IN ('12345678', '23456789', '34567890', '45678901', '56789012', '67890123', '78901234', '89012345', '90123456', '01234567');

-- 2. Insertar 10 asesores
INSERT INTO RecursosHumanos.Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento)
VALUES
('11223344', 'Luis', 'Mendoza', 'Quispe', '1983-04-12'),
('22334455', 'Carmen', 'Vega', 'Salas', '1987-09-25'),
('33445566', 'Raul', 'Paredes', 'Zapata', '1985-11-30'),
('44556677', 'Patricia', 'Chavez', 'Ruiz', '1990-07-18'),
('55667788', 'Miguel', 'Rios', 'Castro', '1988-02-22'),
('66778899', 'Gabriela', 'Diaz', 'Paz', '1992-05-15'),
('77889900', 'Oscar', 'Huaman', 'Lopez', '1986-08-08'),
('88990011', 'Claudia', 'Soto', 'Mesa', '1989-12-03'),
('99001122', 'Fernando', 'Arias', 'Tello', '1984-03-27'),
('00112233', 'Daniela', 'Paz', 'Solis', '1991-10-10');

-- Insertar teléfonos para asesores
INSERT INTO RecursosHumanos.Telefonos_Personas (telefono, dni)
VALUES
('981234567', '11223344'),
('982345678', '22334455'),
('983456789', '33445566'),
('984567890', '44556677'),
('985678901', '55667788'),
('986789012', '66778899'),
('987890123', '77889900'),
('988901234', '88990011'),
('989012345', '99001122'),
('980123456', '00112233');

-- Insertar direcciones para asesores
INSERT INTO RecursosHumanos.Direcciones_Personas (dni, direccion)
VALUES
('11223344', 'Av. Los Olivos 123, Lima'),
('22334455', 'Jr. Las Begonias 456, Lima'),
('33445566', 'Calle Las Dalias 789, Lima'),
('44556677', 'Av. Las Hortensias 321, Lima'),
('55667788', 'Jr. Las Azaleas 654, Lima'),
('66778899', 'Av. Las Camelias 987, Lima'),
('77889900', 'Calle Las Gardenias 654, Lima'),
('88990011', 'Av. Las Magnolias 321, Lima'),
('99001122', 'Jr. Las Orquídeas 159, Lima'),
('00112233', 'Av. Las Rosas 753, Lima');

-- Insertar como empleados
INSERT INTO RecursosHumanos.Empleados (dni, estado, es_administrador)
SELECT dni, 'activo', 0
FROM RecursosHumanos.Personas 
WHERE dni IN ('11223344', '22334455', '33445566', '44556677', '55667788', '66778899', '77889900', '88990011', '99001122', '00112233');

-- Insertar como asesores
INSERT INTO RecursosHumanos.Asesores (cod_empleado, experiencia, especialidad)
SELECT 
    cod_empleado, 
    FLOOR(RAND(CHECKSUM(NEWID())) * 10) + 1, -- Experiencia aleatoria entre 1 y 10 años
    CASE 
        WHEN RAND() > 0.7 THEN 'Dermatólogo'
        WHEN RAND() > 0.4 THEN 'Cosmetólogo'
        ELSE 'Esteticista'
    END
FROM RecursosHumanos.Empleados 
WHERE dni IN ('11223344', '22334455', '33445566', '44556677', '55667788', '66778899', '77889900', '88990011', '99001122', '00112233');

-- Insertar contratos para asesores
INSERT INTO RecursosHumanos.Contratos (cod_empleado, fecha_inicio, fecha_fin, salario_men, estado)
SELECT 
    cod_empleado,
    '2024-01-01',
    '2024-12-31',
    CASE 
        WHEN dni IN ('11223344', '22334455') THEN 3500.00
        WHEN dni IN ('33445566', '44556677') THEN 3200.00
        ELSE 3000.00
    END,
    'activo'
FROM RecursosHumanos.Empleados 
WHERE dni IN ('11223344', '22334455', '33445566', '44556677', '55667788', '66778899', '77889900', '88990011', '99001122', '00112233');

-- 3. Insertar 100 clientes
-- (Voy a insertar los primeros 10 como ejemplo, el patrón sería similar para los 90 restantes)
INSERT INTO RecursosHumanos.Personas (dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento)
VALUES
-- Primeros 10 clientes
('10000001', 'Andrea', 'Gutierrez', 'Salas', '1990-06-15'),
('10000002', 'Roberto', 'Mendez', 'Paredes', '1988-09-22'),
('10000003', 'Lucia', 'Quispe', 'Huaman', '1992-03-10'),
('10000004', 'Javier', 'Reyes', 'Castro', '1985-11-28'),
('10000005', 'Sandra', 'Vega', 'Diaz', '1993-07-14'),
('10000006', 'Mario', 'Tello', 'Rios', '1987-04-30'),
('10000007', 'Carolina', 'Zapata', 'Mesa', '1991-12-05'),
('10000008', 'Hugo', 'Paz', 'Solis', '1989-08-18'),
('10000009', 'Natalia', 'Ruiz', 'Chavez', '1994-02-25'),
('10000010', 'Eduardo', 'Salas', 'Arias', '1986-10-08'),
-- Siguientes 90 clientes (patrón similar)
('10000011', 'Verónica', 'Mendoza', 'Lopez', '1990-05-12'),
('10000012', 'Gustavo', 'Torres', 'Garcia', '1988-11-20'),
('10000013', 'Daniela', 'Silva', 'Sanchez', '1992-07-03'),
('10000014', 'Ricardo', 'Gonzalez', 'Rodriguez', '1985-09-17'),
('10000015', 'Mariana', 'Ramirez', 'Diaz', '1993-01-25'),
('10000016', 'Felipe', 'Torres', 'Vargas', '1987-06-08'),
('10000017', 'Camila', 'Silva', 'Mendoza', '1991-10-15'),
('10000018', 'Andrés', 'Rojas', 'Peralta', '1989-04-22'),
('10000019', 'Valentina', 'Castro', 'Rios', '1994-08-30'),
('10000020', 'Santiago', 'Flores', 'Campos', '1986-12-12'),
('10000021', 'Florencia', 'Gutierrez', 'Salas', '1990-06-15'),
('10000022', 'Matías', 'Mendez', 'Paredes', '1988-09-22'),
('10000023', 'Isabella', 'Quispe', 'Huaman', '1992-03-10'),
('10000024', 'Sebastián', 'Reyes', 'Castro', '1985-11-28'),
('10000025', 'Sofía', 'Vega', 'Diaz', '1993-07-14'),
('10000026', 'Joaquín', 'Tello', 'Rios', '1987-04-30'),
('10000027', 'Martina', 'Zapata', 'Mesa', '1991-12-05'),
('10000028', 'Benjamín', 'Paz', 'Solis', '1989-08-18'),
('10000029', 'Emilia', 'Ruiz', 'Chavez', '1994-02-25'),
('10000030', 'Vicente', 'Salas', 'Arias', '1986-10-08'),
('10000031', 'Renata', 'Mendoza', 'Lopez', '1990-05-12'),
('10000032', 'Alonso', 'Torres', 'Garcia', '1988-11-20'),
('10000033', 'Catalina', 'Silva', 'Sanchez', '1992-07-03'),
('10000034', 'Tomás', 'Gonzalez', 'Rodriguez', '1985-09-17'),
('10000035', 'Emilia', 'Ramirez', 'Diaz', '1993-01-25'),
('10000036', 'Julián', 'Torres', 'Vargas', '1987-06-08'),
('10000037', 'Antonella', 'Silva', 'Mendoza', '1991-10-15'),
('10000038', 'Maximiliano', 'Rojas', 'Peralta', '1989-04-22'),
('10000039', 'Valeria', 'Castro', 'Rios', '1994-08-30'),
('10000040', 'Emiliano', 'Flores', 'Campos', '1986-12-12'),
('10000041', 'María José', 'Gutierrez', 'Salas', '1990-06-15'),
('10000042', 'Diego', 'Mendez', 'Paredes', '1988-09-22'),
('10000043', 'Antonia', 'Quispe', 'Huaman', '1992-03-10'),
('10000044', 'Juan Pablo', 'Reyes', 'Castro', '1985-11-28'),
('10000045', 'Josefina', 'Vega', 'Diaz', '1993-07-14'),
('10000046', 'Cristóbal', 'Tello', 'Rios', '1987-04-30'),
('10000047', 'Isidora', 'Zapata', 'Mesa', '1991-12-05'),
('10000048', 'Agustín', 'Paz', 'Solis', '1989-08-18'),
('10000049', 'Florencia', 'Ruiz', 'Chavez', '1994-02-25'),
('10000050', 'Vicente', 'Salas', 'Arias', '1986-10-08'),
('10000051', 'María Jesús', 'Mendoza', 'Lopez', '1990-05-12'),
('10000052', 'Joaquín', 'Torres', 'Garcia', '1988-11-20'),
('10000053', 'María Ignacia', 'Silva', 'Sanchez', '1992-07-03'),
('10000054', 'Martín', 'Gonzalez', 'Rodriguez', '1985-09-17'),
('10000055', 'María Paz', 'Ramirez', 'Diaz', '1993-01-25'),
('10000056', 'Juan José', 'Torres', 'Vargas', '1987-06-08'),
('10000057', 'María Fernanda', 'Silva', 'Mendoza', '1991-10-15'),
('10000058', 'Felipe', 'Rojas', 'Peralta', '1989-04-22'),
('10000059', 'María Victoria', 'Castro', 'Rios', '1994-08-30'),
('10000060', 'Cristóbal', 'Flores', 'Campos', '1986-12-12'),
('10000061', 'María José', 'Gutierrez', 'Salas', '1990-06-15'),
('10000062', 'Diego', 'Mendez', 'Paredes', '1988-09-22'),
('10000063', 'Antonia', 'Quispe', 'Huaman', '1992-03-10'),
('10000064', 'Juan Pablo', 'Reyes', 'Castro', '1985-11-28'),
('10000065', 'Josefina', 'Vega', 'Diaz', '1993-07-14'),
('10000066', 'Cristóbal', 'Tello', 'Rios', '1987-04-30'),
('10000067', 'Isidora', 'Zapata', 'Mesa', '1991-12-05'),
('10000068', 'Agustín', 'Paz', 'Solis', '1989-08-18'),
('10000069', 'Florencia', 'Ruiz', 'Chavez', '1994-02-25'),
('10000070', 'Vicente', 'Salas', 'Arias', '1986-10-08'),
('10000071', 'María Jesús', 'Mendoza', 'Lopez', '1990-05-12'),
('10000072', 'Joaquín', 'Torres', 'Garcia', '1988-11-20'),
('10000073', 'María Ignacia', 'Silva', 'Sanchez', '1992-07-03'),
('10000074', 'Martín', 'Gonzalez', 'Rodriguez', '1985-09-17'),
('10000075', 'María Paz', 'Ramirez', 'Diaz', '1993-01-25'),
('10000076', 'Juan José', 'Torres', 'Vargas', '1987-06-08'),
('10000077', 'María Fernanda', 'Silva', 'Mendoza', '1991-10-15'),
('10000078', 'Felipe', 'Rojas', 'Peralta', '1989-04-22'),
('10000079', 'María Victoria', 'Castro', 'Rios', '1994-08-30'),
('10000080', 'Cristóbal', 'Flores', 'Campos', '1986-12-12'),
('10000081', 'María José', 'Gutierrez', 'Salas', '1990-06-15'),
('10000082', 'Diego', 'Mendez', 'Paredes', '1988-09-22'),
('10000083', 'Antonia', 'Quispe', 'Huaman', '1992-03-10'),
('10000084', 'Juan Pablo', 'Reyes', 'Castro', '1985-11-28'),
('10000085', 'Josefina', 'Vega', 'Diaz', '1993-07-14'),
('10000086', 'Cristóbal', 'Tello', 'Rios', '1987-04-30'),
('10000087', 'Isidora', 'Zapata', 'Mesa', '1991-12-05'),
('10000088', 'Agustín', 'Paz', 'Solis', '1989-08-18'),
('10000089', 'Florencia', 'Ruiz', 'Chavez', '1994-02-25'),
('10000090', 'Vicente', 'Salas', 'Arias', '1986-10-08'),
('10000091', 'María Jesús', 'Mendoza', 'Lopez', '1990-05-12'),
('10000092', 'Joaquín', 'Torres', 'Garcia', '1988-11-20'),
('10000093', 'María Ignacia', 'Silva', 'Sanchez', '1992-07-03'),
('10000094', 'Martín', 'Gonzalez', 'Rodriguez', '1985-09-17'),
('10000095', 'María Paz', 'Ramirez', 'Diaz', '1993-01-25'),
('10000096', 'Juan José', 'Torres', 'Vargas', '1987-06-08'),
('10000097', 'María Fernanda', 'Silva', 'Mendoza', '1991-10-15'),
('10000098', 'Felipe', 'Rojas', 'Peralta', '1989-04-22'),
('10000099', 'María Victoria', 'Castro', 'Rios', '1994-08-30'),
('10000100', 'Cristóbal', 'Flores', 'Campos', '1986-12-12');

-- Insertar teléfonos para clientes (solo primeros 10 como ejemplo)
INSERT INTO RecursosHumanos.Telefonos_Personas (telefono, dni)
SELECT 
    CONCAT('9', 900000000 + ROW_NUMBER() OVER (ORDER BY dni)),
    dni
FROM RecursosHumanos.Personas 
WHERE dni LIKE '10000%';

-- Insertar direcciones para clientes (solo primeros 10 como ejemplo)
INSERT INTO RecursosHumanos.Direcciones_Personas (dni, direccion)
SELECT 
    dni,
    CONCAT('Calle Cliente ', SUBSTRING(dni, 6, 5), ' #', ROW_NUMBER() OVER (ORDER BY dni), ', Lima')
FROM RecursosHumanos.Personas 
WHERE dni LIKE '10000%';

-- Insertar como clientes
INSERT INTO RecursosHumanos.Clientes (dni, tipo_cliente)
SELECT 
    dni,
    CASE 
        WHEN RAND(CHECKSUM(NEWID())) > 0.7 THEN 'frecuente'
        ELSE 'regular'
    END
FROM RecursosHumanos.Personas 
WHERE dni LIKE '10000%';

-- 4. Insertar facturas (1 por cliente)
-- Primero, creamos una tabla temporal para almacenar los códigos de vendedor y asesor
DECLARE @Vendedores TABLE (id INT IDENTITY(1,1), cod_vendedor INT);
DECLARE @Asesores TABLE (id INT IDENTITY(1,1), cod_asesor INT);

-- Llenamos las tablas temporales con los códigos de vendedores y asesores
INSERT INTO @Vendedores (cod_vendedor)
SELECT cod_vendedor FROM RecursosHumanos.Vendedores;

INSERT INTO @Asesores (cod_asesor)
SELECT cod_asesor FROM RecursosHumanos.Asesores;

-- Insertamos las facturas
DECLARE @i INT = 1;
DECLARE @total_clientes INT = (SELECT COUNT(*) FROM RecursosHumanos.Clientes);
DECLARE @fecha_inicio DATE = '2024-01-01';
DECLARE @fecha_fin DATE = GETDATE();
DECLARE @dias_diferencia INT = DATEDIFF(DAY, @fecha_inicio, @fecha_fin);

WHILE @i <= @total_clientes
BEGIN
    DECLARE @dni_cliente CHAR(8) = (SELECT dni FROM (SELECT ROW_NUMBER() OVER (ORDER BY dni) AS rn, dni FROM RecursosHumanos.Clientes) AS t WHERE rn = @i);
    DECLARE @fecha_factura DATE = DATEADD(DAY, FLOOR(RAND(CHECKSUM(NEWID())) * @dias_diferencia), @fecha_inicio);
    DECLARE @cod_vendedor INT = (SELECT TOP 1 cod_vendedor FROM @Vendedores ORDER BY NEWID());
    DECLARE @cod_asesor INT = (SELECT TOP 1 cod_asesor FROM @Asesores ORDER BY NEWID());
    
    -- Insertar factura
    INSERT INTO Ventas.Facturas (dni, cod_vendedor, cod_asesor, fecha_registro)
    VALUES (@dni_cliente, @cod_vendedor, @cod_asesor, @fecha_factura);
    
    -- Obtener el ID de la factura recién insertada
    DECLARE @cod_factura INT = SCOPE_IDENTITY();
    
    -- Insertar detalles de factura (3-5 productos por factura)
    DECLARE @num_productos INT = FLOOR(RAND(CHECKSUM(NEWID())) * 3) + 3; -- Entre 3 y 5 productos
    DECLARE @j INT = 1;
    
    WHILE @j <= @num_productos
    BEGIN
        -- Seleccionar un producto aleatorio que tenga stock
        DECLARE @cod_producto INT;
        DECLARE @precio_venta FLOAT;
        DECLARE @stock_actual INT;
        
        SELECT TOP 1 
            @cod_producto = p.cod_producto,
            @precio_venta = p.precio_venta,
            @stock_actual = p.stock
        FROM Inventario.Productos p
        WHERE p.stock > 0
        ORDER BY NEWID();
        
        -- Si hay stock, insertar el detalle
        IF @stock_actual > 0
        BEGIN
            DECLARE @cantidad INT = FLOOR(RAND(CHECKSUM(NEWID())) * 3) + 1; -- Entre 1 y 3 unidades
            
            -- Asegurarse de no exceder el stock
            IF @cantidad > @stock_actual
                SET @cantidad = @stock_actual;
            
            -- Insertar detalle de factura
            INSERT INTO Ventas.Detalle_Facturas (cod_factura, cod_producto, cantidad)
            VALUES (@cod_factura, @cod_producto, @cantidad);
            
            -- Actualizar el stock del producto
            UPDATE Inventario.Productos
            SET stock = stock - @cantidad
            WHERE cod_producto = @cod_producto;
            
            -- Si el stock llega a cero, marcar como agotado
            IF (@stock_actual - @cantidad) <= 0
            BEGIN
                UPDATE Inventario.Productos
                SET estado = 'agotado'
                WHERE cod_producto = @cod_producto;
            END
            
            SET @j = @j + 1;
        END
    END
    
    SET @i = @i + 1;
END

-- Reactivar restricciones de clave foránea
ALTER TABLE Ventas.Detalle_Facturas CHECK CONSTRAINT ALL;
ALTER TABLE Ventas.Facturas CHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Telefonos_Personas CHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Direcciones_Personas CHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Empleados CHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Vendedores CHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Asesores CHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Clientes CHECK CONSTRAINT ALL;
ALTER TABLE RecursosHumanos.Contratos CHECK CONSTRAINT ALL;

-- Mostrar resumen de la carga de datos
SELECT 'Resumen de la carga de datos' AS Descripcion, COUNT(*) AS Cantidad FROM RecursosHumanos.Personas WHERE dni LIKE '10000%' 
UNION ALL SELECT 'Clientes insertados', COUNT(*) FROM RecursosHumanos.Clientes WHERE dni LIKE '10000%'
UNION ALL SELECT 'Vendedores insertados', COUNT(*) FROM RecursosHumanos.Vendedores WHERE cod_empleado > 2
UNION ALL SELECT 'Asesores insertados', COUNT(*) FROM RecursosHumanos.Asesores WHERE cod_empleado > 2
UNION ALL SELECT 'Facturas generadas', COUNT(*) FROM Ventas.Facturas
UNION ALL SELECT 'Detalles de factura generados', COUNT(*) FROM Ventas.Detalle_Facturas;

-- Mostrar algunas facturas de ejemplo
SELECT TOP 10 
    f.cod_factura,
    p.nombre + ' ' + p.apellido_paterno AS Cliente,
    f.fecha_registro,
    COUNT(df.cod_producto) AS Cantidad_Productos,
    SUM(df.cantidad * pr.precio_venta) AS Total
FROM Ventas.Facturas f
JOIN RecursosHumanos.Personas p ON f.dni = p.dni
JOIN Ventas.Detalle_Facturas df ON f.cod_factura = df.cod_factura
JOIN Inventario.Productos pr ON df.cod_producto = pr.cod_producto
GROUP BY f.cod_factura, p.nombre, p.apellido_paterno, f.fecha_registro
ORDER BY f.cod_factura DESC;

-- Mostrar productos más vendidos
SELECT TOP 10 
    p.nombre AS Producto,
    c.nombre AS Categoria,
    SUM(df.cantidad) AS Unidades_Vendidas,
    SUM(df.cantidad * p.precio_venta) AS Total_Vendido
FROM Ventas.Detalle_Facturas df
JOIN Inventario.Productos p ON df.cod_producto = p.cod_producto
JOIN Inventario.Categorias c ON p.cod_categoria = c.cod_categoria
GROUP BY p.nombre, c.nombre
ORDER BY Unidades_Vendidas DESC;
