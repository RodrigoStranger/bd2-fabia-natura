USE FabiaNatura;
GO

/*------------------- Reporte la lista de los productos -------------------------*/

DECLARE @cod_producto INT,  
        @nombre NVARCHAR(100),  
        @stock INT,  
        @unidades_orden INT = 10; -- puedes ajustar este número según el caso

DECLARE cursor_productos CURSOR FOR  
SELECT cod_producto, nombre, stock  
FROM Inventario.Productos;

OPEN cursor_productos;   

FETCH NEXT FROM cursor_productos INTO @cod_producto, @nombre, @stock;

WHILE @@FETCH_STATUS = 0  
BEGIN  
    IF @unidades_orden > @stock  
        PRINT 'COMPRA URGENTE del Producto: ' + @nombre + '  <----------------';  
    ELSE  
        PRINT 'STOCK ADECUADO del Producto: ' + @nombre;  

    FETCH NEXT FROM cursor_productos INTO @cod_producto, @nombre, @stock;  
END  

CLOSE cursor_productos;  
DEALLOCATE cursor_productos;



/*------------------------- Listado de Productos por Categorías -------------------------*/

DECLARE @CategoryID INT,  
        @CategoryName NVARCHAR(50);  

-- Declarar el cursor para recorrer las categorías
DECLARE CategoryCursor CURSOR FOR  
SELECT cod_categoria, nombre   
FROM Inventario.Categorias;  

OPEN CategoryCursor;  
FETCH NEXT FROM CategoryCursor INTO @CategoryID, @CategoryName;  

-- Recorrer cada categoría
WHILE @@FETCH_STATUS = 0  
BEGIN  
    PRINT ' ';  	
    PRINT '<-----------------  ' + LTRIM(@CategoryName) + '  ----------------->'; 
    PRINT 'Productos:';  
    
    DECLARE @ProductID INT,  
            @ProductName NVARCHAR(100),  
            @Stock INT,  
            @Price FLOAT;  

    -- Declarar el cursor para recorrer los productos dentro de cada categoría
    DECLARE ProductCursor CURSOR FOR  
    SELECT cod_producto, nombre, stock, precio_venta   
    FROM Inventario.Productos   
    WHERE cod_categoria = @CategoryID;  
    
    OPEN ProductCursor;  
    FETCH NEXT FROM ProductCursor INTO @ProductID, @ProductName, @Stock, @Price;  
    
    -- Recorrer cada producto dentro de la categoría
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        PRINT LTRIM(' (Stock: ' + STR(@Stock, 5, 0) + ')  -  Precio: ' + STR(@Price, 10, 2) + '  - ' + @ProductName );  
        FETCH NEXT FROM ProductCursor INTO @ProductID, @ProductName, @Stock, @Price;  
    END    
    CLOSE ProductCursor;  
    DEALLOCATE ProductCursor;   

    FETCH NEXT FROM CategoryCursor INTO @CategoryID, @CategoryName;  
END  

CLOSE CategoryCursor;  
DEALLOCATE CategoryCursor;  
