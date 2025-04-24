USE FabiaNatura;
GO

-- Trigger para actualizar el estado a agotado cuando el stock llegue a 0
CREATE TRIGGER trg_ActualizarEstadoAgotado
ON Inventario.Productos
AFTER UPDATE
AS
BEGIN
    DISABLE TRIGGER trg_ActualizarEstadoDisponible ON Inventario.Productos;
    UPDATE p
    SET p.estado = 'agotado'
    FROM Inventario.Productos p
    INNER JOIN inserted i ON p.cod_producto = i.cod_producto
    WHERE i.stock = 0 AND p.estado != 'agotado';
    ENABLE TRIGGER trg_ActualizarEstadoDisponible ON Inventario.Productos;
END;
GO

-- Trigger para actualizar el estado a disponible cuando el stock sea mayor a 0
CREATE TRIGGER trg_ActualizarEstadoDisponible
ON Inventario.Productos
AFTER UPDATE
AS
BEGIN
    DISABLE TRIGGER trg_ActualizarEstadoAgotado ON Inventario.Productos;
    UPDATE p
    SET p.estado = 'disponible'
    FROM Inventario.Productos p
    INNER JOIN inserted i ON p.cod_producto = i.cod_producto
    WHERE i.stock > 0 AND p.estado != 'disponible';
    ENABLE TRIGGER trg_ActualizarEstadoAgotado ON Inventario.Productos;
END;
GO