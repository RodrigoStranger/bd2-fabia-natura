--Procedimiento para Actualizar inventario
CREATE PROCEDURE sp_ActualizarInventario
    @cod_producto INT,
    @cantidad INT
AS
BEGIN
    BEGIN TRY
        -- Restar la cantidad vendida al inventario del producto
        UPDATE Productos
        SET stock = stock - @cantidad
        WHERE cod_producto = @cod_producto;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH;
END;