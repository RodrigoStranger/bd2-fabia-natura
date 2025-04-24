USE FabiaNatura;
GO 

-- Procedimiento almacenado que obtiene las facturas en las que ha participado un asesor con una especialidad específica.
CREATE PROCEDURE RecursosHumanos.ReporteFacturasPorEspecialidadAsesor
    @especialidad VARCHAR(20)
AS
BEGIN
    -- Verificar si la especialidad existe en la tabla de Asesores
    IF NOT EXISTS (SELECT 1 FROM RecursosHumanos.Asesores WHERE especialidad = @especialidad)
    BEGIN
        RAISERROR('La especialidad especificada no existe.', 16, 1);
        RETURN;
    END;

    -- Consulta para obtener las facturas relacionadas con la especialidad del asesor
    SELECT 
        f.cod_factura,
        f.dni AS ClienteDNI,
        f.cod_vendedor,
        f.cod_asesor,
        f.fecha_registro AS FechaFactura,
        (
            -- Subconsulta para obtener la especialidad del asesor
            SELECT a.especialidad
            FROM RecursosHumanos.Asesores a
            WHERE a.cod_asesor = f.cod_asesor
        ) AS EspecialidadAsesor,
        (
            -- Subconsulta para obtener el nombre del producto
            SELECT p.nombre
            FROM Inventario.Productos p
            WHERE p.cod_producto = df.cod_producto
        ) AS NombreProducto,
        df.cantidad,
        (
            -- Subconsulta para obtener el precio de venta del producto
            SELECT p.precio_venta
            FROM Inventario.Productos p
            WHERE p.cod_producto = df.cod_producto
        ) AS PrecioVenta,
        (
            -- Subconsulta para calcular el total por producto
            SELECT (df.cantidad * p.precio_venta)
            FROM Inventario.Productos p
            WHERE p.cod_producto = df.cod_producto
        ) AS TotalProducto
    FROM 
        Ventas.Facturas f
    INNER JOIN 
        Ventas.Detalle_Facturas df ON f.cod_factura = df.cod_factura
    WHERE 
        f.cod_asesor IN (SELECT cod_asesor FROM RecursosHumanos.Asesores WHERE especialidad = @especialidad)
    ORDER BY 
        f.fecha_registro DESC;
END;