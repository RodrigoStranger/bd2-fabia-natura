USE FabiaNatura;
GO

-- Procedimiento almacenado que muestra reportes por categoria
CREATE PROCEDURE Inventario.ReporteProductosPorCategorias
AS
BEGIN
    DECLARE @categoria_nombre NVARCHAR(100);

    -- Cursor para recorrer todas las categorías
    DECLARE categoria_cursor CURSOR FOR
        SELECT nombre
        FROM Inventario.Categorias;

    OPEN categoria_cursor;
    FETCH NEXT FROM categoria_cursor INTO @categoria_nombre;

    -- Iterar sobre cada categoría
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '--- Categoría: ' + @categoria_nombre + ' ---';  -- Imprimir el encabezado de la categoría

        -- Imprimir los productos de la categoría actual
        DECLARE @cod_producto INT, @nombre_producto NVARCHAR(100), @estado_producto VARCHAR(10), @stock INT;
        
        -- Seleccionar los productos de la categoría
        DECLARE producto_cursor CURSOR FOR
            SELECT p.cod_producto, p.nombre, p.estado, p.stock
            FROM Inventario.Productos p
            INNER JOIN Inventario.Categorias c ON p.cod_categoria = c.cod_categoria
            WHERE c.nombre = @categoria_nombre;

        OPEN producto_cursor;
        FETCH NEXT FROM producto_cursor INTO @cod_producto, @nombre_producto, @estado_producto, @stock;

        -- Iterar sobre los productos de la categoría
        WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT 'Código Producto: ' + CAST(@cod_producto AS NVARCHAR(10));  -- Imprimir código de producto
            PRINT 'Nombre Producto: ' + @nombre_producto;  -- Imprimir nombre de producto
            PRINT 'Estado: ' + @estado_producto;  -- Imprimir estado del producto
            PRINT 'Stock: ' + CAST(@stock AS NVARCHAR(10));  -- Imprimir stock del producto
            PRINT '';  -- Salto de línea entre productos

            FETCH NEXT FROM producto_cursor INTO @cod_producto, @nombre_producto, @estado_producto, @stock;
        END

        -- Cerrar el cursor de productos
        CLOSE producto_cursor;
        DEALLOCATE producto_cursor;

        -- Salto de línea entre categorías
        PRINT '';

        FETCH NEXT FROM categoria_cursor INTO @categoria_nombre;  -- Obtener la siguiente categoría
    END

    -- Cerrar el cursor de categorías
    CLOSE categoria_cursor;
    DEALLOCATE categoria_cursor;
END;
GO

-- Mostrar los productos por una categoria en especifico
CREATE PROCEDURE Inventario.ReporteProductosPorCategoriaEspecifica
    @cod_categoria INT = NULL
AS
BEGIN
    -- Validar si se filtrará por categoría
    IF @cod_categoria IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Inventario.Categorias WHERE cod_categoria = @cod_categoria)
        BEGIN
            RAISERROR('La categoría especificada no existe.', 16, 1);
            RETURN;
        END;
    END;
    
    -- Consulta principal con SELECT anidado corregido
    SELECT 
        c.nombre AS Categoria,  -- Categoría ahora es la primera columna
        p.cod_producto AS CodigoProducto,
        p.nombre AS NombreProducto,
        p.precio_venta AS PrecioVenta,
        p.stock,
        (
            -- SELECT anidado para cantidad vendida (solo referencia a p.cod_producto)
            SELECT ISNULL(SUM(df.cantidad), 0)
            FROM Ventas.Detalle_Facturas df
            WHERE df.cod_producto = p.cod_producto
        ) AS Vendidos,
        (
            -- SELECT anidado para total generado
            SELECT ISNULL(SUM(df.cantidad * dfp.precio_venta), 0)
            FROM Ventas.Detalle_Facturas df
            INNER JOIN Inventario.Productos dfp ON df.cod_producto = dfp.cod_producto
            WHERE df.cod_producto = p.cod_producto
        ) AS TotalGenerado
    FROM 
        Inventario.Productos p
    INNER JOIN 
        Inventario.Categorias c ON p.cod_categoria = c.cod_categoria
    WHERE 
        @cod_categoria IS NULL OR p.cod_categoria = @cod_categoria
    ORDER BY 
        Vendidos DESC;
END;
GO