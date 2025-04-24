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

-- Crear una factura
CREATE PROCEDURE Ventas.CrearFactura
    @dni_cliente CHAR(8),        -- DNI del cliente
    @cod_vendedor INT,           -- Código del vendedor
    @cod_asesor INT = NULL       -- Código del asesor (opcional)
AS
BEGIN
    BEGIN TRANSACTION;  -- Iniciar la transacción
    
    BEGIN TRY
        DECLARE @cod_factura INT;  -- Variable para almacenar el código de la nueva factura
        
        -- Insertar la nueva factura en la tabla de facturas
        INSERT INTO Ventas.Facturas (dni, cod_vendedor, cod_asesor, fecha_registro)
        VALUES (@dni_cliente, @cod_vendedor, @cod_asesor, GETDATE());
        
        -- Obtener el código de la factura recién insertada
        SET @cod_factura = SCOPE_IDENTITY();
        
        -- Verificación: ¿Existe el cliente?
        IF NOT EXISTS (SELECT 1 FROM RecursosHumanos.Clientes WHERE dni = @dni_cliente)
        BEGIN
            -- Si no existe el cliente, revertimos la transacción
            ROLLBACK;
            PRINT 'Error: El cliente con DNI ' + @dni_cliente + ' no existe.';
            RETURN;  -- Salir del procedimiento
        END
        
        -- Verificación: ¿Existe el vendedor?
        IF NOT EXISTS (SELECT 1 FROM RecursosHumanos.Vendedores WHERE cod_vendedor = @cod_vendedor)
        BEGIN
            -- Si no existe el vendedor, revertimos la transacción
            ROLLBACK;
            PRINT 'Error: El vendedor con código ' + CAST(@cod_vendedor AS NVARCHAR(10)) + ' no existe.';
            RETURN;  -- Salir del procedimiento
        END
        
        -- Verificación: ¿Existe el asesor (si se proporciona)?
        IF @cod_asesor IS NOT NULL AND NOT EXISTS (SELECT 1 FROM RecursosHumanos.Asesores WHERE cod_asesor = @cod_asesor)
        BEGIN
            -- Si no existe el asesor, revertimos la transacción
            ROLLBACK;
            PRINT 'Error: El asesor con código ' + CAST(@cod_asesor AS NVARCHAR(10)) + ' no existe.';
            RETURN;  -- Salir del procedimiento
        END
        
        -- Si todo está bien, confirmar la transacción
        COMMIT;
        PRINT 'Factura creada exitosamente. Código de factura: ' + CAST(@cod_factura AS NVARCHAR(10));
    END TRY
    BEGIN CATCH
        
        -- Si ocurre un error, revertimos la transacción
        ROLLBACK;
        
        -- Mostrar el mensaje de error
        PRINT 'Error al crear la factura: ' + ERROR_MESSAGE();
        RETURN;  -- Salir del procedimiento
    END CATCH
END;
GO

-- Eliminar una factura y devolver sus stocks a como estaban antes
CREATE PROCEDURE Ventas.EliminarFactura
    @cod_factura INT -- Código de la factura a eliminar
AS
BEGIN
    BEGIN TRANSACTION;  -- Iniciar la transacción

    BEGIN TRY
        -- Verificar si la factura existe
        IF NOT EXISTS (SELECT 1 FROM Ventas.Facturas WHERE cod_factura = @cod_factura)
        BEGIN
            -- Si la factura no existe, revertimos la transacción
            ROLLBACK;
            PRINT 'Error: La factura con el código ' + CAST(@cod_factura AS NVARCHAR(10)) + ' no existe.';
            RETURN;  -- Salir del procedimiento
        END

        -- Variables para almacenar los valores de los detalles de la factura
        DECLARE @cod_producto INT, @cantidad INT, @stock_actual INT;

        -- Cursor para obtener los detalles de la factura
        DECLARE detalle_cursor CURSOR FOR
            SELECT cod_producto, cantidad
            FROM Ventas.Detalle_Facturas
            WHERE cod_factura = @cod_factura;

        OPEN detalle_cursor;
        FETCH NEXT FROM detalle_cursor INTO @cod_producto, @cantidad;

        -- Revertir el stock de cada producto
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Obtener el stock actual del producto
            SELECT @stock_actual = stock
            FROM Inventario.Productos
            WHERE cod_producto = @cod_producto;

            -- Actualizar el stock del producto (sumar la cantidad vendida)
            UPDATE Inventario.Productos
            SET stock = @stock_actual + @cantidad
            WHERE cod_producto = @cod_producto;

            -- Obtener el siguiente detalle de la factura
            FETCH NEXT FROM detalle_cursor INTO @cod_producto, @cantidad;
        END

        -- Cerrar y liberar el cursor
        CLOSE detalle_cursor;
        DEALLOCATE detalle_cursor;

        -- Eliminar los detalles de la factura
        DELETE FROM Ventas.Detalle_Facturas
        WHERE cod_factura = @cod_factura;

        -- Eliminar la factura
        DELETE FROM Ventas.Facturas
        WHERE cod_factura = @cod_factura;

        -- Confirmar la transacción si todo ha ido bien
        COMMIT;

        PRINT 'Factura eliminada y stock restaurado exitosamente.';

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertimos la transacción
        ROLLBACK;

        -- Mostrar el mensaje de error
        PRINT 'Error al eliminar la factura: ' + ERROR_MESSAGE();
        RETURN;  -- Salir del procedimiento
    END CATCH
END;
GO
