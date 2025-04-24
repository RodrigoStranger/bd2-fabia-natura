USE FabiaNatura;
GO

CREATE PROCEDURE Ventas.ReporteStock
AS
BEGIN
    DECLARE @cod_producto INT,
            @nombre_producto NVARCHAR(100),
            @stock INT,
            @estado_producto VARCHAR(10),
            @unidades_pedidas INT,
            @mensaje NVARCHAR(50);

    -- Cursor para recorrer los productos y calcular unidades pedidas
    DECLARE producto_cursor CURSOR FOR
        SELECT p.cod_producto, 
               p.nombre, 
               p.stock, 
               p.estado,
               -- Usamos COALESCE() antes del SUM() para evitar NULL
               ISNULL(SUM(COALESCE(d.cantidad, 0)), 0) AS unidades_pedidas  -- Reemplazar NULL con 0 en unidades pedidas
        FROM Inventario.Productos p
        LEFT JOIN Ventas.Detalle_Facturas d ON p.cod_producto = d.cod_producto
        GROUP BY p.cod_producto, p.nombre, p.stock, p.estado;

    OPEN producto_cursor;
    FETCH NEXT FROM producto_cursor INTO @cod_producto, @nombre_producto, @stock, @estado_producto, @unidades_pedidas;
	PRINT '---------------------'
	PRINT 'REPORTE DE PRODUCTOS'
	PRINT '---------------------'
	PRINT ''
    -- Iterar sobre los productos
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si las unidades pedidas son mayores al stock disponible
        IF @unidades_pedidas > @stock
        BEGIN
            SET @mensaje = 'COMPRAR URGENTE';
        END
        ELSE
        BEGIN
            SET @mensaje = 'STOCK ADECUADO';
        END

        -- Imprimir el resultado para cada producto en el formato solicitado
        PRINT 'Codigo del producto: ' + CAST(@cod_producto AS NVARCHAR(10)) + '';
        PRINT 'Nombre del producto: ' + @nombre_producto + '';
        PRINT 'Estado del stock: ' + @estado_producto + '';
        PRINT 'Unidades vendidas: ' + CAST(@unidades_pedidas AS NVARCHAR(10)) + '';
        PRINT 'Se requiere: ' + @mensaje + '';
        PRINT '';  -- Salto de línea entre productos

        -- Obtener el siguiente producto
        FETCH NEXT FROM producto_cursor INTO @cod_producto, @nombre_producto, @stock, @estado_producto, @unidades_pedidas;
    END

    -- Cerrar y liberar el cursor
    CLOSE producto_cursor;
    DEALLOCATE producto_cursor;
END;
GO

-- Mostrar la cantidad de ventas por producto
CREATE PROCEDURE Ventas.ReporteTotalVentasPorProducto
AS
BEGIN
    SELECT 
        p.nombre AS Producto,
        p.cod_producto AS ID_Producto,
        -- Subconsulta que calcula el total de ventas por producto
        (SELECT SUM(df.cantidad * p.precio_venta) 
         FROM Ventas.Detalle_Facturas df
         INNER JOIN Inventario.Productos p ON df.cod_producto = p.cod_producto
         WHERE df.cod_producto = p.cod_producto) AS Total_Ventas
    FROM Inventario.Productos p
    ORDER BY Total_Ventas DESC;
END;