USE FabiaNatura;
GO

-- Trigger para actualizar el estado del cliente a frecuente cuando tiene más de 10 facturas
CREATE TRIGGER trg_ActualizarEstadoClienteFrecuente
ON Ventas.Facturas
AFTER INSERT
AS
BEGIN
    -- Declaramos una variable para almacenar el número de facturas por cliente
    DECLARE @dni_cliente CHAR(8);
    -- Obtenemos el DNI del cliente de la nueva factura insertada
    SELECT @dni_cliente = dni FROM inserted;
    -- Verificamos cuántas facturas tiene el cliente
    IF (SELECT COUNT(*) FROM Ventas.Facturas WHERE dni = @dni_cliente) > 10
    BEGIN
        -- Si tiene más de 10 facturas, actualizamos su estado a frecuente
        UPDATE RecursosHumanos.Clientes
        SET tipo_cliente = 'frecuente'
        WHERE dni = @dni_cliente;
    END
END;