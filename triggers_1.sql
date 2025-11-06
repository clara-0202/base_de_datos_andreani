-- TRIGGER 4: trg_despacho_entregado
-- Tabla: Despacho
-- Momento: AFTER UPDATE
-- Propósito: Si fecha_entrega_real se completa, actualizar estado pedido a 'ENTREGADO'
-- Por qué: Cierra el ciclo del pedido automáticamente

CREATE OR ALTER TRIGGER trg_despacho_entregado
ON Despacho
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE p
    SET id_estado = 5
    FROM Pedido p
    INNER JOIN inserted i ON p.id_pedido = i.id_pedido
    INNER JOIN deleted d ON p.id_pedido = d.id_pedido
    WHERE i.fecha_entrega_real IS NOT NULL
      AND d.fecha_entrega_real IS NULL
      AND i.id_pedido IS NOT NULL
      AND p.id_estado <> 5;
    
    IF @@ROWCOUNT > 0
        PRINT 'Estado del pedido actualizado a Entregado.';
END;
GO