USE FabiaNatura;
GO

-- Prodedimiento para poder agregar un detalle de factura
CREATE PROCEDURE Ventas.CrearDetalleFactura
    @cod_factura INT,
    @cod_producto INT, -- Producto para agregar al detalle de la factura
    @cantidad INT -- Cantidad del producto
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @estado_producto VARCHAR(10), @stock INT, @precio_venta FLOAT, @nombre_producto NVARCHAR(100);

        -- Verificar si el cod_factura existe
        IF NOT EXISTS (SELECT 1 FROM Ventas.Facturas WHERE cod_factura = @cod_factura)
        BEGIN
            -- Si no existe, revertimos todo con un ROLLBACK
            ROLLBACK;
            PRINT 'La factura con el código ' + CAST(@cod_factura AS NVARCHAR(10)) + ' no existe.';
            RETURN; -- Salir del procedimiento después de imprimir el mensaje
        END

        -- Insertar el detalle de la factura
        INSERT INTO Ventas.Detalle_Facturas (cod_factura, cod_producto, cantidad)
        VALUES (@cod_factura, @cod_producto, @cantidad);

        -- Obtener información del producto
        SELECT 
            @estado_producto = estado, 
            @stock = stock, 
            @precio_venta = precio_venta, 
            @nombre_producto = nombre
        FROM Inventario.Productos
        WHERE cod_producto = @cod_producto;

        -- Verificar si el producto no existe
        IF @estado_producto IS NULL
        BEGIN
            -- Si no existe, revertimos todo con un ROLLBACK
            ROLLBACK;
            PRINT 'El producto con el código ' + CAST(@cod_producto AS NVARCHAR(10)) + ' no existe.';
            RETURN; -- Salir del procedimiento después de imprimir el mensaje
        END

        -- Verificar si el producto está agotado
        IF @estado_producto = 'agotado'
        BEGIN
            -- Si está agotado, revertimos todo con un ROLLBACK
            ROLLBACK;
            PRINT 'El producto ' + COALESCE(CAST(@nombre_producto AS NVARCHAR(100)), 'Desconocido') + ' está agotado y no puede ser vendido.';
            RETURN; -- Salir del procedimiento después de imprimir el mensaje
        END

        -- Verificar si hay suficiente stock
        IF @stock < @cantidad
        BEGIN
            -- Si no hay suficiente stock, revertimos todo con un ROLLBACK
            ROLLBACK;
            PRINT 'No hay suficiente stock para el producto ' + COALESCE(CAST(@nombre_producto AS NVARCHAR(100)), 'Desconocido') + '.';
            RETURN; -- Salir del procedimiento después de imprimir el mensaje
        END

        -- Actualizar el stock del producto si todo está bien
        UPDATE Inventario.Productos
        SET stock = stock - @cantidad
        WHERE cod_producto = @cod_producto;

        -- Si todo va bien, confirmar la transacción
        COMMIT;
        PRINT 'Detalle de la factura agregado exitosamente. Producto: ' + COALESCE(CAST(@nombre_producto AS NVARCHAR(100)), 'Desconocido') + ', Cantidad: ' + CAST(@cantidad AS NVARCHAR(10)) + '.';

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacemos rollback de toda la transacción
        ROLLBACK;

        -- Mostrar el mensaje de error
        PRINT 'Error en la creación del detalle de la factura: ' + ERROR_MESSAGE();
        RETURN; -- Salir del procedimiento después de imprimir el mensaje
    END CATCH
END;
GO

-- Procedimiento almacenado para eliminar un detalle de factura
CREATE PROCEDURE Ventas.EliminarDetalleFactura
    @cod_factura INT,      -- Código de la factura
    @cod_producto INT      -- Código del producto
AS
BEGIN
    BEGIN TRANSACTION;  -- Iniciar la transacción

    BEGIN TRY
        DECLARE @cantidad INT, @stock INT;

        -- Obtener la cantidad del producto en el detalle de la factura
        SELECT @cantidad = cantidad
        FROM Ventas.Detalle_Facturas
        WHERE cod_factura = @cod_factura AND cod_producto = @cod_producto;

        -- Si no se encuentra el detalle de la factura, revertir la transacción
        IF @cantidad IS NULL
        BEGIN
            PRINT 'Error: El detalle de la factura no existe para este producto.';
            ROLLBACK;
            RETURN;
        END

        -- Obtener el stock actual del producto
        SELECT @stock = stock
        FROM Inventario.Productos
        WHERE cod_producto = @cod_producto;

        -- Restaurar el stock del producto
        UPDATE Inventario.Productos
        SET stock = @stock + @cantidad
        WHERE cod_producto = @cod_producto;

        -- Eliminar el detalle de la factura
        DELETE FROM Ventas.Detalle_Facturas
        WHERE cod_factura = @cod_factura AND cod_producto = @cod_producto;

        -- Confirmar la transacción si todo está bien
        COMMIT;

        PRINT 'Detalle de factura eliminado y stock restaurado correctamente.';
        
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertimos la transacción
        ROLLBACK;

        -- Mostrar el mensaje de error
        PRINT 'Error al eliminar el detalle de la factura: ' + ERROR_MESSAGE();
        RETURN;  -- Salir del procedimiento
    END CATCH
END;