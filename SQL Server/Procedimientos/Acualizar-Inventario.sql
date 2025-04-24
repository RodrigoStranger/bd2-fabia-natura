--Procedimiento para Actualizar inventario
CREATE PROCEDURE ActualizarInventario
    @cod_producto INT,
    @cantidad INT
AS
BEGIN
    UPDATE Productos
    SET stock = stock - @cantidad
    WHERE cod_producto = @cod_producto;
END;