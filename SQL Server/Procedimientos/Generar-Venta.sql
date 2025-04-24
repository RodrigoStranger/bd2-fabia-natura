-- Procedimiento para Realizar Venta con verificación de stock
CREATE PROCEDURE CrearDetalleFactura
    @cod_factura INT,
    @cod_producto INT,
    @cantidad INT
AS
BEGIN
    BEGIN TRANSACTION;

    DECLARE @stock_actual INT;

    SELECT @stock_actual = stock
    FROM Productos
    WHERE cod_producto = @cod_producto;

    IF @stock_actual IS NULL
    BEGIN
        RAISERROR('Producto no encontrado.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF @stock_actual < @cantidad
    BEGIN
        RAISERROR('Stock insuficiente.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Insertar detalle de factura
    INSERT INTO Detalle_Facturas (cod_factura, cod_producto, cantidad)
    VALUES (@cod_factura, @cod_producto, @cantidad);

    -- Actualizar inventario
    UPDATE Productos
    SET stock = stock - @cantidad
    WHERE cod_producto = @cod_producto;

    COMMIT TRANSACTION;
END;