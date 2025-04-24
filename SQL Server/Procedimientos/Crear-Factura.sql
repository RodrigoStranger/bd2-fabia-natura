CREATE PROCEDURE CrearFactura
    @dni_cliente CHAR(8),
    @cod_vendedor INT,
    @cod_asesor INT = NULL,
    @cod_factura INT OUTPUT
AS
BEGIN
    INSERT INTO Facturas (dni, cod_vendedor, cod_asesor)
    VALUES (@dni_cliente, @cod_vendedor, @cod_asesor);

    SET @cod_factura = SCOPE_IDENTITY();
END;