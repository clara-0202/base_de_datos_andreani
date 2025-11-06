-- Crear variable del tipo definido
DECLARE @items TipoProductosPedido;

-- Cargar los productos solicitados
INSERT INTO @items VALUES (1, 10, 'caja'), (2, 5, 'blister');

-- Ejecutar el procedimiento
EXEC sp_CrearPedidoCompleto 
    @id_cliente = 3, 
    @comentario = 'Pedido para farmacia central',
    @productos = @items;