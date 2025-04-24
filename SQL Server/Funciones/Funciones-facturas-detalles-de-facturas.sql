USE FabiaNatura;
GO

-- Obtener la ultima Factura
CREATE FUNCTION Ventas.ObtenerUltimaFactura()
RETURNS INT
AS
BEGIN
    DECLARE @ultima_factura INT;

    -- Obtener el código de la última factura creada (basado en la fecha de registro más reciente)
    SELECT TOP 1 @ultima_factura = cod_factura
    FROM Ventas.Facturas
    ORDER BY fecha_registro DESC;

    -- Devolver el código de la última factura
    RETURN @ultima_factura;
END;

-- SELECT Ventas.ObtenerUltimaFactura() AS UltimaFactura;

