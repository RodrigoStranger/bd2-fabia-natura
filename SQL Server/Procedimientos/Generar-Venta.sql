-- Procedimiento para Realizar Venta con verificación de stock
CREATE PROCEDURE sp_RealizarVenta
    @dni_cliente CHAR(8),
    @cod_vendedor INT,
    @cod_asesor INT,
    @cantidad INT,
    @cod_producto INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Verificar si hay suficiente stock
        DECLARE @stock_actual INT;
        SELECT @stock_actual = stock
        FROM Productos
        WHERE cod_producto = @cod_producto;

        -- Si no hay suficiente stock, generar un error
        IF @stock_actual < @cantidad
        BEGIN
            THROW 50001, 'No hay suficiente stock para realizar la venta.', 1;
        END

        -- 1. Insertar la factura
        INSERT INTO Facturas (dni, cod_vendedor, cod_asesor)
        VALUES (@dni_cliente, @cod_vendedor, @cod_asesor);

        -- Obtener el código de la factura recién insertada
        DECLARE @cod_factura INT;
        SELECT @cod_factura = SCOPE_IDENTITY();

        -- 2. Insertar el detalle de la factura
        INSERT INTO Detalle_Facturas (cod_factura, cod_producto, cantidad)
        VALUES (@cod_factura, @cod_producto, @cantidad);

        -- 3. Actualizar el inventario (reducir stock)
        EXEC sp_ActualizarInventario @cod_producto, @cantidad;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- En caso de error, revertir todo
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;