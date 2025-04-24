USE FabiaNatura;
GO

-- Trigger para actualizar el estado de los contratos cuando el empleado se actualiza a inactivo
CREATE TRIGGER trg_ActualizarEstadoEmpleado
ON RecursosHumanos.Empleados
AFTER UPDATE
AS
BEGIN
    -- Verificamos si el estado del empleado fue actualizado a inactivo
    IF UPDATE(estado) 
    BEGIN
        -- Evitamos que se ejecute el trigger recursivamente
        IF EXISTS (SELECT 1 FROM inserted WHERE estado = 'inactivo')
        BEGIN
            -- Actualizamos todos los contratos asociados al empleado que cambió a inactivo
            UPDATE RecursosHumanos.Contratos
            SET estado = 'inactivo'
            FROM RecursosHumanos.Contratos c
            JOIN inserted i ON c.cod_empleado = i.cod_empleado
            WHERE c.estado != 'inactivo'; -- Solo actualizamos aquellos que no están ya inactivos
        END
    END
END;