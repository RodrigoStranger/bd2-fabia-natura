USE FabiaNatura;
GO

-- Insertar 3 ventas de ejemplo

-- Venta 1: Venta normal sin asesor
INSERT INTO Ventas.Facturas (dni, cod_vendedor, cod_asesor, fecha_registro)
VALUES ('71827188', 1, NULL, '2025-05-25 10:30:00');

-- Detalles de la Venta 1
INSERT INTO Ventas.Detalle_Facturas (cod_factura, cod_producto, cantidad)
VALUES 
(IDENT_CURRENT('Ventas.Facturas'), 1, 2),  -- 2 unidades del producto con ID 1
(IDENT_CURRENT('Ventas.Facturas'), 5, 1);   -- 1 unidad del producto con ID 5

-- Actualizar stock de los productos vendidos
UPDATE Inventario.Productos 
SET stock = stock - 2 
WHERE cod_producto = 1;

UPDATE Inventario.Productos 
SET stock = stock - 1 
WHERE cod_producto = 5;

-- Venta 2: Venta con asesor
INSERT INTO Ventas.Facturas (dni, cod_vendedor, cod_asesor, fecha_registro)
VALUES ('71827188', 1, 1, '2025-05-26 15:45:00');

-- Detalles de la Venta 2
INSERT INTO Ventas.Detalle_Facturas (cod_factura, cod_producto, cantidad)
VALUES 
(IDENT_CURRENT('Ventas.Facturas'), 3, 1),  -- 1 unidad del producto con ID 3
(IDENT_CURRENT('Ventas.Facturas'), 7, 2),   -- 2 unidades del producto con ID 7
(IDENT_CURRENT('Ventas.Facturas'), 10, 1);  -- 1 unidad del producto con ID 10

-- Actualizar stock de los productos vendidos
UPDATE Inventario.Productos 
SET stock = stock - 1 
WHERE cod_producto = 3;

UPDATE Inventario.Productos 
SET stock = stock - 2 
WHERE cod_producto = 7;

UPDATE Inventario.Productos 
SET stock = stock - 1 
WHERE cod_producto = 10;

-- Venta 3: Otra venta normal
INSERT INTO Ventas.Facturas (dni, cod_vendedor, cod_asesor, fecha_registro)
VALUES ('71827188', 1, NULL, '2025-05-27 11:20:00');

-- Detalles de la Venta 3
INSERT INTO Ventas.Detalle_Facturas (cod_factura, cod_producto, cantidad)
VALUES 
(IDENT_CURRENT('Ventas.Facturas'), 2, 1),   -- 1 unidad del producto con ID 2
(IDENT_CURRENT('Ventas.Facturas'), 8, 1);    -- 1 unidad del producto con ID 8

-- Actualizar stock de los productos vendidos
UPDATE Inventario.Productos 
SET stock = stock - 1 
WHERE cod_producto = 2;

UPDATE Inventario.Productos 
SET stock = stock - 1 
WHERE cod_producto = 8;

-- Mostrar las ventas realizadas
SELECT 
    f.cod_factura,
    f.fecha_registro,
    p.nombre + ' ' + p.apellido_paterno AS cliente,
    ve.nombre + ' ' + ve.apellido_paterno AS vendedor,
    ISNULL(a.nombre + ' ' + a.apellido_paterno, 'Sin asesor') AS asesor,
    df.cod_producto,
    pr.nombre AS producto,
    df.cantidad,
    pr.precio_venta,
    (df.cantidad * pr.precio_venta) AS subtotal
FROM Ventas.Facturas f
JOIN RecursosHumanos.Personas p ON f.dni = p.dni
JOIN RecursosHumanos.Empleados e ON f.cod_vendedor = e.cod_empleado
JOIN RecursosHumanos.Personas ve ON e.dni = ve.dni
LEFT JOIN RecursosHumanos.Asesores ae ON f.cod_asesor = ae.cod_asesor
LEFT JOIN RecursosHumanos.Empleados ea ON ae.cod_empleado = ea.cod_empleado
LEFT JOIN RecursosHumanos.Personas a ON ea.dni = a.dni
JOIN Ventas.Detalle_Facturas df ON f.cod_factura = df.cod_factura
JOIN Inventario.Productos pr ON df.cod_producto = pr.cod_producto
ORDER BY f.cod_factura, df.cod_producto;
