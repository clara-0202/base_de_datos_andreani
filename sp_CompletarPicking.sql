--Actualiza el resultado del picking. Si el resultado es 'OK', el trigger crea el despacho automáticamente.

ALTER PROCEDURE sp_CompletarPicking
    @id_picking INT,
    @resultado_validacion VARCHAR(20),  -- 'OK', 'PARCIAL' o 'ERROR'
    @comentarios VARCHAR(255) = NULL
AS
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el picking exista
        IF NOT EXISTS (SELECT 1 FROM Picking WHERE id_picking = @id_picking)
        BEGIN
            PRINT 'Error: No existe el picking especificado.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizar los campos del picking
        UPDATE Picking
        SET 
            resultado_validacion = @resultado_validacion,
            comentarios = @comentarios,
            fecha_hora = GETDATE()
        WHERE id_picking = @id_picking;

        COMMIT TRANSACTION;

        PRINT 'Picking actualizado correctamente.';

        -- Mensaje según resultado
        IF @resultado_validacion = 'OK'
            PRINT 'El trigger generará automáticamente el despacho asociado.';
        ELSE IF @resultado_validacion = 'PARCIAL'
            PRINT 'El picking quedó marcado como parcial. No se genera despacho automático.';
        ELSE
            PRINT 'El picking se marcó como con error.';

        -- Mostrar el estado actualizado
        SELECT 
            id_picking,
            id_detalle_pedido,
            id_operario,
            fecha_hora,
            resultado_validacion,
            comentarios
        FROM Picking
        WHERE id_picking = @id_picking;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al completar el picking. Transacción revertida.';
    END CATCH;
END;
GO