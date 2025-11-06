--TRIGGERS TP ANDREANI


/*
trg_detalle_pedido_stock_valido

Tabla: Detalle_Pedido
Momento: BEFORE INSERT
Propósito: Si hay cantidad suficiente en stock del producto, habilita el insert del detalle_pedido, 
si no hay stock marca como rechazado el pedido
*/
CREATE TRIGGER trg_detalle_pedido_stock_valido
ON Detalle_Pedido
INSTEAD OF INSERT
AS
BEGIN
DECLARE @PedidosSinStock TABLE (id_pedido INT PRIMARY KEY);
        INSERT INTO @PedidosSinStock (id_pedido)
        SELECT DISTINCT i.id_pedido --Busca los pedidos que no cumplen con el stock
        FROM inserted i
        WHERE ISNULL((
                SELECT SUM(l.cantidad_disponible)
                FROM Lote l
                WHERE l.id_producto = i.id_producto
        ), 0) < i.cantidad_solicitada;

        UPDATE p SET id_estado = 7, comentario = 'Rechazado por stock insuf.' FROM Pedido p
        INNER JOIN @PedidosSinStock p2 ON p.id_pedido = p2.id_pedido;
        
        INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad_solicitada, unidad_medida)
        SELECT id_pedido, id_producto, cantidad_solicitada, unidad_medida
        FROM inserted
        WHERE id_pedido NOT IN (SELECT id_pedido FROM @PedidosSinStock);

    IF EXISTS (SELECT 1 FROM @PedidosSinStock)
        PRINT 'Algunos pedidos fueron rechazados por falta de stock.';
    ELSE
        PRINT 'Todos los detalles fueron insertados correctamente.';
END;

/*
trg_picking_completado

Tabla: Picking
Momento: AFTER UPDATE
Propósito: Si resultado_validacion = 'OK', crear Despacho
*/
GO
CREATE TRIGGER trg_picking_completado
ON Picking
AFTER UPDATE
AS
BEGIN

    INSERT INTO Despacho (id_vehiculo, id_pedido, fecha_salida, fecha_llegada_estimada, id_estado)
    SELECT 
        (SELECT TOP 1 id_vehiculo FROM Vehiculo ORDER BY id_vehiculo) AS id_vehiculo,--selecciono el primer vehiculo
        dp.id_pedido,
        GETDATE() AS fecha_salida,
        DATEADD(DAY, 2, GETDATE()) AS fecha_llegada_estimada, --estimamos 2 dias como estandar de entrega
        (SELECT TOP 1 id_estado FROM Estado_Despacho WHERE nombre_estado = 'Validando' ORDER BY id_estado) AS id_estado
    FROM inserted i
    INNER JOIN deleted d 
        ON i.id_picking = d.id_picking
    INNER JOIN Detalle_pedido dp 
        ON dp.id_detalle_pedido = i.id_detalle_pedido
    WHERE i.resultado_validacion = 'OK'
      AND d.resultado_validacion <> 'OK';
END;