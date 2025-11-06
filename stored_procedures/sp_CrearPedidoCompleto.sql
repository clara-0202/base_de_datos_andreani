-- Crea un pedido y sus detalles dentro de una transacción

CREATE TYPE TipoProductosPedido AS TABLE (
    id_producto INT,
    cantidad_solicitada INT,
    unidad_medida VARCHAR(20)
);
GO

CREATE PROCEDURE sp_CrearPedidoCompleto
    @id_cliente INT,
    @comentario VARCHAR(255),
    @productos TipoProductosPedido READONLY
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @id_estado INT;

        SELECT @id_estado = id_estado 
        FROM Estado_Pedido 
        WHERE nombre_estado = 'Pendiente';

        -- Crear el pedido
        INSERT INTO Pedido (id_cliente, fecha_pedido, id_estado, comentario)
        VALUES (@id_cliente, GETDATE(), @id_estado, @comentario);

        DECLARE @nuevo_id_pedido INT = SCOPE_IDENTITY();

        -- Insertar los detalles del pedido
        INSERT INTO Detalle_Pedido (id_pedido, id_producto, cantidad_solicitada, unidad_medida)
        SELECT @nuevo_id_pedido, id_producto, cantidad_solicitada, unidad_medida
        FROM @productos;

        COMMIT TRANSACTION;

        PRINT 'Pedido y detalles creados correctamente.';
        SELECT @nuevo_id_pedido AS id_pedido_creado;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al crear el pedido. Transacción revertida.';
    END CATCH;
END;
GO